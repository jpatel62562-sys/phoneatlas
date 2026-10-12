import 'package:flutter/widgets.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

import '../models/country.dart';
import '../models/phone_number_value.dart';

/// Validation error categories for phone numbers.
enum PhoneValidationError {
  /// The phone number is valid.
  none,

  /// The input is empty or contains no digits.
  empty,

  /// The input contains invalid non-numeric characters.
  invalidCharacters,

  /// The phone number is shorter than the minimum possible length for the country.
  tooShort,

  /// The phone number exceeds the maximum possible length for the country.
  tooLong,

  /// The number has an invalid area code, prefix, or format pattern.
  invalidPattern,

  /// The number does not match valid phone number ranges for the country.
  invalidNumber,
}

/// Phone number validation engine based on international phone metadata.
class PhoneValidator {
  const PhoneValidator._();

  /// Validates whether the given [nationalNumber] is a valid phone number for [country].
  ///
  /// Optionally validates against a specific [type] (e.g. [PhoneNumberType.mobile]).
  static bool isValid(
    Country country,
    String nationalNumber, {
    PhoneNumberType? type,
  }) {
    return getValidationError(country, nationalNumber, type: type) ==
        PhoneValidationError.none;
  }

  /// Checks whether the national digits count satisfies [country]'s length constraints.
  ///
  /// - If [country.minLength] == [country.maxLength], the number must contain exactly that many digits.
  /// - If [country.minLength] != [country.maxLength], the number is valid by length when its digit
  ///   count is >= [country.minLength] and <= [country.maxLength].
  /// - Empty input returns `false`.
  /// - Digits only are counted; formatting characters and dial codes are excluded.
  static bool isLengthValid(Country country, String nationalNumber) {
    return country.isLengthValid(nationalNumber);
  }

  /// Determines the specific [PhoneValidationError] for the given [nationalNumber] and [country].
  static PhoneValidationError getValidationError(
    Country country,
    String nationalNumber, {
    PhoneNumberType? type,
  }) {
    final trimmed = nationalNumber.trim();
    if (trimmed.isEmpty) {
      return PhoneValidationError.empty;
    }

    // 1. Strip country calling code / international prefix if present (+<dialCode> or 00<dialCode>)
    var processed = trimmed;
    final cleanDialDigits = country.dialCode.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanDialDigits.isNotEmpty) {
      final dialPattern = RegExp('^(?:\\+|00)\\s*$cleanDialDigits[\\s\\-]*');
      if (dialPattern.hasMatch(processed)) {
        processed = processed.replaceFirst(dialPattern, '').trim();
      } else if (processed.startsWith('+$cleanDialDigits')) {
        processed = processed.substring(('+$cleanDialDigits').length).trim();
      } else if (processed.startsWith('00$cleanDialDigits')) {
        processed = processed.substring(('00$cleanDialDigits').length).trim();
      }
    }

    // 2. Validate disallowed characters
    // Permitted formatting characters: digits, spaces, hyphens, parentheses, dots
    final disallowedChars = RegExp(r'[^\d\s\-\(\)\.]');
    if (disallowedChars.hasMatch(processed)) {
      return PhoneValidationError.invalidCharacters;
    }

