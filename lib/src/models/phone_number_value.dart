import 'package:flutter/foundation.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

import '../formatters/phone_input_formatter.dart';
import '../validators/phone_validator.dart';
import 'country.dart';

/// An immutable representation of a parsed and validated phone number.
@immutable
class PhoneNumberValue {
  /// The selected or detected country.
  final Country country;

  /// The raw national phone number digits without formatting characters or dial code.
  final String nationalNumber;

  /// The international dialing code prefixed with '+' (e.g. '+91', '+1').
  final String dialCode;

  /// The international phone number formatted in E.164 standard (e.g. '+919876543210')
  /// if valid or deterministically populated. Returns empty string if invalid or empty.
  final String internationalNumber;

  /// Whether the phone number is valid according to international phone number metadata.
  final bool isValid;

  /// The country-specific formatted national phone number (e.g. '(202) 555-0123' or '98765 43210').
  final String? formattedNationalNumber;

  /// Creates an immutable [PhoneNumberValue].
  const PhoneNumberValue({
    required this.country,
    required this.nationalNumber,
    required this.dialCode,
    required this.internationalNumber,
    required this.isValid,
    this.formattedNationalNumber,
  });

  /// Creates an empty [PhoneNumberValue] for a given [country].
  factory PhoneNumberValue.empty(Country country) {
    return PhoneNumberValue(
      country: country,
      nationalNumber: '',
      dialCode: country.dialCode,
      internationalNumber: '',
      isValid: false,
      formattedNationalNumber: '',
    );
  }

  /// Extracts national digits by stripping international dial code prefix (if present)
  /// and removing any non-digit formatting characters.
  static String extractNationalDigits(Country country, String input) {
    var trimmed = input.trim();
    if (trimmed.isEmpty) return '';

    final cleanDialDigits = country.dialCode.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanDialDigits.isNotEmpty) {
      final dialPattern = RegExp('^(?:\\+|00)\\s*$cleanDialDigits[\\s\\-]*');
      if (dialPattern.hasMatch(trimmed)) {
        trimmed = trimmed.replaceFirst(dialPattern, '');
      } else if (trimmed.startsWith('+$cleanDialDigits')) {
        trimmed = trimmed.substring(('+$cleanDialDigits').length);
      } else if (trimmed.startsWith('00$cleanDialDigits')) {
        trimmed = trimmed.substring(('00$cleanDialDigits').length);
      }
    }

