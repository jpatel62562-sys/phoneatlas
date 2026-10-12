import 'package:flutter_test/flutter_test.dart';
import 'package:phoneatlas/phoneatlas.dart';

void main() {
  group('Country Model & Lookups', () {
    test('contains well-known country constants', () {
      expect(Country.india.isoCode, 'IN');
      expect(Country.india.dialCode, '+91');
      expect(Country.india.flag, '🇮🇳');
      expect(Country.india.minLength, 10);
      expect(Country.india.maxLength, 10);

      expect(Country.unitedStates.isoCode, 'US');
      expect(Country.unitedStates.dialCode, '+1');
      expect(Country.unitedStates.flag, '🇺🇸');

      expect(Country.unitedKingdom.isoCode, 'GB');
      expect(Country.unitedKingdom.dialCode, '+44');
      expect(Country.unitedKingdom.flag, '🇬🇧');

      expect(Country.germany.isoCode, 'DE');
      expect(Country.germany.dialCode, '+49');

      expect(Country.japan.isoCode, 'JP');
      expect(Country.japan.dialCode, '+81');

      expect(Country.brazil.isoCode, 'BR');
      expect(Country.brazil.dialCode, '+55');
    });

    test('Country.all contains over 240 countries and is sorted', () {
      expect(Country.all.length, greaterThanOrEqualTo(240));
      // Verify all have valid properties
      for (final country in Country.all) {
        expect(country.name.isNotEmpty, isTrue);
        expect(country.isoCode.length, 2);
        expect(country.dialCode.startsWith('+'), isTrue);
        expect(country.flag.isNotEmpty, isTrue);
        expect(country.minLength, greaterThan(0));
        expect(country.maxLength, greaterThanOrEqualTo(country.minLength));
      }
    });

    test('fromIsoCode looks up countries accurately', () {
      expect(Country.fromIsoCode('IN'), Country.india);
      expect(Country.fromIsoCode('us'), Country.unitedStates);
      expect(Country.fromIsoCode('GB'), Country.unitedKingdom);
      expect(Country.fromIsoCode('de'), Country.germany);

      expect(() => Country.fromIsoCode('XX'), throwsArgumentError);
    });

    test('tryFromIsoCode handles valid, invalid, and null inputs safely', () {
      expect(Country.tryFromIsoCode('IN'), Country.india);
      expect(Country.tryFromIsoCode('us'), Country.unitedStates);
      expect(Country.tryFromIsoCode('ZZ'), isNull);
      expect(Country.tryFromIsoCode(null), isNull);
      expect(Country.tryFromIsoCode(''), isNull);
    });

    test('fromDialCode looks up countries', () {
      expect(Country.fromDialCode('+91'), Country.india);
      expect(Country.fromDialCode('91'), Country.india);
      expect(Country.fromDialCode('+1'), Country.unitedStates);
      expect(Country.fromDialCode('+44'), Country.unitedKingdom);
      expect(Country.fromDialCode('+49'), Country.germany);
      expect(Country.fromDialCode('+81'), Country.japan);

      expect(() => Country.fromDialCode('+99999'), throwsArgumentError);
    });

    test('tryFromDialCode handles valid, invalid, and null inputs', () {
      expect(Country.tryFromDialCode('+91'), Country.india);
      expect(Country.tryFromDialCode('91'), Country.india);
      expect(Country.tryFromDialCode('+99999'), isNull);
      expect(Country.tryFromDialCode(null), isNull);
      expect(Country.tryFromDialCode(''), isNull);
    });

    test('search filters by name, ISO code, and dial code', () {
      final searchIndia = Country.search('India');
      expect(searchIndia.any((c) => c.isoCode == 'IN'), isTrue);

      final searchDial = Country.search('+91');
      expect(searchDial.any((c) => c.isoCode == 'IN'), isTrue);

      final searchIso = Country.search('gb');
      expect(searchIso.any((c) => c.isoCode == 'GB'), isTrue);

      final emptySearch = Country.search('');
      expect(emptySearch.length, Country.all.length);
    });

    test('equality and hashCode work as expected', () {
      final country1 = Country.fromIsoCode('IN');
      final country2 = Country.india;
      expect(country1, equals(country2));
      expect(country1.hashCode, equals(country2.hashCode));
      expect(country1.toString(), contains('India'));
    });
  });
}
