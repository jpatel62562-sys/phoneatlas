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

    test('validates length dynamically for variable-length country (minLength: 8, maxLength: 12)', () {
      const variableCountry = Country(
        name: 'Custom Variable',
        isoCode: 'CVAR',
        dialCode: '+999',
        flag: '🏳️',
        minLength: 8,
        maxLength: 12,
      );

      // 7 digits (below minLength)
      final v7 = PhoneNumberValue.parse(country: variableCountry, nationalNumber: '1234567');
      expect(v7.isLengthValid, isFalse);
      expect(v7.isValid, isFalse);

      // 8 digits (minimum boundary)
      final v8 = PhoneNumberValue.parse(country: variableCountry, nationalNumber: '12345678');
      expect(v8.isLengthValid, isTrue);
      expect(v8.isValid, isTrue);

      // 10 digits (within range)
      final v10 = PhoneNumberValue.parse(country: variableCountry, nationalNumber: '1234567890');
      expect(v10.isLengthValid, isTrue);
      expect(v10.isValid, isTrue);

      // 12 digits (maximum boundary)
      final v12 = PhoneNumberValue.parse(country: variableCountry, nationalNumber: '123456789012');
      expect(v12.isLengthValid, isTrue);
      expect(v12.isValid, isTrue);

      // 13 digits (above maxLength)
      final v13 = PhoneNumberValue.parse(country: variableCountry, nationalNumber: '1234567890123');
      expect(v13.isLengthValid, isFalse);
      expect(v13.isValid, isFalse);
    });

    test('validates length dynamically for fixed-length country (minLength: 10, maxLength: 10)', () {
      const fixedCountry = Country(
        name: 'Custom Fixed',
        isoCode: 'CFIX',
        dialCode: '+998',
        flag: '🏳️',
        minLength: 10,
        maxLength: 10,
      );

      // 9 digits (below minLength)
      final f9 = PhoneNumberValue.parse(country: fixedCountry, nationalNumber: '123456789');
      expect(f9.isLengthValid, isFalse);
      expect(f9.isValid, isFalse);

      // 10 digits (exact match)
      final f10 = PhoneNumberValue.parse(country: fixedCountry, nationalNumber: '1234567890');
      expect(f10.isLengthValid, isTrue);
      expect(f10.isValid, isTrue);

      // 11 digits (above maxLength)
      final f11 = PhoneNumberValue.parse(country: fixedCountry, nationalNumber: '12345678901');
      expect(f11.isLengthValid, isFalse);
      expect(f11.isValid, isFalse);
    });
  });
}
