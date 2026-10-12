import 'package:flutter_test/flutter_test.dart';
import 'package:phoneatlas/phoneatlas.dart';

void main() {
  group('PhoneValidator', () {
    group('India (+91) phone number validation', () {
      test('accepts valid 10-digit Indian numbers with standard prefixes (6, 7, 8, 9)', () {
        expect(PhoneValidator.isValid(Country.india, '9876543210'), isTrue);
        expect(PhoneValidator.isValid(Country.india, '8876543210'), isTrue);
        expect(PhoneValidator.isValid(Country.india, '7876543210'), isTrue);
        expect(PhoneValidator.isValid(Country.india, '6876543210'), isTrue);
        expect(
          PhoneValidator.getValidationError(Country.india, '9876543210'),
          PhoneValidationError.none,
        );
      });

      test('rejects 8-digit Indian numbers as tooShort', () {
        expect(PhoneValidator.isValid(Country.india, '98765432'), isFalse);
        expect(
          PhoneValidator.getValidationError(Country.india, '98765432'),
          PhoneValidationError.tooShort,
        );
      });

      test('rejects 9-digit Indian numbers as tooShort', () {
        expect(PhoneValidator.isValid(Country.india, '987654321'), isFalse);
        expect(
          PhoneValidator.getValidationError(Country.india, '987654321'),
          PhoneValidationError.tooShort,
        );
      });

      test('rejects Indian numbers with fewer than 10 digits', () {
        expect(PhoneValidator.isValid(Country.india, '987654'), isFalse);
        expect(
          PhoneValidator.getValidationError(Country.india, '987654'),
          PhoneValidationError.tooShort,
        );
      });

      test('rejects Indian numbers with more than 10 digits as tooLong', () {
        expect(PhoneValidator.isValid(Country.india, '98765432100'), isFalse);
        expect(
          PhoneValidator.getValidationError(Country.india, '98765432100'),
          PhoneValidationError.tooLong,
        );
        expect(PhoneValidator.isValid(Country.india, '987654321000'), isFalse);
        expect(
          PhoneValidator.getValidationError(Country.india, '987654321000'),
          PhoneValidationError.tooLong,
        );
      });

      test('rejects Indian numbers with invalid leading digits', () {
        // Leading 0 is not a valid national number digit
        expect(PhoneValidator.isValid(Country.india, '0876543210'), isFalse);
        expect(
          PhoneValidator.getValidationError(Country.india, '0876543210'),
          PhoneValidationError.invalidNumber,
        );
      });

      test('validates Indian mobile numbers specifically with PhoneNumberType.mobile', () {
        // Valid mobile prefixes (6, 7, 8, 9)
        expect(
          PhoneValidator.isValid(
            Country.india,
            '9876543210',
            type: PhoneNumberType.mobile,
          ),
          isTrue,
        );
        expect(
          PhoneValidator.isValid(
            Country.india,
            '8876543210',
            type: PhoneNumberType.mobile,
          ),
          isTrue,
        );
        expect(
          PhoneValidator.isValid(
            Country.india,
            '7876543210',
            type: PhoneNumberType.mobile,
          ),
          isTrue,
        );
        expect(
          PhoneValidator.isValid(
            Country.india,
            '6876543210',
            type: PhoneNumberType.mobile,
          ),
          isTrue,
        );

        // Invalid mobile prefixes (fixed line or unassigned)
        expect(
          PhoneValidator.isValid(
            Country.india,
            '1234567890',
            type: PhoneNumberType.mobile,
          ),
          isFalse,
        );
        expect(
          PhoneValidator.isValid(
            Country.india,
            '5876543210',
            type: PhoneNumberType.mobile,
          ),
          isFalse,
        );
        expect(
          PhoneValidator.isValid(
            Country.india,
            '98765432',
            type: PhoneNumberType.mobile,
          ),
          isFalse,
        );
      });

      test('does not treat +91 or 0091 calling code as national digits', () {
        // Full international number entered in national number input
        expect(PhoneValidator.isValid(Country.india, '+919876543210'), isTrue);
        expect(
          PhoneValidator.isValid(Country.india, '+91 98765 43210'),
          isTrue,
        );
        expect(PhoneValidator.isValid(Country.india, '00919876543210'), isTrue);

        // 8 national digits with +91 prefix should still be invalid (only 8 national digits)
        expect(PhoneValidator.isValid(Country.india, '+91 98765432'), isFalse);
        expect(
          PhoneValidator.getValidationError(Country.india, '+91 98765432'),
          PhoneValidationError.tooShort,
        );
      });

      test('handles formatting characters in Indian numbers correctly', () {
        expect(PhoneValidator.isValid(Country.india, '98765 43210'), isTrue);
        expect(PhoneValidator.isValid(Country.india, '98765-43210'), isTrue);
        expect(PhoneValidator.isValid(Country.india, '(98765) 43210'), isTrue);
      });
    });

    group('International country validation', () {
      test('validates US numbers with NANP rules', () {
        expect(
          PhoneValidator.isValid(Country.unitedStates, '2025550123'),
          isTrue,
        );
        expect(
          PhoneValidator.isValid(Country.unitedStates, '(202) 555-0123'),
          isTrue,
        );
        expect(
          PhoneValidator.isValid(Country.unitedStates, '+1 202-555-0123'),
          isTrue,
        );

        // Incomplete
        expect(PhoneValidator.isValid(Country.unitedStates, '202555'), isFalse);
        expect(
          PhoneValidator.getValidationError(Country.unitedStates, '202555'),
          PhoneValidationError.tooShort,
        );

        // NANP numbers cannot start with 0 or 1
        expect(
          PhoneValidator.isValid(Country.unitedStates, '0025550123'),
          isFalse,
        );
        expect(
          PhoneValidator.isValid(Country.unitedStates, '1025550123'),
          isFalse,
        );
      });

      test('validates UK numbers', () {
        expect(
          PhoneValidator.isValid(Country.unitedKingdom, '7400123456'),
          isTrue,
        );
        expect(
          PhoneValidator.isValid(Country.unitedKingdom, '+44 7400 123456'),
          isTrue,
        );

        // Incomplete
        expect(PhoneValidator.isValid(Country.unitedKingdom, '123'), isFalse);
        expect(
          PhoneValidator.getValidationError(Country.unitedKingdom, '123'),
          PhoneValidationError.tooShort,
        );
      });

      test('validates Germany numbers with variable lengths', () {
        // 8 digits
        expect(PhoneValidator.isValid(Country.germany, '30123456'), isTrue);
        // 11 digits
        expect(PhoneValidator.isValid(Country.germany, '15123456789'), isTrue);
        // Incomplete
        expect(PhoneValidator.isValid(Country.germany, '12'), isFalse);
        expect(
          PhoneValidator.getValidationError(Country.germany, '12'),
          PhoneValidationError.tooShort,
        );
      });

      test('validates Australia numbers', () {
        expect(PhoneValidator.isValid(Country.australia, '412345678'), isTrue);
        // Incomplete (8 digits for AU mobile)
        expect(PhoneValidator.isValid(Country.australia, '41234567'), isFalse);
      });

      test('validates Japan numbers', () {
        expect(PhoneValidator.isValid(Country.japan, '9012345678'), isTrue);
        // Incomplete
        expect(PhoneValidator.isValid(Country.japan, '901234'), isFalse);
      });

      test('validates France numbers', () {
        final france = Country.fromIsoCode('FR');
        expect(PhoneValidator.isValid(france, '612345678'), isTrue);
        expect(PhoneValidator.isValid(france, '61234'), isFalse);
      });
    });

    group('Edge cases and error categories', () {
      test('detects empty and whitespace-only inputs', () {
        expect(
          PhoneValidator.getValidationError(Country.india, ''),
          PhoneValidationError.empty,
        );
        expect(
          PhoneValidator.getValidationError(Country.india, '   '),
          PhoneValidationError.empty,
        );
      });

      test('detects invalid non-numeric characters', () {
        expect(
          PhoneValidator.getValidationError(Country.india, '9876abc210'),
          PhoneValidationError.invalidCharacters,
        );
        expect(
          PhoneValidator.getValidationError(Country.india, '9876#43210'),
          PhoneValidationError.invalidCharacters,
        );
      });

      test('returns user-friendly error messages', () {
        final emptyErr = PhoneValidator.validate(Country.india, '');
        expect(emptyErr, 'Please enter a phone number');

        final shortErr = PhoneValidator.validate(Country.india, '12345');
        expect(shortErr, contains('too short for India'));

        final longErr = PhoneValidator.validate(
          Country.india,
          '98765432101234',
        );
        expect(longErr, contains('too long for India'));

        final invalidCharsErr = PhoneValidator.validate(
          Country.india,
          '9876abc210',
        );
        expect(invalidCharsErr, 'Phone number can only contain digits');

        final invalidNumErr = PhoneValidator.validate(
          Country.india,
          '0876543210',
        );
        expect(invalidNumErr, 'Please enter a valid phone number for India');

        final validErr = PhoneValidator.validate(Country.india, '9876543210');
        expect(validErr, isNull);
      });
    });

    group('FormFieldValidator helpers', () {
      test('required validator rejects empty values and accepts non-empty', () {
        final requiredValidator = PhoneValidator.required();
        final emptyValue = PhoneNumberValue.empty(Country.india);
        expect(requiredValidator(emptyValue), isNotNull);

        final validValue = PhoneNumberValue.parse(
          country: Country.india,
          nationalNumber: '9876543210',
        );
        expect(requiredValidator(validValue), isNull);
      });

      test('valid validator enforces country-specific validity', () {
        final validValidator = PhoneValidator.valid();

        final validValue = PhoneNumberValue.parse(
          country: Country.india,
          nationalNumber: '9876543210',
        );
        expect(validValidator(validValue), isNull);

        // 8 digits in India should be invalid
        final eightDigitValue = PhoneNumberValue.parse(
          country: Country.india,
          nationalNumber: '98765432',
        );
        expect(eightDigitValue.isValid, isFalse);
        expect(validValidator(eightDigitValue), isNotNull);

        // 9 digits in India should be invalid
        final nineDigitValue = PhoneNumberValue.parse(
          country: Country.india,
          nationalNumber: '987654321',
        );
        expect(nineDigitValue.isValid, isFalse);
        expect(validValidator(nineDigitValue), isNotNull);
      });

      test('valid validator supports allowEmpty option', () {
        final allowEmptyValidator = PhoneValidator.valid(allowEmpty: true);
        final emptyValue = PhoneNumberValue.empty(Country.india);
        expect(allowEmptyValidator(emptyValue), isNull);

        final strictValidator = PhoneValidator.valid(allowEmpty: false);
        expect(strictValidator(emptyValue), isNotNull);
      });
    });
  });
}