    // 3. Extract digits only
    final digitsOnly = processed.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.isEmpty) {
      return PhoneValidationError.empty;
    }

    // 4. Validate national number length against country's dynamic metadata
    final minLength = country.minLength;
    final maxLength = country.maxLength;

    if (digitsOnly.length < minLength) {
      return PhoneValidationError.tooShort;
    }

    if (digitsOnly.length > maxLength) {
      return PhoneValidationError.tooLong;
    }

    // 5. Authoritative validation via Google libphonenumber metadata
    IsoCode? iso;
    for (final c in IsoCode.values) {
      if (c.name.toUpperCase() == country.isoCode.toUpperCase()) {
        iso = c;
        break;
      }
    }

    if (iso == null) {
      // Dynamic or custom country metadata without libphonenumber numbering plan
      return PhoneValidationError.none;
    }

    final upperIso = country.isoCode.toUpperCase();
    if (upperIso == 'IN' && digitsOnly.startsWith('0')) {
      return PhoneValidationError.invalidNumber;
    }
    if (upperIso == 'US' &&
        (digitsOnly.startsWith('0') || digitsOnly.startsWith('1'))) {
      return PhoneValidationError.invalidNumber;
    }

    try {
      final parsed = PhoneNumber.parse(digitsOnly, destinationCountry: iso);

      // Verify that parsed country code matches this country's dial code
      // (guards against mock/custom countries reusing an ISO code with a different dial code)
      if (cleanDialDigits.isNotEmpty && parsed.countryCode != cleanDialDigits) {
        return PhoneValidationError.none;
      }

      final isValidNumber = type != null
          ? parsed.isValid(type: type)
          : parsed.isValid();

      if (isValidNumber) {
        return PhoneValidationError.none;
      }

      // Check if length is considered valid by libphonenumber
      final isLengthValid = type != null
          ? parsed.isValidLength(type: type)
          : parsed.isValidLength();

      if (!isLengthValid) {
        if (digitsOnly.length < minLength) {
          return PhoneValidationError.tooShort;
        } else if (digitsOnly.length > maxLength) {
          return PhoneValidationError.tooLong;
        }
      }

      // If a specific phone number type (e.g., mobile) was requested, enforce strict validity
      if (type != null) {
        return PhoneValidationError.invalidNumber;
      }

      // For general phone validation:
      // If the country has variable length (minLength != maxLength, e.g. Austria 4..13, Germany 5..15),
      // or libphonenumber confirms length validity within [minLength, maxLength],
      // the number digit count satisfies the country's specifications.
      if (minLength != maxLength || isLengthValid) {
        return PhoneValidationError.none;
      }

      return PhoneValidationError.invalidNumber;
    } catch (_) {
      if (minLength != maxLength) {
        return PhoneValidationError.none;
      }
      return PhoneValidationError.invalidNumber;
    }
  }

  /// Returns a user-friendly error string, or `null` if the phone number is valid.
  static String? validate(
    Country country,
    String nationalNumber, {
    PhoneNumberType? type,
    String? emptyMessage,
    String? invalidCharactersMessage,
    String? tooShortMessage,
    String? tooLongMessage,
    String? invalidNumberMessage,
  }) {
    final error = getValidationError(country, nationalNumber, type: type);
    switch (error) {
      case PhoneValidationError.none:
        return null;
      case PhoneValidationError.empty:
        return emptyMessage ?? 'Please enter a phone number';
      case PhoneValidationError.invalidCharacters:
        return invalidCharactersMessage ??
            'Phone number can only contain digits';
      case PhoneValidationError.tooShort:
        return tooShortMessage ??
            'Phone number is too short for ${country.name}';
      case PhoneValidationError.tooLong:
        return tooLongMessage ?? 'Phone number is too long for ${country.name}';
      case PhoneValidationError.invalidPattern:
      case PhoneValidationError.invalidNumber:
        return invalidNumberMessage ??
            'Please enter a valid phone number for ${country.name}';
    }
  }

  /// Creates a Flutter [FormFieldValidator] requiring a non-empty phone number.
  static FormFieldValidator<PhoneNumberValue> required({String? message}) {
    return (value) {
      if (value == null || value.isEmpty) {
        return message ?? 'Phone number is required';
      }
      return null;
    };
  }

  /// Creates a Flutter [FormFieldValidator] verifying that the phone number is valid.
  static FormFieldValidator<PhoneNumberValue> valid({
    PhoneNumberType? type,
    String? emptyMessage,
    String? invalidMessage,
    bool allowEmpty = false,
  }) {
    return (value) {
      if (value == null || value.isEmpty) {
        if (allowEmpty) return null;
        return emptyMessage ?? 'Please enter a phone number';
      }

      final isNumberValid = type != null
          ? PhoneValidator.isValid(
              value.country,
              value.nationalNumber,
              type: type,
            )
          : value.isValid;

      if (!isNumberValid) {
        return invalidMessage ??
            PhoneValidator.validate(
              value.country,
              value.nationalNumber,
              type: type,
            ) ??
            'Enter a valid phone number for ${value.country.name}';
      }

      return null;
    };
  }

  /// Composes multiple [FormFieldValidator]s into a single validator.
  static FormFieldValidator<PhoneNumberValue> compose(
    List<FormFieldValidator<PhoneNumberValue>> validators,
  ) {
    return (value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) return result;
      }
      return null;
    };
  }
}
