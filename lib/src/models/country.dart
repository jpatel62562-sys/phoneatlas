import 'package:flutter/foundation.dart';

import '../data/countries.dart';
import '../utils/flag_utils.dart';

/// Immutable model representing a country with its international phone specifications.
@immutable
class Country implements Comparable<Country> {
  /// The canonical English display name of the country or territory.
  final String name;

  /// The two-letter ISO 3166-1 alpha-2 country code (in uppercase).
  final String isoCode;

  /// The international dialing code prefixed with '+' (e.g., '+91', '+1').
  final String dialCode;

  /// The Unicode flag emoji representing the country.
  final String flag;

  /// The minimum expected national phone number length (in digits).
  final int minLength;

  /// The maximum expected national phone number length (in digits).
  final int maxLength;

  /// Creates an immutable [Country] instance.
  const Country({
    required this.name,
    required this.isoCode,
    required this.dialCode,
    required this.flag,
    this.minLength = 4,
    this.maxLength = 15,
  });

  /// Factory constructor that creates a [Country] and derives the flag automatically
  /// from the provided [isoCode] if not specified.
  factory Country.withDerivedFlag({
    required String name,
    required String isoCode,
    required String dialCode,
    String? flag,
    int minLength = 4,
    int maxLength = 15,
  }) {
    return Country(
      name: name,
      isoCode: isoCode.toUpperCase(),
      dialCode: dialCode.startsWith('+') ? dialCode : '+$dialCode',
      flag: flag ?? countryFlagFromIsoCode(isoCode),
      minLength: minLength,
      maxLength: maxLength,
    );
  }

  /// All 245+ supported countries and territories.
  static List<Country> get all => CountriesData.all;

  /// Well-known country constant: India (+91).
  static const Country india = Country(
    name: 'India',
    isoCode: 'IN',
    dialCode: '+91',
    flag: '🇮🇳',
    minLength: 10,
    maxLength: 10,
  );

  /// Well-known country constant: United States (+1).
  static const Country unitedStates = Country(
    name: 'United States',
    isoCode: 'US',
    dialCode: '+1',
    flag: '🇺🇸',
    minLength: 10,
    maxLength: 10,
  );

  /// Well-known country constant: United Kingdom (+44).
  static const Country unitedKingdom = Country(
    name: 'United Kingdom',
    isoCode: 'GB',
    dialCode: '+44',
    flag: '🇬🇧',
    minLength: 10,
    maxLength: 10,
  );

  /// Well-known country constant: Canada (+1).
  static const Country canada = Country(
    name: 'Canada',
    isoCode: 'CA',
    dialCode: '+1',
    flag: '🇨🇦',
    minLength: 10,
    maxLength: 10,
  );

  /// Well-known country constant: Australia (+61).
  static const Country australia = Country(
    name: 'Australia',
    isoCode: 'AU',
    dialCode: '+61',
    flag: '🇦🇺',
    minLength: 9,
    maxLength: 10,
  );

  /// Well-known country constant: Germany (+49).
  static const Country germany = Country(
    name: 'Germany',
    isoCode: 'DE',
    dialCode: '+49',
    flag: '🇩🇪',
    minLength: 10,
    maxLength: 11,
  );

  /// Well-known country constant: Austria (+43).
  static const Country austria = Country(
    name: 'Austria',
    isoCode: 'AT',
    dialCode: '+43',
    flag: '🇦🇹',
    minLength: 10,
    maxLength: 13,
  );

  /// Well-known country constant: Japan (+81).
  static const Country japan = Country(
    name: 'Japan',
    isoCode: 'JP',
    dialCode: '+81',
    flag: '🇯🇵',
    minLength: 10,
    maxLength: 10,
  );

  /// Well-known country constant: Brazil (+55).
  static const Country brazil = Country(
    name: 'Brazil',
    isoCode: 'BR',
    dialCode: '+55',
    flag: '🇧🇷',
    minLength: 11,
    maxLength: 11,
  );

  /// Well-known country constant: Afghanistan (+93).
  static const Country afghanistan = Country(
    name: 'Afghanistan',
    isoCode: 'AF',
    dialCode: '+93',
    flag: '🇦🇫',
    minLength: 9,
    maxLength: 9,
  );