    return trimmed.replaceAll(RegExp(r'[^\d]'), '');
  }

  /// Creates a [PhoneNumberValue] without executing phone-number validation rules.
  ///
  /// Useful when phone-number validation is disabled (e.g. `isValidate: false`),
  /// treating the input as a normal phone/text field while retaining the selected
  /// country, dial code, and raw digits. [isValid] is set to `true`.
  factory PhoneNumberValue.unvalidated({
    required Country country,
    required String nationalNumber,
    String? formattedNationalNumber,
  }) {
    final cleanDigits = extractNationalDigits(country, nationalNumber);
    final cleanDialCode = country.dialCode.startsWith('+')
        ? country.dialCode
        : '+${country.dialCode}';
    final intl = cleanDigits.isNotEmpty ? '$cleanDialCode$cleanDigits' : '';

    return PhoneNumberValue(
      country: country,
      nationalNumber: cleanDigits,
      dialCode: cleanDialCode,
      internationalNumber: intl,
      isValid: true,
      formattedNationalNumber: formattedNationalNumber ?? cleanDigits,
    );
  }

  /// Parses a given [nationalNumber] within the context of a [country].
  ///
  /// Extracts clean digits, performs authoritative validation against Google libphonenumber metadata
  /// and the country's dynamic length metadata, formats according to local conventions,
  /// and produces international / E.164 output.
  /// Optionally validates against a specific [type] (e.g. [PhoneNumberType.mobile]).
  factory PhoneNumberValue.parse({
    required Country country,
    required String nationalNumber,
    PhoneNumberType? type,
  }) {
    final cleanDigits = extractNationalDigits(country, nationalNumber);

    if (cleanDigits.isEmpty) {
      return PhoneNumberValue.empty(country);
    }

    final valid = PhoneValidator.isValid(country, cleanDigits, type: type);

    final cleanDialCode = country.dialCode.startsWith('+')
        ? country.dialCode
        : '+${country.dialCode}';

    final intl = valid ? '$cleanDialCode$cleanDigits' : '';

    final formatted =
        PhoneInputFormatter.formatNationalNumber(country, cleanDigits);

    return PhoneNumberValue(
      country: country,
      nationalNumber: cleanDigits,
      dialCode: cleanDialCode,
      internationalNumber: intl,
      isValid: valid,
      formattedNationalNumber: formatted.isNotEmpty ? formatted : cleanDigits,
    );
  }

  /// Parses a raw phone string, such as a full international number (e.g. `+919876543210`)
  /// or a national number with an optional [defaultCountry].
  ///
  /// Automatically resolves the country if an international dial code prefix is present.
  factory PhoneNumberValue.fromRaw({
    required String rawNumber,
    Country? defaultCountry,
    PhoneNumberType? type,
  }) {
    final trimmed = rawNumber.trim();
    if (trimmed.isEmpty) {
      return PhoneNumberValue.empty(defaultCountry ?? Country.unitedStates);
    }

    if (trimmed.startsWith('+')) {
      try {
        final parsed = PhoneNumber.parse(trimmed);
        final detectedCountry =
            Country.tryFromIsoCode(parsed.isoCode.name) ??
            defaultCountry ??
            Country.unitedStates;

        final valid = PhoneValidator.isValid(
          detectedCountry,
          parsed.nsn,
          type: type,
        );
        final cleanDialCode = detectedCountry.dialCode;
        final intl = valid ? parsed.international : '';

        return PhoneNumberValue(
          country: detectedCountry,
          nationalNumber: parsed.nsn,
          dialCode: cleanDialCode,
          internationalNumber: intl,
          isValid: valid,
          formattedNationalNumber: parsed.formatNsn(),
        );
      } catch (_) {
        // Fall back to dial code matching if parsing raw fails
        for (final country in Country.all) {
          if (trimmed.startsWith(country.dialCode)) {
            final nationalPart = trimmed.substring(country.dialCode.length);
            return PhoneNumberValue.parse(
              country: country,
              nationalNumber: nationalPart,
              type: type,
            );
          }
        }
      }
    }

    // Default to the provided country or US
    final targetCountry = defaultCountry ?? Country.unitedStates;
    return PhoneNumberValue.parse(
      country: targetCountry,
      nationalNumber: trimmed,
      type: type,
    );
  }

  /// Whether the national phone number digits satisfy the country's length constraints.
  bool get isLengthValid =>
      PhoneValidator.isLengthValid(country, nationalNumber);

  /// E.164 formatted representation. Returns `null` if the number is not valid.
  String? get e164 => isValid ? internationalNumber : null;

  /// Whether the phone number input is empty.
  bool get isEmpty => nationalNumber.isEmpty;

  /// Whether the phone number input contains digits.
  bool get isNotEmpty => nationalNumber.isNotEmpty;

  /// Creates a copy of this [PhoneNumberValue] with specified fields replaced.
  PhoneNumberValue copyWith({
    Country? country,
    String? nationalNumber,
    String? dialCode,
    String? internationalNumber,
    bool? isValid,
    String? formattedNationalNumber,
  }) {
    return PhoneNumberValue(
      country: country ?? this.country,
      nationalNumber: nationalNumber ?? this.nationalNumber,
      dialCode: dialCode ?? this.dialCode,
      internationalNumber: internationalNumber ?? this.internationalNumber,
      isValid: isValid ?? this.isValid,
      formattedNationalNumber:
          formattedNationalNumber ?? this.formattedNationalNumber,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhoneNumberValue &&
          runtimeType == other.runtimeType &&
          country == other.country &&
          nationalNumber == other.nationalNumber &&
          dialCode == other.dialCode &&
          internationalNumber == other.internationalNumber &&
          isValid == other.isValid;

  @override
  int get hashCode => Object.hash(
    country,
    nationalNumber,
    dialCode,
    internationalNumber,
    isValid,
  );

  @override
  String toString() =>
      'PhoneNumberValue(country: ${country.name}, nationalNumber: $nationalNumber, dialCode: $dialCode, internationalNumber: $internationalNumber, isValid: $isValid)';
}
