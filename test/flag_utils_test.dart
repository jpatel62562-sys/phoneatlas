import 'package:flutter_test/flutter_test.dart';
import 'package:phoneatlas/phoneatlas.dart';

void main() {
  group('FlagUtils & countryFlagFromIsoCode', () {
    test('generates expected flag emojis for standard country codes', () {
      expect(countryFlagFromIsoCode('IN'), '🇮🇳');
      expect(countryFlagFromIsoCode('US'), '🇺🇸');
      expect(countryFlagFromIsoCode('GB'), '🇬🇧');
      expect(countryFlagFromIsoCode('DE'), '🇩🇪');
      expect(countryFlagFromIsoCode('JP'), '🇯🇵');
      expect(countryFlagFromIsoCode('BR'), '🇧🇷');
      expect(countryFlagFromIsoCode('AF'), '🇦🇫');
      expect(countryFlagFromIsoCode('AU'), '🇦🇺');
      expect(countryFlagFromIsoCode('CA'), '🇨🇦');
    });

    test('is case insensitive', () {
      expect(countryFlagFromIsoCode('in'), '🇮🇳');
      expect(countryFlagFromIsoCode('us'), '🇺🇸');
      expect(countryFlagFromIsoCode('gb'), '🇬🇧');
    });

    test('returns empty string for invalid codes', () {
      expect(countryFlagFromIsoCode(''), '');
      expect(countryFlagFromIsoCode('U'), '');
      expect(countryFlagFromIsoCode('USA'), '');
      expect(countryFlagFromIsoCode('12'), '');
    });
  });
}