  /// Looks up a [Country] by its two-letter [isoCode] (case-insensitive).
  ///
  /// Throws an [ArgumentError] if no country with the given [isoCode] is found.
  /// Use [tryFromIsoCode] if you prefer a nullable return value.
  static Country fromIsoCode(String isoCode) {
    final country = tryFromIsoCode(isoCode);
    if (country == null) {
      throw ArgumentError.value(
        isoCode,
        'isoCode',
        'No country found for ISO code "$isoCode".',
      );
    }
    return country;
  }

  /// Safely looks up a [Country] by its [isoCode] (case-insensitive).
  ///
  /// Returns `null` if no match is found or if [isoCode] is null/empty.
  static Country? tryFromIsoCode(String? isoCode) {
    if (isoCode == null || isoCode.trim().isEmpty) return null;
    final normalized = isoCode.trim().toUpperCase();
    for (final country in all) {
      if (country.isoCode == normalized) {
        return country;
      }
    }
    return null;
  }

  /// Looks up a [Country] by its international [dialCode] (e.g. '+91' or '91').
  ///
  /// When multiple countries share the same dial code (such as +1 for US and Canada),
  /// the primary country is returned.
  /// Throws an [ArgumentError] if not found.
  static Country fromDialCode(String dialCode) {
    final country = tryFromDialCode(dialCode);
    if (country == null) {
      throw ArgumentError.value(
        dialCode,
        'dialCode',
        'No country found for dial code "$dialCode".',
      );
    }
    return country;
  }

  /// Safely looks up a [Country] by its [dialCode].
  ///
  /// Returns `null` if no match is found.
  static Country? tryFromDialCode(String? dialCode) {
    if (dialCode == null || dialCode.trim().isEmpty) return null;
    final clean = dialCode.trim().replaceAll(RegExp(r'[^\d]'), '');
    if (clean.isEmpty) return null;
    final target = '+$clean';

    // Prefer exact main countries first if +1, +44, etc.
    if (target == '+1') return unitedStates;
    if (target == '+44') return unitedKingdom;

    for (final country in all) {
      if (country.dialCode == target) {
        return country;
      }
    }
    return null;
  }

  /// Filters all countries matching [query] against name, ISO code, or dial code.
  static List<Country> search(String query) {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) return List.unmodifiable(all);

    final digitsOnly = query.replaceAll(RegExp(r'[^\d]'), '');

    return all.where((c) {
      final nameMatch = c.name.toLowerCase().contains(trimmed);
      final isoMatch = c.isoCode.toLowerCase().contains(trimmed);
      final dialMatch =
          c.dialCode.toLowerCase().contains(trimmed) ||
          (digitsOnly.isNotEmpty &&
              c.dialCode.replaceAll('+', '').contains(digitsOnly));
      return nameMatch || isoMatch || dialMatch;
    }).toList();
  }

  /// Checks whether a national phone number's digit count satisfies this country's
  /// minimum and maximum length constraints.
  ///
  /// - If [minLength] == [maxLength], the number must contain exactly that many digits.
  /// - If [minLength] != [maxLength], the number is valid by length when its digit
  ///   count is >= [minLength] and <= [maxLength].
  /// - Returns `false` for empty input or numbers below [minLength] / above [maxLength].
  bool isLengthValid(String nationalNumber) {
    var trimmed = nationalNumber.trim();
    if (trimmed.isEmpty) return false;

    final cleanDialDigits = dialCode.replaceAll(RegExp(r'[^\d]'), '');
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

    final digits = trimmed.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) return false;

    if (minLength == maxLength) {
      return digits.length == minLength;
    }
    return digits.length >= minLength && digits.length <= maxLength;
  }

  @override
  int compareTo(Country other) => name.compareTo(other.name);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Country &&
          runtimeType == other.runtimeType &&
          isoCode == other.isoCode;

  @override
  int get hashCode => isoCode.hashCode;

  @override
  String toString() => '$flag $name ($dialCode)';
}
