/// Utility functions for country flags.
class FlagUtils {
  const FlagUtils._();

  /// Converts a two-letter ISO 3166-1 alpha-2 country code into its corresponding
  /// Unicode emoji flag representation.
  ///
  /// Examples:
  /// ```dart
  /// countryFlagFromIsoCode('IN'); // '🇮🇳'
  /// countryFlagFromIsoCode('US'); // '🇺🇸'
  /// countryFlagFromIsoCode('gb'); // '🇬🇧'
  /// ```
  ///
  /// Returns an empty string if the ISO code is invalid or not 2 characters.
  static String countryFlagFromIsoCode(String isoCode) {
    if (isoCode.length != 2) return '';
    final upper = isoCode.toUpperCase();
    final first = upper.codeUnitAt(0) - 0x41 + 0x1F1E6;
    final second = upper.codeUnitAt(1) - 0x41 + 0x1F1E6;
    if (first < 0x1F1E6 ||
        first > 0x1F1FF ||
        second < 0x1F1E6 ||
        second > 0x1F1FF) {
      return '';
    }
    return String.fromCharCode(first) + String.fromCharCode(second);
  }
}

/// Convenience top-level function for converting an ISO code to a flag emoji.
String countryFlagFromIsoCode(String isoCode) =>
    FlagUtils.countryFlagFromIsoCode(isoCode);
