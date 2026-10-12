import 'package:flutter/services.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

import '../models/country.dart';

/// A [TextInputFormatter] that formats phone numbers in real-time according
/// to country-specific national formatting patterns while preserving correct cursor placement.
class PhoneInputFormatter extends TextInputFormatter {
  /// The active country determining formatting patterns.
  Country country;

  /// Whether to format digits as the user types. Defaults to `true`.
  final bool enableFormatting;

  /// Whether phone number validation/length constraints are enforced.
  ///
  /// When `true` (default), the maximum allowed digits is constrained to
  /// [country.maxLength].
  ///
  /// When `false`, the input behaves as a normal phone/text field and is not
  /// constrained to [country.maxLength], allowing users to enter arbitrary digits.
  final bool isValidate;

  /// Creates a [PhoneInputFormatter] for the given [country].
  PhoneInputFormatter({
    required this.country,
    this.enableFormatting = true,
    this.isValidate = true,
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Strip country dial code prefix if present (e.g. when pasting +91 98765 43210 or 0091...)
    var processedNewText = newValue.text;
    final cleanDialDigits = country.dialCode.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanDialDigits.isNotEmpty) {
      final trimmedNew = newValue.text.trim();
      if (trimmedNew.startsWith('+$cleanDialDigits')) {
        processedNewText = trimmedNew.substring(('+$cleanDialDigits').length);
      } else if (trimmedNew.startsWith('00$cleanDialDigits')) {
        processedNewText = trimmedNew.substring(('00$cleanDialDigits').length);
      }
    }

    if (!enableFormatting) {
      // Still strip non-digits if not formatted
      final clean = processedNewText.replaceAll(RegExp(r'[^\d]'), '');
      if (isValidate && clean.length > country.maxLength) {
        final capped = clean.substring(0, country.maxLength);
        return TextEditingValue(
          text: capped,
          selection: TextSelection.collapsed(offset: capped.length),
        );
      }
      return TextEditingValue(
        text: clean,
        selection: TextSelection.collapsed(offset: clean.length),
      );
    }

    final oldText = oldValue.text;
    final newText = processedNewText;

    // Handle backspace when user deletes a formatting character
    String rawDigits = newText.replaceAll(RegExp(r'[^\d]'), '');
    final oldDigits = oldText.replaceAll(RegExp(r'[^\d]'), '');

    final isDeleting = newText.length < oldText.length;

    // If user hit backspace on a formatting character (like space, bracket, hyphen),
    // and raw digits count didn't decrease, remove the preceding digit.
    if (isDeleting &&
        rawDigits.length == oldDigits.length &&
        rawDigits.isNotEmpty) {
      final oldSelectionIndex = oldValue.selection.end;
      // Count digits before cursor in old text
      int digitsBefore = 0;
      for (int i = 0; i < oldSelectionIndex && i < oldText.length; i++) {
        if (RegExp(r'\d').hasMatch(oldText[i])) {
          digitsBefore++;
        }
      }
      if (digitsBefore > 0 && digitsBefore <= rawDigits.length) {
        rawDigits =
            rawDigits.substring(0, digitsBefore - 1) +
            rawDigits.substring(digitsBefore);
      }
    }

    // Limit maximum allowed digits only if isValidate is true
    if (isValidate && rawDigits.length > country.maxLength) {
      rawDigits = rawDigits.substring(0, country.maxLength);
    }

    if (rawDigits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Count how many digits exist before the new cursor position
    int digitsBeforeCursor = 0;
    final cursorIndex = newValue.selection.end.clamp(0, newText.length);
    for (int i = 0; i < cursorIndex; i++) {
      if (RegExp(r'\d').hasMatch(newText[i])) {
        digitsBeforeCursor++;
      }
    }
    // Clamp digitsBeforeCursor to rawDigits length
    digitsBeforeCursor = digitsBeforeCursor.clamp(0, rawDigits.length);

    // Format raw digits using country metadata
    final formatted = formatNationalNumber(country, rawDigits);

    // Calculate the new cursor position in the formatted string
    final newCursorOffset = _calculateCursorOffset(
      formattedText: formatted,
      digitsBeforeCursor: digitsBeforeCursor,
    );

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newCursorOffset),
    );
  }

  /// Formats raw digits for a country using libphonenumber metadata.
  static String formatNationalNumber(Country country, String rawDigits) {
    if (rawDigits.isEmpty) return '';
    try {
      final iso = IsoCode.values.firstWhere(
        (c) => c.name.toUpperCase() == country.isoCode.toUpperCase(),
        orElse: () => IsoCode.US,
      );
      final parsed = PhoneNumber.parse(rawDigits, destinationCountry: iso);
      final formatted = parsed.formatNsn();
      return formatted.isNotEmpty ? formatted : rawDigits;
    } catch (_) {
      return rawDigits;
    }
  }

  /// Calculates the cursor index in [formattedText] such that [digitsBeforeCursor]
  /// digits appear to the left of the cursor.
  int _calculateCursorOffset({
    required String formattedText,
    required int digitsBeforeCursor,
  }) {
    if (digitsBeforeCursor <= 0) return 0;
    int digitsFound = 0;
    for (int i = 0; i < formattedText.length; i++) {
      if (RegExp(r'\d').hasMatch(formattedText[i])) {
        digitsFound++;
        if (digitsFound == digitsBeforeCursor) {
          return i + 1;
        }
      }
    }
    return formattedText.length;
  }
}
