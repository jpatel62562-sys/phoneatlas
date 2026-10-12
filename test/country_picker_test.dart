import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phoneatlas/phoneatlas.dart';

void main() {
  group('CountryPicker Widget Tests', () {
    testWidgets('displays country search and lazy list', (tester) async {
      Country? selected;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showCountryPickerSheet(
                    context,
                    selectedCountry: Country.india,
                    onSelect: (c) => selected = c,
                  );
                },
                child: const Text('Open Picker'),
              ),
            ),
          ),
        ),
      );

      // Tap button to open sheet
      await tester.tap(find.text('Open Picker'));
      await tester.pumpAndSettle();

      // Verify title and search field are present
      expect(find.text('Select Country'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      // Verify search works
      await tester.enterText(find.byType(TextField), 'India');
      await tester.pumpAndSettle();

      final indiaTile = find.widgetWithText(CountryListTile, 'India');
      expect(indiaTile, findsOneWidget);
      expect(find.text('+91'), findsOneWidget);

      // Tap India tile
      await tester.tap(indiaTile);
      await tester.pumpAndSettle();

      expect(selected, Country.india);
    });

    testWidgets('shows empty state when no countries match query', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showCountryPickerDialog(
                    context,
                    selectedCountry: Country.unitedStates,
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'NonExistentCountryXYZ');
      await tester.pumpAndSettle();

      expect(find.text('No countries found'), findsOneWidget);
    });

    testWidgets('clears search when clear icon is tapped', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showCountryPickerSheet(
                    context,
                    selectedCountry: Country.unitedStates,
                  );
                },
                child: const Text('Open Picker'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Picker'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Ger');
      await tester.pumpAndSettle();
      expect(find.widgetWithText(CountryListTile, 'Germany'), findsOneWidget);

      // Tap clear icon
      await tester.tap(find.byIcon(Icons.clear_rounded));
      await tester.pumpAndSettle();

      // All countries should be restored
      expect(
        find.widgetWithText(CountryListTile, 'Afghanistan'),
        findsOneWidget,
      );
    });

    testWidgets(
      'displays selected country at top with distinct visual styling (border, background, checkmark)',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    showCountryPickerSheet(
                      context,
                      selectedCountry: Country.india,
                    );
                  },
                  child: const Text('Open Picker'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open Picker'));
        await tester.pumpAndSettle();

        // The first country tile in the list must be India
        final firstTile = tester.widget<CountryListTile>(
          find.byType(CountryListTile).first,
        );
        expect(firstTile.country, Country.india);
        expect(firstTile.isSelected, isTrue);

        // Checkmark is displayed for selected country
        expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

        // Next tile is Afghanistan (unselected)
        final tiles = tester.widgetList<CountryListTile>(
          find.byType(CountryListTile),
        ).toList();
        expect(tiles.length, greaterThan(1));
        expect(tiles[1].country.name, 'Afghanistan');
        expect(tiles[1].isSelected, isFalse);

        // Verify Divider is present separating top selected item
        expect(find.byType(Divider), findsOneWidget);
      },
    );

    testWidgets(
      'handles dynamic country changes moving newly selected country to top and updating styling',
      (tester) async {
        Country selected = Country.india;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return CountryPickerContent(
                    selectedCountry: selected,
                    themeData: const CountryPickerThemeData(),
                    onSelect: (newCountry) {
                      setState(() {
                        selected = newCountry;
                      });
                    },
                  );
                },
              ),
            ),
          ),
        );

        // Initially India is at top
        expect(
          tester.widget<CountryListTile>(find.byType(CountryListTile).first).country,
          Country.india,
        );
        expect(
          tester.widget<CountryListTile>(find.byType(CountryListTile).first).isSelected,
          isTrue,
        );

        // Tap Afghanistan (currently 2nd item)
        final afghanistanTile = find.widgetWithText(CountryListTile, 'Afghanistan');
        expect(afghanistanTile, findsOneWidget);
        await tester.tap(afghanistanTile);
        await tester.pumpAndSettle();

        // Now Afghanistan moves to top and is selected
        expect(
          tester.widget<CountryListTile>(find.byType(CountryListTile).first).country.name,
          'Afghanistan',
        );
        expect(
          tester.widget<CountryListTile>(find.byType(CountryListTile).first).isSelected,
          isTrue,
        );

        // Tap Albania (currently 2nd item)
        final albaniaTile = find.widgetWithText(CountryListTile, 'Albania');
        expect(albaniaTile, findsOneWidget);
        await tester.tap(albaniaTile);
        await tester.pumpAndSettle();

        // Albania is now at the top
        expect(
          tester.widget<CountryListTile>(find.byType(CountryListTile).first).country.name,
          'Albania',
        );
        expect(
          tester.widget<CountryListTile>(find.byType(CountryListTile).first).isSelected,
          isTrue,
        );
      },
    );

    testWidgets(
      'preserves search without duplicating selected country and restores top position on clear',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CountryPickerContent(
                selectedCountry: Country.india,
                themeData: CountryPickerThemeData(),
                onSelect: _dummySelect,
              ),
            ),
          ),
        );

        // Initially exactly one India tile at top
        expect(find.widgetWithText(CountryListTile, 'India'), findsOneWidget);
        expect(
          tester.widget<CountryListTile>(find.byType(CountryListTile).first).country,
          Country.india,
        );

        // Search "Ind" -> matches India and Indonesia
        await tester.enterText(find.byType(TextField), 'Ind');
        await tester.pumpAndSettle();

        // Exactly one India tile
        expect(find.widgetWithText(CountryListTile, 'India'), findsOneWidget);
        expect(find.widgetWithText(CountryListTile, 'Indonesia'), findsOneWidget);

        // India is at top of search results
        expect(
          tester.widget<CountryListTile>(find.byType(CountryListTile).first).country,
          Country.india,
        );
        expect(
          tester.widget<CountryListTile>(find.byType(CountryListTile).first).isSelected,
          isTrue,
        );

        // Search "Ger" -> only Germany matches, India is not shown
        await tester.enterText(find.byType(TextField), 'Ger');
        await tester.pumpAndSettle();
        expect(find.widgetWithText(CountryListTile, 'Germany'), findsOneWidget);
        expect(find.widgetWithText(CountryListTile, 'India'), findsNothing);

        // Clear search -> India is back at the top
        await tester.tap(find.byIcon(Icons.clear_rounded));
        await tester.pumpAndSettle();

        expect(
          tester.widget<CountryListTile>(find.byType(CountryListTile).first).country,
          Country.india,
        );
        expect(
          tester.widget<CountryListTile>(find.byType(CountryListTile).first).isSelected,
          isTrue,
        );
        expect(find.widgetWithText(CountryListTile, 'India'), findsOneWidget);
      },
    );

    testWidgets(
      'reopening picker via PhoneAtlasField synchronizes selected country, flag, dial code, and top placement',
      (tester) async {
        final controller = PhoneAtlasController.fromCountry(Country.india);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PhoneAtlasField(controller: controller),
            ),
          ),
        );

        // Verify initial country display
        expect(find.text('🇮🇳'), findsOneWidget);
        expect(find.text('+91'), findsOneWidget);

        // Open picker
        await tester.tap(find.text('+91'));
        await tester.pumpAndSettle();

        // India is top and selected
        expect(
          tester.widget<CountryListTile>(find.byType(CountryListTile).first).country,
          Country.india,
        );
        expect(
          tester.widget<CountryListTile>(find.byType(CountryListTile).first).isSelected,
          isTrue,
        );

        // Search for Germany
        await tester.enterText(find.byType(TextField).last, 'Germany');
        await tester.pumpAndSettle();

        final germanyTile = find.widgetWithText(CountryListTile, 'Germany');
        expect(germanyTile, findsOneWidget);
        await tester.tap(germanyTile);
        await tester.pumpAndSettle();

        // Field is updated with Germany
        expect(controller.country, Country.germany);
        expect(find.text('🇩🇪'), findsOneWidget);
        expect(find.text('+49'), findsOneWidget);

        // Reopen picker
        await tester.tap(find.text('+49'));
        await tester.pumpAndSettle();

        // Germany is now at the top of the reopened picker
        final topTileAfterReopen = tester.widget<CountryListTile>(
          find.byType(CountryListTile).first,
        );
        expect(topTileAfterReopen.country, Country.germany);
        expect(topTileAfterReopen.isSelected, isTrue);

        // Close picker
        await tester.tap(find.byIcon(Icons.close_rounded));
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'renders responsively with LayoutBuilder on both compact and large screens',
      (tester) async {
        // Test compact screen (320px width)
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 320,
                  height: 500,
                  child: CountryPickerContent(
                    selectedCountry: Country.japan,
                    themeData: CountryPickerThemeData(),
                    onSelect: _dummySelect,
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(CountryPickerContent), findsOneWidget);
        expect(
          tester.widget<CountryListTile>(find.byType(CountryListTile).first).country,
          Country.japan,
        );

        // Test wide screen (900px width)
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 900,
                  height: 700,
                  child: CountryPickerContent(
                    selectedCountry: Country.brazil,
                    themeData: CountryPickerThemeData(),
                    onSelect: _dummySelect,
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(CountryPickerContent), findsOneWidget);
        expect(
          tester.widget<CountryListTile>(find.byType(CountryListTile).first).country,
          Country.brazil,
        );
      },
    );
  });
}

void _dummySelect(Country country) {}
