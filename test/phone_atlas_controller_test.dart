import 'package:flutter_test/flutter_test.dart';
import 'package:phoneatlas/phoneatlas.dart';

void main() {
  group('PhoneAtlasController', () {
    test('initializes with default or specified country and value', () {
      final controller = PhoneAtlasController.fromCountry(Country.india);
      expect(controller.country, Country.india);
      expect(controller.nationalNumber, '');
      expect(controller.dialCode, '+91');
      expect(controller.isValid, isFalse);
    });

    test('updates national number and computes validity', () {
      final controller = PhoneAtlasController.fromCountry(Country.india);
      bool notified = false;
      controller.addListener(() => notified = true);

      controller.setNationalNumber('9876543210');
      expect(notified, isTrue);
      expect(controller.nationalNumber, '9876543210');
      expect(controller.isValid, isTrue);
      expect(controller.internationalNumber, '+919876543210');
      expect(controller.e164, '+919876543210');
    });

    test('updates country while preserving national digits and updating validation', () {
      final controller = PhoneAtlasController.fromCountry(
        Country.india,
        '9876543210',
      );
      expect(controller.isValid, isTrue);

      controller.setCountry(Country.unitedStates);
      expect(controller.country, Country.unitedStates);
      expect(controller.nationalNumber, '9876543210');
      expect(controller.dialCode, '+1');
    });

    test('clears phone number properly', () {
      final controller = PhoneAtlasController.fromCountry(
        Country.india,
        '9876543210',
      );
      controller.clear();
      expect(controller.nationalNumber, '');
      expect(controller.isValid, isFalse);
      expect(controller.country, Country.india);
    });

    test('setRaw parses international string with auto-detection', () {
      final controller = PhoneAtlasController();
      controller.setRaw('+919876543210');
      expect(controller.country.isoCode, 'IN');
      expect(controller.nationalNumber, '9876543210');
      expect(controller.isValid, isTrue);
    });

    test('exposes maxLength and minLength from selected country', () {
      final controller = PhoneAtlasController.fromCountry(Country.india);
      expect(controller.maxLength, 10);
      expect(controller.minLength, 10);
    });

    test('retains digits without silent truncation when switching countries and updates validation', () {
      final controller = PhoneAtlasController.fromCountry(
        Country.india,
        '9876543210',
      );
      expect(controller.nationalNumber.length, 10);
      expect(controller.isValid, isTrue);

      controller.setCountry(Country.afghanistan);
      expect(controller.country, Country.afghanistan);
      expect(controller.maxLength, 9);
      // Does not silently truncate existing digits
      expect(controller.nationalNumber, '9876543210');
      expect(controller.nationalNumber.length, 10);
      // Exceeds Afghanistan max length (9), so it is invalid
      expect(controller.isValid, isFalse);
    });
  });
}
