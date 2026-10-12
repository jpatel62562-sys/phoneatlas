import 'package:flutter_test/flutter_test.dart';
import 'package:phoneatlas/phoneatlas.dart';

void main() {
  group('PhoneNumberValue', () {
    test('creates empty value for country', () {
      final value = PhoneNumberValue.empty(Country.india);
      expect(value.country, Country.india);
      expect(value.nationalNumber, '');
      expect(value.dialCode, '+91');
      expect(value.internationalNumber, '');
      expect(value.isValid, isFalse);
      expect(value.isEmpty, isTrue);
      expect(value.isNotEmpty, isFalse);
      expect(value.e164, isNull);
    });

    test('parses valid Indian phone number', () {
      final value = PhoneNumberValue.parse(
        country: Country.india,
        nationalNumber: '9876543210',
      );
      expect(value.country, Country.india);
      expect(value.nationalNumber, '9876543210');
      expect(value.dialCode, '+91');
      expect(value.internationalNumber, '+919876543210');
      expect(value.isValid, isTrue);
      expect(value.e164, '+919876543210');
      expect(value.formattedNationalNumber, '98765 43210');
    });

    test('parses valid US phone number', () {
      final value = PhoneNumberValue.parse(
        country: Country.unitedStates,
        nationalNumber: '2025550123',
      );
      expect(value.country, Country.unitedStates);
      expect(value.nationalNumber, '2025550123');
      expect(value.dialCode, '+1');
      expect(value.internationalNumber, '+12025550123');
      expect(value.isValid, isTrue);
      expect(value.e164, '+12025550123');
      expect(value.formattedNationalNumber, '(202) 555-0123');
    });

    test('rejects 8-digit and 9-digit Indian numbers as invalid', () {
      final val8 = PhoneNumberValue.parse(
        country: Country.india,
        nationalNumber: '98765432',
      );
      expect(val8.country, Country.india);
      expect(val8.nationalNumber, '98765432');
      expect(val8.isValid, isFalse);
      expect(val8.e164, isNull);
      expect(val8.internationalNumber, '');

      final val9 = PhoneNumberValue.parse(
        country: Country.india,
        nationalNumber: '987654321',
      );
      expect(val9.isValid, isFalse);
      expect(val9.e164, isNull);
    });

    test('extracts national digits when dial code prefix is included in nationalNumber', () {
      final val = PhoneNumberValue.parse(
        country: Country.india,
        nationalNumber: '+91 98765 43210',
      );
      expect(val.nationalNumber, '9876543210');
      expect(val.dialCode, '+91');
      expect(val.isValid, isTrue);
      expect(val.internationalNumber, '+919876543210');
      expect(val.e164, '+919876543210');
    });

    test(
      'handles invalid or incomplete numbers without returning invalid E.164',
      () {
        final value = PhoneNumberValue.parse(
          country: Country.unitedStates,
          nationalNumber: '123',
        );
        expect(value.isValid, isFalse);
        expect(value.internationalNumber, '');
        expect(value.e164, isNull);
        expect(value.nationalNumber, '123');
      },
    );

    test(
      'parses from raw full international number with auto country detection',
      () {
        final valueIn = PhoneNumberValue.fromRaw(rawNumber: '+919876543210');
        expect(valueIn.country.isoCode, 'IN');
        expect(valueIn.nationalNumber, '9876543210');
        expect(valueIn.isValid, isTrue);
        expect(valueIn.internationalNumber, '+919876543210');

        final valueUs = PhoneNumberValue.fromRaw(rawNumber: '+12025550123');
        expect(valueUs.country.isoCode, 'US');
        expect(valueUs.nationalNumber, '2025550123');
        expect(valueUs.isValid, isTrue);
      },
    );

    test('copyWith updates properties properly', () {
      final initial = PhoneNumberValue.parse(
        country: Country.india,
        nationalNumber: '9876543210',
      );
      final copied = initial.copyWith(nationalNumber: '9999999999');
      expect(copied.nationalNumber, '9999999999');
      expect(copied.country, Country.india);
    });

    test('creates unvalidated value without running phone validation', () {
      final value = PhoneNumberValue.unvalidated(
        country: Country.india,
        nationalNumber: '123',
      );
      expect(value.country, Country.india);
      expect(value.nationalNumber, '123');
      expect(value.dialCode, '+91');
      expect(value.internationalNumber, '+91123');
      expect(value.isValid, isTrue);
    });

    test('equality and hashCode work as expected', () {
      final val1 = PhoneNumberValue.parse(
        country: Country.india,
        nationalNumber: '9876543210',
      );
      final val2 = PhoneNumberValue.parse(
        country: Country.india,
        nationalNumber: '9876543210',
      );
      expect(val1, equals(val2));
      expect(val1.hashCode, equals(val2.hashCode));
    });
  });
}
