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
  });
}
