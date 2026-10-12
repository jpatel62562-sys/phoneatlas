import 'package:flutter/foundation.dart';

import '../models/country.dart';
import '../models/phone_number_value.dart';

/// A controller that manages the state of a phone input field, including
/// the selected [Country], national digits, validation status, and E.164 output.
class PhoneAtlasController extends ValueNotifier<PhoneNumberValue> {
  /// Creates a [PhoneAtlasController] with an optional [initialValue].
  PhoneAtlasController([PhoneNumberValue? initialValue])
    : super(initialValue ?? PhoneNumberValue.empty(Country.unitedStates));

  /// Creates a [PhoneAtlasController] initialized with a specific [country] and optional [nationalNumber].
  PhoneAtlasController.fromCountry(
    Country country, [
    String nationalNumber = '',
  ]) : super(
         nationalNumber.isEmpty
             ? PhoneNumberValue.empty(country)
             : PhoneNumberValue.parse(
                 country: country,
                 nationalNumber: nationalNumber,
               ),
       );

  /// The currently selected [Country].
  Country get country => value.country;

  /// The raw national phone number digits.
  String get nationalNumber => value.nationalNumber;

  /// The international dialing code (e.g., '+1', '+91').
  String get dialCode => value.dialCode;

  /// The full international number in E.164 format if valid, or empty string.
  String get internationalNumber => value.internationalNumber;

  /// Whether the current phone number is valid for the selected country.
  bool get isValid => value.isValid;

  /// The formatted national phone number.
  String? get formattedNationalNumber => value.formattedNationalNumber;

  /// E.164 formatted string, or `null` if the number is invalid.
  String? get e164 => value.e164;

  /// Maximum allowed national number digits for the currently selected country.
  int get maxLength => value.country.maxLength;

  /// Minimum expected national number digits for the currently selected country.
  int get minLength => value.country.minLength;

  /// Updates the selected country while retaining existing digits without silent truncation.
  void setCountry(Country newCountry) {
    if (newCountry == value.country) return;
    final digits = value.nationalNumber;
    value = PhoneNumberValue.parse(country: newCountry, nationalNumber: digits);
  }

  /// Updates the national phone number digits for the current country.
  void setNationalNumber(String newNumber) {
    value = PhoneNumberValue.parse(
      country: value.country,
      nationalNumber: newNumber,
    );
  }

  /// Sets both country and national number simultaneously.
  void setPhoneNumber(Country newCountry, String newNumber) {
    value = PhoneNumberValue.parse(
      country: newCountry,
      nationalNumber: newNumber,
    );
  }

  /// Parses a raw phone string (e.g., `+919876543210` or `(202) 555-0123`),
  /// auto-detecting country if an international dial code is present.
  void setRaw(String rawNumber) {
    value = PhoneNumberValue.fromRaw(
      rawNumber: rawNumber,
      defaultCountry: value.country,
    );
  }

  /// Clears the phone number while keeping the current country.
  void clear() {
    value = PhoneNumberValue.empty(value.country);
  }
}
