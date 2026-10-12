import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phoneatlas/phoneatlas.dart';

void main() {
  group('PhoneAtlasField Widget Tests', () {
    testWidgets('renders initial country, flag, and dial code', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: PhoneAtlasField(initialCountry: Country.india)),
        ),
      );

      expect(find.text('🇮🇳'), findsOneWidget);
      expect(find.text('+91'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('accepts input and triggers onChanged with parsed value', (
      tester,
    ) async {
      PhoneNumberValue? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PhoneAtlasField(
              initialCountry: Country.india,
              onChanged: (val) => result = val,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '9876543210');
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!.nationalNumber, '9876543210');
      expect(result!.isValid, isTrue);
      expect(result!.internationalNumber, '+919876543210');
      expect(result!.dialCode, '+91');
    });

    testWidgets('switches country via prefix button and updates state', (
      tester,
    ) async {
      PhoneNumberValue? lastValue;
      Country? changedCountry;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PhoneAtlasField(
              initialCountry: Country.india,
              onChanged: (val) => lastValue = val,
              onCountryChanged: (c) => changedCountry = c,
            ),
          ),
        ),
      );

      // Enter Indian number
      await tester.enterText(find.byType(TextField), '9876543210');
      await tester.pumpAndSettle();

      // Tap country selector prefix button
      await tester.tap(find.text('+91'));
      await tester.pumpAndSettle();

      // Search for United States
      await tester.enterText(find.byType(TextField).last, 'United States');
      await tester.pumpAndSettle();

      // Tap United States list tile
      final usTile = find.widgetWithText(CountryListTile, 'United States');
      expect(usTile, findsOneWidget);
      await tester.tap(usTile);
      await tester.pumpAndSettle();

      expect(changedCountry, Country.unitedStates);
      expect(find.text('🇺🇸'), findsOneWidget);
      expect(find.text('+1'), findsOneWidget);
      expect(lastValue?.country, Country.unitedStates);
    });

    testWidgets('integrates with Flutter Form, validation, and error display', (
      tester,
    ) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: PhoneAtlasField(
                initialCountry: Country.unitedStates,
                validator: (val) {
                  if (val == null || !val.isValid) {
                    return 'Please enter a valid US number';
                  }
                  return null;
                },
              ),
            ),
          ),
        ),
      );

      // Initially empty -> validate should fail
      final isValidInitial = formKey.currentState!.validate();
      await tester.pumpAndSettle();
      expect(isValidInitial, isFalse);
      expect(find.text('Please enter a valid US number'), findsOneWidget);

      // Enter valid US number
      await tester.enterText(find.byType(TextField), '2025550123');
      await tester.pumpAndSettle();

      final isValidAfter = formKey.currentState!.validate();
      await tester.pumpAndSettle();
      expect(isValidAfter, isTrue);
      expect(find.text('Please enter a valid US number'), findsNothing);
    });

    testWidgets('supports PhoneAtlasController two-way binding', (
      tester,
    ) async {
      final controller = PhoneAtlasController.fromCountry(Country.india);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: PhoneAtlasField(controller: controller)),
        ),
      );

      expect(find.text('+91'), findsOneWidget);

      // Programmatically update controller
      controller.setPhoneNumber(Country.unitedStates, '2025550123');
      await tester.pumpAndSettle();

      expect(find.text('+1'), findsOneWidget);
      expect(find.text('🇺🇸'), findsOneWidget);
      expect(controller.isValid, isTrue);
      expect(controller.internationalNumber, '+12025550123');
    });

    testWidgets('respects enabled and readOnly states', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PhoneAtlasField(
              initialCountry: Country.india,
              enabled: false,
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isFalse);

      // Tapping country selector does not open picker
      await tester.tap(find.text('+91'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.text('Select Country'), findsNothing);
    });

    testWidgets(
      'when isValidate is false, treats input as normal text without validation errors',
      (tester) async {
        final formKey = GlobalKey<FormState>();
        PhoneNumberValue? receivedValue;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Form(
                key: formKey,
                child: PhoneAtlasField(
                  initialCountry: Country.unitedStates,
                  isValidate: false,
                  onChanged: (val) => receivedValue = val,
                ),
              ),
            ),
          ),
        );

        // Enter arbitrary short number that would normally be invalid
        await tester.enterText(find.byType(TextField), '123');
        await tester.pumpAndSettle();

        expect(receivedValue, isNotNull);
        expect(receivedValue!.nationalNumber, '123');
        expect(receivedValue!.isValid, isTrue);

        // Form validation should pass without showing errors
        final formValid = formKey.currentState!.validate();
        await tester.pumpAndSettle();
        expect(formValid, isTrue);
        expect(
          find.textContaining('Please enter a valid phone number'),
          findsNothing,
        );
        expect(find.textContaining('invalid'), findsNothing);

        // Country selection still works
        await tester.tap(find.text('+1'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField).last, 'India');
        await tester.pumpAndSettle();

        final inTile = find.widgetWithText(CountryListTile, 'India');
        await tester.tap(inTile);
        await tester.pumpAndSettle();

        expect(find.text('+91'), findsOneWidget);
        expect(find.text('🇮🇳'), findsOneWidget);
        expect(receivedValue!.country, Country.india);
        expect(receivedValue!.isValid, isTrue);
      },
    );

    testWidgets(
      'when isValidate is false and country is India, allows entering more than 10 digits',
      (tester) async {
        final controller = PhoneAtlasController.fromCountry(Country.india);
        PhoneNumberValue? receivedValue;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PhoneAtlasField(
                controller: controller,
                isValidate: false,
                onChanged: (val) => receivedValue = val,
              ),
            ),
          ),
        );

        // Enter 14 digits for India (which normally has maxLength 10)
        await tester.enterText(find.byType(TextField), '98765432101234');
        await tester.pumpAndSettle();

        expect(controller.nationalNumber, '98765432101234');
        expect(receivedValue, isNotNull);
        expect(receivedValue!.nationalNumber, '98765432101234');
        expect(receivedValue!.isValid, isTrue);
        expect(receivedValue!.internationalNumber, '+9198765432101234');

        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(
          textField.controller!.text.replaceAll(' ', ''),
          '98765432101234',
        );
      },
    );

    testWidgets(
      'when isValidate is true, validates against country rules and displays error when invalid',
      (tester) async {
        final formKey = GlobalKey<FormState>();
        PhoneNumberValue? receivedValue;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Form(
                key: formKey,
                child: PhoneAtlasField(
                  initialCountry: Country.unitedStates,
                  isValidate: true,
                  onChanged: (val) => receivedValue = val,
                ),
              ),
            ),
          ),
        );

        // Enter invalid US number
        await tester.enterText(find.byType(TextField), '123');
        await tester.pumpAndSettle();

        expect(receivedValue, isNotNull);
        expect(receivedValue!.isValid, isFalse);

        // Validate form -> should fail and display error
        final formValid = formKey.currentState!.validate();
        await tester.pumpAndSettle();
        expect(formValid, isFalse);
        expect(
          find.text('Please enter a valid phone number for United States'),
          findsOneWidget,
        );

        // Enter valid US number
        await tester.enterText(find.byType(TextField), '2025550123');
        await tester.pumpAndSettle();

        expect(receivedValue!.isValid, isTrue);
        final formValidAfter = formKey.currentState!.validate();
        await tester.pumpAndSettle();
        expect(formValidAfter, isTrue);
        expect(
          find.text('Please enter a valid phone number for United States'),
          findsNothing,
        );
      },
    );

    testWidgets(
      'rejects 8-digit Indian number and shows validation error on form validate',
      (tester) async {
        final formKey = GlobalKey<FormState>();
        PhoneNumberValue? receivedValue;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Form(
                key: formKey,
                child: PhoneAtlasField(
                  initialCountry: Country.india,
                  isValidate: true,
                  onChanged: (val) => receivedValue = val,
                ),
              ),
            ),
          ),
        );

        // Enter 8 digits for India
        await tester.enterText(find.byType(TextField), '98765432');
        await tester.pumpAndSettle();

        expect(receivedValue, isNotNull);
        expect(receivedValue!.nationalNumber, '98765432');
        expect(receivedValue!.isValid, isFalse);

        // Validate form -> must fail and display error
        final formValid = formKey.currentState!.validate();
        await tester.pumpAndSettle();
        expect(formValid, isFalse);
        expect(
          find.text('Please enter a valid phone number for India'),
          findsOneWidget,
        );

        // Complete the 10 digits
        await tester.enterText(find.byType(TextField), '9876543210');
        await tester.pumpAndSettle();

        expect(receivedValue!.nationalNumber, '9876543210');
        expect(receivedValue!.isValid, isTrue);

        final formValidNow = formKey.currentState!.validate();
        await tester.pumpAndSettle();
        expect(formValidNow, isTrue);
        expect(
          find.text('Please enter a valid phone number for India'),
          findsNothing,
        );
      },
    );

    testWidgets(
      'switching countries does not silently truncate existing input',
      (tester) async {
        final controller = PhoneAtlasController.fromCountry(
          Country.india,
          '9876543210',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PhoneAtlasField(controller: controller, isValidate: true),
            ),
          ),
        );

        // Tap country selector prefix button
        await tester.tap(find.text('+91'));
        await tester.pumpAndSettle();

        // Search for Afghanistan (maxLength 9)
        await tester.enterText(find.byType(TextField).last, 'Afghanistan');
        await tester.pumpAndSettle();

        final afgTile = find.widgetWithText(CountryListTile, 'Afghanistan');
        await tester.tap(afgTile);
        await tester.pumpAndSettle();

        // Country switched to Afghanistan
        expect(controller.country, Country.afghanistan);
        // 10 digits retained, not silently truncated
        expect(controller.nationalNumber, '9876543210');
        // Because 10 digits exceeds Afghanistan's 9 digits, it is marked invalid
        expect(controller.isValid, isFalse);
      },
    );

    testWidgets(
      'dynamically validates variable-length country at boundaries and out of range',
      (tester) async {
        const variableCountry = Country(
          name: 'Custom Variable',
          isoCode: 'CVAR',
          dialCode: '+999',
          flag: '🏳️',
          minLength: 8,
          maxLength: 12,
        );

        final formKey = GlobalKey<FormState>();
        PhoneNumberValue? latestValue;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Form(
                key: formKey,
                child: PhoneAtlasField(
                  initialCountry: variableCountry,
                  isValidate: true,
                  onChanged: (val) => latestValue = val,
                ),
              ),
            ),
          ),
        );

        // 7 digits (below minLength 8) -> invalid
        await tester.enterText(find.byType(TextField), '1234567');
        await tester.pumpAndSettle();
        expect(latestValue?.isValid, isFalse);
        expect(latestValue?.isLengthValid, isFalse);
        expect(formKey.currentState!.validate(), isFalse);

        // 8 digits (min boundary) -> valid
        await tester.enterText(find.byType(TextField), '12345678');
        await tester.pumpAndSettle();
        expect(latestValue?.isValid, isTrue);
        expect(latestValue?.isLengthValid, isTrue);
        expect(formKey.currentState!.validate(), isTrue);

        // 10 digits (within range) -> valid
        await tester.enterText(find.byType(TextField), '1234567890');
        await tester.pumpAndSettle();
        expect(latestValue?.isValid, isTrue);
        expect(latestValue?.isLengthValid, isTrue);
        expect(formKey.currentState!.validate(), isTrue);

        // 12 digits (max boundary) -> valid
        await tester.enterText(find.byType(TextField), '123456789012');
        await tester.pumpAndSettle();
        expect(latestValue?.isValid, isTrue);
        expect(latestValue?.isLengthValid, isTrue);
        expect(formKey.currentState!.validate(), isTrue);
      },
    );

    testWidgets(
      'switching from variable-length country to fixed-length country immediately updates validity and triggers onChanged',
      (tester) async {
        final controller = PhoneAtlasController.fromCountry(
          Country.germany, // min: 10, max: 11
          '1512345678', // 10 digits (valid in Germany)
        );
        PhoneNumberValue? changedValue;
        Country? changedCountry;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PhoneAtlasField(
                controller: controller,
                isValidate: true,
                onChanged: (val) => changedValue = val,
                onCountryChanged: (c) => changedCountry = c,
              ),
            ),
          ),
        );

        // 10 digits is valid in Germany
        expect(controller.isValid, isTrue);

        // Switch to India (fixed 10 digits)
        await tester.tap(find.text('+49'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField).last, 'India');
        await tester.pumpAndSettle();

        final indiaTile = find.widgetWithText(CountryListTile, 'India');
        await tester.tap(indiaTile);
        await tester.pumpAndSettle();

        // Country switched to India
        expect(changedCountry, Country.india);
        expect(controller.country, Country.india);
        expect(controller.nationalNumber, '1512345678');

        // 1512345678 is 10 digits for India
        expect(controller.isValid, isTrue);
        expect(controller.isLengthValid, isTrue);
        expect(changedValue?.country, Country.india);
        expect(changedValue?.isValid, isTrue);

        // Deleting digits to 8 digits -> invalid
        await tester.enterText(find.byType(TextField), '98765432');
        await tester.pumpAndSettle();

        expect(controller.isValid, isFalse);
        expect(controller.isLengthValid, isFalse);
        expect(changedValue?.isValid, isFalse);
      },
    );

    testWidgets(
      'supports Austria (+43) mobile variable length validation (10 to 13 digits) in PhoneAtlasField',
      (tester) async {
        final controller = PhoneAtlasController.fromCountry(Country.austria);
        final formKey = GlobalKey<FormState>();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Form(
                key: formKey,
                child: PhoneAtlasField(
                  controller: controller,
                  isValidate: true,
                ),
              ),
            ),
          ),
        );

        // Initially empty -> invalid
        expect(controller.isValid, isFalse);

        // 7 digits (less than mobile minLength 10) -> invalid
        await tester.enterText(find.byType(TextField), '6501234');
        await tester.pumpAndSettle();
        expect(controller.isValid, isFalse);
        expect(formKey.currentState!.validate(), isFalse);

        // 10 digits (mobile minLength 10) -> valid!
        await tester.enterText(find.byType(TextField), '9876543210');
        await tester.pumpAndSettle();
        expect(controller.isValid, isTrue);
        expect(formKey.currentState!.validate(), isTrue);

        // 13 digits (maxLength 13) -> valid!
        await tester.enterText(find.byType(TextField), '1234567890123');
        await tester.pumpAndSettle();
        expect(controller.isValid, isTrue);
        expect(formKey.currentState!.validate(), isTrue);

        // Input formatter clamps input to maxLength (13 digits)
        await tester.enterText(find.byType(TextField), '12345678901234');
        await tester.pumpAndSettle();
        expect(controller.nationalNumber.length, 13);
        expect(controller.isValid, isTrue);

        // If directly assigned an out-of-range value (> 13 digits), isValid is false
        controller.value = PhoneNumberValue.parse(
          country: Country.austria,
          nationalNumber: '12345678901234',
        );
        expect(controller.isValid, isFalse);
        expect(formKey.currentState!.validate(), isFalse);
      },
    );
  });
}
