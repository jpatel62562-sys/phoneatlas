import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phoneatlas/phoneatlas.dart';

void main() {
  group('PhoneInputFormatter', () {
    test('formats US phone numbers progressively with correct formatting characters', () {
      final formatter = PhoneInputFormatter(country: Country.unitedStates);

      // Typing '202'
      var result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(
          text: '202',
          selection: TextSelection.collapsed(offset: 3),
        ),
      );
      expect(result.text, '(202)');

      // Adding '555'
      result = formatter.formatEditUpdate(
        result,
        const TextEditingValue(
          text: '(202) 555',
          selection: TextSelection.collapsed(offset: 9),
        ),
      );
      expect(result.text, '(202) 555');

      // Adding '0123'
      result = formatter.formatEditUpdate(
        result,
        const TextEditingValue(
          text: '(202) 555-0123',
          selection: TextSelection.collapsed(offset: 14),
        ),
      );
      expect(result.text, '(202) 555-0123');
    });

    test('formats India phone numbers with space separator', () {
      final formatter = PhoneInputFormatter(country: Country.india);

      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(
          text: '9876543210',
          selection: TextSelection.collapsed(offset: 10),
        ),
      );
      expect(result.text, '98765 43210');
    });

    test('clamps India phone numbers to 10 digits when isValidate is true', () {
      final formatter = PhoneInputFormatter(
        country: Country.india,
        isValidate: true,
      );

      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(
          text: '9876543210999',
          selection: TextSelection.collapsed(offset: 13),
        ),
      );
      expect(result.text, '98765 43210');
    });

    test(
      'allows entering more than 10 digits for India when isValidate is false',
      () {
        final formatter = PhoneInputFormatter(
          country: Country.india,
          isValidate: false,
        );

        final result = formatter.formatEditUpdate(
          TextEditingValue.empty,
          const TextEditingValue(
            text: '9876543210999',
            selection: TextSelection.collapsed(offset: 13),
          ),
        );
        expect(result.text.replaceAll(' ', ''), '9876543210999');
      },
    );

    test('strips non-digits from pasted content', () {
      final formatter = PhoneInputFormatter(country: Country.india);

      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(
          text: '98765-43210',
          selection: TextSelection.collapsed(offset: 11),
        ),
      );
      expect(result.text, '98765 43210');
    });

    test('strips country calling code prefix when pasting international number into field', () {
      final formatter = PhoneInputFormatter(country: Country.india);

      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(
          text: '+91 98765 43210',
          selection: TextSelection.collapsed(offset: 16),
        ),
      );
      // Strips +91 and formats the 10 national digits
      expect(result.text, '98765 43210');
    });

    test(
      'handles backspace on formatting characters without getting stuck',
      () {
        final formatter = PhoneInputFormatter(country: Country.unitedStates);

        // Current formatted text is '(202) ' with cursor after space (offset 6)
        const current = TextEditingValue(
          text: '(202) ',
          selection: TextSelection.collapsed(offset: 6),
        );

        // User hits backspace, removing the space -> text becomes '(202)'
        const backspaced = TextEditingValue(
          text: '(202)',
          selection: TextSelection.collapsed(offset: 5),
        );

        final result = formatter.formatEditUpdate(current, backspaced);
        // The digit '2' should be removed, leaving '(20'
        expect(result.text, '(20');
      },
    );

    test('updates country dynamically', () {
      final formatter = PhoneInputFormatter(country: Country.unitedStates);
      formatter.country = Country.india;
      expect(formatter.country, Country.india);
    });

    test('formatNationalNumber with extra digits', () {
      final formatted = PhoneInputFormatter.formatNationalNumber(
        Country.india,
        '9876543210123',
      );
      // ignore: avoid_print
      print('FORMATTED EXTRA: "$formatted"');
      expect(formatted, isNotEmpty);
    });
  });
}
