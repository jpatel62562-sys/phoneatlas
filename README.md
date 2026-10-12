# PhoneAtlas

A production-quality, lightweight Flutter/Dart package for international phone number input, country selection, Unicode flags, country-specific formatting, and authoritative validation powered by the Google libphonenumber ecosystem.

[![pub package](https://img.shields.io/badge/pub-0.1.0-blue.svg)](https://pub.dev)
[![license](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/flutter->=3.16.0-02569B.svg?logo=flutter)](https://flutter.dev)

---

## Features

- 🌍 **245+ Countries & Territories**: Complete ISO 3166-1 alpha-2 coverage with English canonical names and dialing codes.
- 🇮🇳 **Unicode Flag Emojis**: Lightweight, asset-free Unicode flag emojis generated dynamically from ISO country codes.
- 📱 **Real-Time As-You-Type Formatting**: Formats phone numbers smoothly in local national format while accurately preserving the cursor position.
- 🛡️ **Authoritative Validation**: Backed by Google libphonenumber metadata rather than arbitrary length heuristics. Correctly handles variable-length countries (e.g. Germany) and mobile prefix rules.
- 🌐 **E.164 & International Output**: Exposes verified E.164 international phone number strings (e.g. `+919876543210`) only when valid.
- 📋 **Seamless Flutter Form Integration**: First-class `FormField<PhoneNumberValue>` support with `validate()`, `reset()`, and customizable error messaging.
- 🔍 **Performant Country Picker**: Modal bottom sheet and dialog with instant fuzzy search (by name, ISO code, or dial code) powered by lazy `ListView.builder` rendering.
- 🎮 **Lightweight Controller**: `PhoneAtlasController` for two-way programmatic control, clearing, setting raw numbers, or listening to updates.
- ♿ **Accessibility & Theming**: Native Material 3 styling, full Dark/Light theme support, and accessible semantics with adequate tap targets (>= 48dp).
- 🛠️ **Reproducible Metadata**: Deterministic generator script (`tool/generate_phone_metadata.dart`) for easy ongoing metadata maintenance.

---

## Core Concept & Flow

```text
🌍 Country Selection
         ↓
🇮🇳 Unicode Flag Emoji
         ↓
+91 International Dial Code
         ↓
📱 Phone Input Field
         ↓
Country-Specific As-You-Type Formatting  (e.g., 98765 43210)
         ↓
Google libphonenumber Metadata Validation
         ↓
Validated E.164 Output                   (e.g., +919876543210)
```

---

## Installation

Add `phoneatlas` to your `pubspec.yaml`:

```yaml
dependencies:
  phoneatlas: ^0.1.0
```

Import it in your Dart code:

```dart
import 'package:phoneatlas/phoneatlas.dart';
```

---

## Quick Start

### Basic Usage

```dart
import 'package:flutter/material.dart';
import 'package:phoneatlas/phoneatlas.dart';

class SimplePhoneExample extends StatelessWidget {
  const SimplePhoneExample({super.key});

  @override
  Widget build(BuildContext context) {
    return PhoneAtlasField(
      initialCountry: Country.india,
      onChanged: (phone) {
        debugPrint('Country: ${phone.country.name}');
        debugPrint('Flag: ${phone.country.flag}');
        debugPrint('Dial code: ${phone.dialCode}');
        debugPrint('National: ${phone.nationalNumber}');
        debugPrint('International: ${phone.internationalNumber}');
        debugPrint('Valid: ${phone.isValid}');
      },
    );
  }
}
```

### Optional Phone Validation (`isValidate`)

Validation can be toggled on or off using `isValidate`:

```dart
// Standard validated phone input (default)
PhoneAtlasField(
  isValidate: true,
  ...
);

// Normal phone/text input without validation errors
PhoneAtlasField(
  isValidate: false,
  ...
);
```

* **When `isValidate: true` (default)**: Uses country-specific phone metadata, applies validation rules, and displays validation errors if the number is invalid.
* **When `isValidate: false`**: Bypasses phone validation rules and suppresses validation errors, while keeping the country selector, flag, dial code, and input length limits intact.

---

## Flutter Form Integration

`PhoneAtlasField` extends Flutter's `FormField<PhoneNumberValue>`, providing complete integration with `FormState`:

```dart
final formKey = GlobalKey<FormState>();

Form(
  key: formKey,
  child: Column(
    children: [
      PhoneAtlasField(
        initialCountry: Country.unitedStates,
        decoration: const InputDecoration(
          labelText: 'Phone Number',
          border: OutlineInputBorder(),
        ),
        validator: PhoneValidator.valid(
          invalidMessage: 'Please enter a valid phone number',
        ),
        onSaved: (phone) {
          debugPrint('Saved: ${phone?.internationalNumber}');
        },
      ),
      const SizedBox(height: 16),
      ElevatedButton(
        onPressed: () {
          if (formKey.currentState!.validate()) {
            formKey.currentState!.save();
          }
        },
        child: const Text('Submit'),
      ),
    ],
  ),
)
```

---

## Programmatic Control with `PhoneAtlasController`

Use `PhoneAtlasController` to read, update, or clear the phone value programmatically:

```dart
final controller = PhoneAtlasController.fromCountry(
  Country.india,
  '9876543210',
);

// Listen to value updates
controller.addListener(() {
  final current = controller.value;
  debugPrint('E.164: ${current.internationalNumber}, Valid: ${current.isValid}');
});

// Programmatically switch country
controller.setCountry(Country.unitedStates);

// Programmatically set national digits
controller.setNationalNumber('2025550123');

// Auto-detect country from full international raw string
controller.setRaw('+447400123456');

// Clear the input
controller.clear();
```

---

## Standalone Country Pickers

You can invoke the country picker modal bottom sheet or dialog anywhere in your application:

```dart
// 1. Bottom Sheet
final country = await showCountryPickerSheet(
  context,
  selectedCountry: Country.india,
  themeData: const CountryPickerThemeData(
    title: 'Select Your Country',
    showDialCode: true,
  ),
);

// 2. Alert Dialog
final countryDialog = await showCountryPickerDialog(
  context,
  selectedCountry: Country.unitedStates,
);
```

---

## Models & APIs

### `Country`

| Property | Type | Description |
|---|---|---|
| `name` | `String` | Canonical English country name (e.g., `'India'`) |
| `isoCode` | `String` | Two-letter ISO 3166-1 alpha-2 code (e.g., `'IN'`) |
| `dialCode` | `String` | International dialing code (e.g., `'+91'`) |
| `flag` | `String` | Regional indicator Unicode emoji (e.g., `'🇮🇳'`) |
| `minLength` | `int` | Minimum possible national length for the country |
| `maxLength` | `int` | Maximum possible national length for the country |

Convenience getters & helpers:
- `Country.all`: Complete list of 245+ countries.
- `Country.india`, `Country.unitedStates`, `Country.unitedKingdom`, `Country.germany`, `Country.japan`, etc.
- `Country.fromIsoCode('IN')` / `Country.tryFromIsoCode('US')`
- `Country.fromDialCode('+91')` / `Country.tryFromDialCode('+1')`
- `Country.search('query')`

### `PhoneNumberValue`

| Property | Type | Description |
|---|---|---|
| `country` | `Country` | Selected country model |
| `nationalNumber` | `String` | Sanitized national digits (e.g., `'9876543210'`) |
| `dialCode` | `String` | Dialing code prefix (e.g., `'+91'`) |
| `internationalNumber` | `String` | Normalized E.164 string if valid (e.g., `'+919876543210'`), empty if invalid |
| `e164` | `String?` | E.164 string when valid, or `null` if invalid |
| `formattedNationalNumber`| `String?` | National formatting (e.g., `'(202) 555-0123'`, `'98765 43210'`) |
| `isValid` | `bool` | Whether the number is valid according to libphonenumber rules |
| `isEmpty` / `isNotEmpty` | `bool` | Convenience state getters |

---

## Phone Number Metadata & Generation

PhoneAtlas relies on authoritative metadata from Google's [libphonenumber](https://github.com/google/libphonenumber) project. Validation and formatting rules are not hand-crafted or AI-generated.

### Updating Metadata

To regenerate the country metadata deterministically:

```bash
dart run tool/generate_phone_metadata.dart
```

This updates `lib/src/data/countries.dart` with the latest ISO specifications, dialing codes, and min/max length parameters.

---

## Running the Example App

The package includes a comprehensive showcase application in `example/`:

```bash
cd example
flutter run
```

Features demonstrated:
- Form field with validation and submission.
- Real-time parsed value inspector.
- Programmatic controller manipulation.
- Custom field styling with pill shapes and filled decorations.
- Standalone bottom sheet and dialog pickers.
- Dark mode toggle.

---

## Testing

Run the test suite with:

```bash
flutter test
```

The test suite covers:
- Country lookup and case-insensitive resolution.
- Dynamic flag generation from ISO codes.
- Real-time phone formatting and cursor position integrity.
- Validation across diverse international patterns (India, US, UK, Germany, Brazil).
- Flutter Form validation, submission, and reset.
- Controller synchronization and country switching.
- Country picker search and lazy scrolling.

---

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
