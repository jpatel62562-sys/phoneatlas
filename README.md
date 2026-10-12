# PhoneAtlas

A production-quality, lightweight Flutter package for international phone number input, country selection, Unicode flags, as-you-type formatting, and metadata-driven phone number validation powered by the Google libphonenumber ecosystem.

[![pub package](https://img.shields.io/pub/v/phoneatlas.svg)](https://pub.dev/packages/phoneatlas)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-%3E%3D3.16.0-02569B.svg?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-%5E3.13.1-0175C2.svg?logo=dart)](https://dart.dev)

---

## Features

- 🌍 **245+ Countries & Territories**: Comprehensive coverage with ISO 3166-1 alpha-2 codes, international dial codes, and canonical English names.
- 🇮🇳 **Zero-Asset Unicode Flag Emojis**: Lightweight flags generated dynamically from regional indicator symbols without bundled asset bloat.
- 🔝 **Smart Country Picker**: Modal bottom sheet and center dialog with instant fuzzy search (name, ISO code, dial code). The currently selected country is automatically pinned to the top with a distinct border, background, and checkmark.
- 📱 **As-You-Type National Formatting**: Automatically formats phone numbers according to national standards while preserving cursor position.
- 🛡️ **Authoritative Validation**: Validates National Significant Number (NSN) lengths and patterns backed by Google's libphonenumber ecosystem. Accurately validates fixed-length and variable-length mobile numbers (e.g., Austria, Germany).
- ⚙️ **Dual-Mode Validation (`isValidate`)**:
  - `isValidate: true` (default): Strictly enforces phone number length and format rules, providing inline form error feedback.
  - `isValidate: false`: Functions as an open phone/text field without validation errors while retaining flag, dial code, and country picker features.
- 📋 **Seamless Flutter `Form` Integration**: Extends `FormField<PhoneNumberValue>` with built-in support for `validate()`, `reset()`, `onSaved`, and custom validators.
- 🎮 **Two-Way Controller**: `PhoneAtlasController` provides complete programmatic control to inspect, update, reset, or set raw E.164 strings.
- ♿ **Responsive & Accessible**: Native Material 3 theming (light & dark mode), adaptive `LayoutBuilder` sizing for compact and large screens, and semantic screen reader labels.

---

## Architecture & Flow

```text
┌────────────────────────────────────────────────────────┐
│                   PhoneAtlasField                      │
├─────────────────────┬──────────────────────────────────┤
│ 🇮🇳 +91 ▼            │ 98765 43210                      │
│ Flag & Prefix Button│ As-You-Type National Formatting  │
└──────────┬──────────┴─────────────────┬────────────────┘
           │ (tap)                      │ (input)
           ▼                            ▼
┌─────────────────────────┐  ┌───────────────────────────┐
│  Smart Country Picker   │  │   libphonenumber Rules    │
│  - Selected pinned top  │  │   - Valid NSN length      │
│  - Instant fuzzy search │  │   - Mobile prefix checks  │
│  - Responsive sheet/dlg │  └─────────────┬─────────────┘
└─────────────────────────┘                │
                                           ▼
                             ┌───────────────────────────┐
                             │    PhoneNumberValue       │
                             │    - country: India       │
                             │    - national: 9876543210 │
                             │    - e164: +919876543210  │
                             │    - isValid: true        │
                             └───────────────────────────┘
```

---

## Compatibility

- **Flutter**: `>= 3.16.0`
- **Dart SDK**: `^3.13.1`
- **Design System**: Material Design 3

---

## Installation

Add `phoneatlas` to your `pubspec.yaml`:

```yaml
dependencies:
  phoneatlas: ^0.1.0
```

Then import the package in your Dart code:

```dart
import 'package:phoneatlas/phoneatlas.dart';
```

---

## Usage Examples

### 1. Basic Usage

A minimal standalone phone field with default validation and country selection:

```dart
import 'package:flutter/material.dart';
import 'package:phoneatlas/phoneatlas.dart';

class BasicPhoneExample extends StatelessWidget {
  const BasicPhoneExample({super.key});

  @override
  Widget build(BuildContext context) {
    return PhoneAtlasField(
      initialCountry: Country.unitedStates,
      onChanged: (PhoneNumberValue value) {
        debugPrint('Country: ${value.country.name}');
        debugPrint('National: ${value.nationalNumber}');
        debugPrint('International E.164: ${value.internationalNumber}');
        debugPrint('Is valid: ${value.isValid}');
      },
    );
  }
}
```

---

### 2. Flutter Form Validation

Use `PhoneAtlasField` inside a Flutter `Form` to handle form submission, inline error messages, and form resets:

```dart
import 'package:flutter/material.dart';
import 'package:phoneatlas/phoneatlas.dart';

class FormValidationExample extends StatefulWidget {
  const FormValidationExample({super.key});

  @override
  State<FormValidationExample> createState() => _FormValidationExampleState();
}

class _FormValidationExampleState extends State<FormValidationExample> {
  final _formKey = GlobalKey<FormState>();
  PhoneNumberValue? _savedValue;

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved: ${_savedValue?.internationalNumber}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          PhoneAtlasField(
            initialCountry: Country.india,
            decoration: const InputDecoration(
              labelText: 'Mobile Number',
              hintText: 'Enter 10-digit number',
              border: OutlineInputBorder(),
            ),
            // Use PhoneValidator helper or a custom validator callback
            validator: PhoneValidator.valid(
              invalidMessage: 'Please enter a valid mobile number',
            ),
            onSaved: (value) {
              _savedValue = value;
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _submit,
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
```

---

### 3. Programmatic Control with `PhoneAtlasController`

Use `PhoneAtlasController` to read, modify, or reset phone field values programmatically. Always remember to dispose the controller in your State's `dispose()` method.

```dart
import 'package:flutter/material.dart';
import 'package:phoneatlas/phoneatlas.dart';

class ControllerExample extends StatefulWidget {
  const ControllerExample({super.key});

  @override
  State<ControllerExample> createState() => _ControllerExampleState();
}

class _ControllerExampleState extends State<ControllerExample> {
  late final PhoneAtlasController _controller;

  @override
  void initState() {
    super.initState();
    // Initialize with a country and optional initial digits
    _controller = PhoneAtlasController.fromCountry(Country.india, '9876543210');
  }

  @override
  void dispose() {
    // Controller must be disposed when no longer needed
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PhoneAtlasField(
          controller: _controller,
          onCountryChanged: (Country country) {
            debugPrint('Country changed to: ${country.name}');
          },
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            ElevatedButton(
              onPressed: () => _controller.setCountry(Country.unitedKingdom),
              child: const Text('Switch to UK'),
            ),
            ElevatedButton(
              onPressed: () => _controller.setRaw('+12025550123'),
              child: const Text('Set US E.164 (+12025550123)'),
            ),
            OutlinedButton(
              onPressed: () => _controller.clear(),
              child: const Text('Clear'),
            ),
          ],
        ),
      ],
    );
  }
}
```

---

### 4. Optional Phone Validation (`isValidate`)

Control validation behavior using the `isValidate` flag:

```dart
// 1. Standard Validated Mode (default: isValidate: true)
PhoneAtlasField(
  isValidate: true,
  // Enforces valid mobile length and pattern. Displays error on form validation.
)

// 2. Open / Free-Form Input Mode (isValidate: false)
PhoneAtlasField(
  isValidate: false,
  // Bypasses validation errors. Allows free-form digits while
  // keeping the country flag, dial code, and picker intact.
)
```

| Behavior | `isValidate: true` (default) | `isValidate: false` |
|---|---|---|
| **Validation Rules** | Enforces libphonenumber constraints | Bypassed |
| **Form Error Messages** | Displayed when invalid | Suppressed |
| **E.164 Output** | Formatted string when valid | Normalized string available |
| **Country Flag & Dial Code** | Fully active | Fully active |
| **As-You-Type Formatting** | Active | Active |

---

### 5. Standalone Country Picker

You can open the country picker modal directly anywhere in your application:

```dart
// Open as a Modal Bottom Sheet
final Country? pickedCountry = await showCountryPickerSheet(
  context,
  selectedCountry: Country.germany,
  themeData: const CountryPickerThemeData(
    title: 'Select Destination Country',
    showDialCode: true,
  ),
);

// Open as an Alert Dialog
final Country? dialogCountry = await showCountryPickerDialog(
  context,
  selectedCountry: Country.japan,
);
```

---

## API Reference

### `PhoneAtlasField`

| Parameter | Type | Default | Description |
|---|---|---|---|
| `controller` | `PhoneAtlasController?` | `null` | Controller for two-way programmatic manipulation. |
| `initialCountry` | `Country?` | `Country.unitedStates` | Country displayed initially if controller is unset. |
| `initialValue` | `PhoneNumberValue?` | `null` | Initial value if controller is unset. |
| `isValidate` | `bool` | `true` | Whether to validate against country metadata and display errors. |
| `onChanged` | `ValueChanged<PhoneNumberValue>?` | `null` | Callback invoked when the phone number changes. |
| `onCountryChanged` | `ValueChanged<Country>?` | `null` | Callback invoked when the selected country changes. |
| `decoration` | `InputDecoration?` | `null` | Decoration for the inner `TextField`. |
| `style` | `TextStyle?` | `null` | Text style for the input digits. |
| `enableFormatting` | `bool` | `true` | Whether to format digits according to national standards. |
| `pickerMode` | `CountryPickerMode` | `.bottomSheet` | Picker presentation mode (`.bottomSheet` or `.dialog`). |
| `countryPickerTheme` | `CountryPickerThemeData?` | `null` | Custom styling for the country picker modal. |
| `countries` | `List<Country>?` | `null` | Custom list of countries to restrict the picker to. |
| `showFlag` | `bool` | `true` | Whether to display the flag emoji in the prefix button. |
| `showCountryName` | `bool` | `false` | Whether to display the country name in the prefix button. |
| `showIsoCode` | `bool` | `false` | Whether to display the ISO alpha-2 code in the prefix button. |
| `showDialCode` | `bool` | `true` | Whether to display the dial code (e.g., `+1`) in the prefix button. |
| `showDropdownIcon` | `bool` | `true` | Whether to display the arrow drop-down icon in the prefix button. |
| `flagSize` | `double` | `20.0` | Font size of the Unicode flag emoji. |
| `dialCodeStyle` | `TextStyle?` | `null` | Custom text style for the prefix dial code. |
| `enabled` | `bool` | `true` | Whether the field is interactive. |
| `readOnly` | `bool` | `false` | Whether the text field is read-only. |
| `validator` | `FormFieldValidator<PhoneNumberValue>?` | `null` | Form field validator function. |
| `autovalidateMode` | `AutovalidateMode?` | `null` | Autovalidation mode for the form field. |
| `onSaved` | `FormFieldSetter<PhoneNumberValue>?` | `null` | Callback when enclosing `FormState.save()` is called. |

---

### `PhoneAtlasController`

| Method / Getter | Description |
|---|---|
| `PhoneAtlasController([PhoneNumberValue? value])` | Creates a controller with an optional initial value. |
| `PhoneAtlasController.fromCountry(Country country, [String nationalNumber = ''])` | Creates a controller initialized with a country and digits. |
| `value` | Current `PhoneNumberValue`. |
| `country` | Currently selected `Country`. |
| `nationalNumber` | Current national digits. |
| `dialCode` | Current country dialing code (e.g., `+91`). |
| `internationalNumber` | E.164 string when valid, or empty string. |
| `isValid` | Whether current value passes validation rules. |
| `setPhoneNumber(Country country, String nationalNumber)` | Updates both country and national number. |
| `setCountry(Country country)` | Updates country while retaining existing digits. |
| `setNationalNumber(String digits)` | Updates national digits. |
| `setRaw(String rawE164)` | Auto-detects country code and parses digits from full string. |
| `clear()` | Clears the national digits. |
| `dispose()` | Disposes internal listeners. |

---

### `PhoneNumberValue`

| Property | Type | Description |
|---|---|---|
| `country` | `Country` | The associated country model. |
| `nationalNumber` | `String` | Raw sanitized national digits (e.g., `'9876543210'`). |
| `dialCode` | `String` | International calling code prefix (e.g., `'+91'`). |
| `internationalNumber` | `String` | Formatted E.164 string when valid (e.g., `'+919876543210'`). |
| `e164` | `String?` | Standard E.164 string when valid, or `null`. |
| `formattedNationalNumber` | `String?` | National format string (e.g., `'(202) 555-0123'`). |
| `isValid` | `bool` | Whether the number satisfies libphonenumber metadata rules. |
| `lengthValid` | `bool` | Whether the number length satisfies country mobile NSN limits. |
| `validationError` | `PhoneValidationError?` | Specific validation failure error (or `null` if valid). |
| `isEmpty` / `isNotEmpty` | `bool` | Convenience state helpers. |

---

### `Country`

| Property | Type | Description |
|---|---|---|
| `name` | `String` | Canonical English country name (e.g., `'India'`). |
| `isoCode` | `String` | ISO 3166-1 alpha-2 code (e.g., `'IN'`). |
| `dialCode` | `String` | International dialing code (e.g., `'+91'`). |
| `flag` | `String` | Unicode regional indicator flag emoji (e.g., `'🇮🇳'`). |
| `minLength` | `int` | Minimum mobile national significant number (NSN) length. |
| `maxLength` | `int` | Maximum mobile national significant number (NSN) length. |

#### Helper Methods:
- `Country.all`: Full list of 245+ countries.
- `Country.fromIsoCode('IN')` / `Country.tryFromIsoCode('US')`: Lookup by ISO alpha-2.
- `Country.fromDialCode('+91')` / `Country.tryFromDialCode('+1')`: Lookup by dialing code.
- `Country.search('query')`: Fuzzy search across names, ISO codes, and dial codes.
- `Country.india`, `Country.unitedStates`, `Country.unitedKingdom`, `Country.germany`, `Country.japan`, `Country.austria`, `Country.australia`, `Country.brazil`: Built-in constants.

---

### `CountryPickerThemeData`

| Property | Type | Default | Description |
|---|---|---|---|
| `title` | `String` | `'Select Country'` | Title text at top of picker. |
| `searchHint` | `String` | `'Search country, ISO, or dial code...'` | Search field placeholder. |
| `noResultsText` | `String` | `'No countries found'` | Text when search finds no matches. |
| `showDialCode` | `bool` | `true` | Whether to display dial codes in picker tiles. |
| `showIsoCode` | `bool` | `false` | Whether to display ISO codes in picker tiles. |
| `flagSize` | `double` | `24.0` | Flag emoji font size in list tiles. |
| `backgroundColor` | `Color?` | `null` | Custom background color for the modal. |
| `borderRadius` | `BorderRadius?` | `null` | Custom border radius for the modal. |
| `searchInputBorder` | `InputBorder?` | `null` | Custom border for search field. |
| `selectedItemBackgroundColor` | `Color?` | `null` | Custom background color for pinned selected item. |
| `selectedItemBorder` | `Border?` | `null` | Custom border for pinned selected item. |

---

## Common Usage Mistakes & Troubleshooting

1. **Forgetting to dispose `PhoneAtlasController`**:
   - Always call `controller.dispose()` inside your `State.dispose()` method to prevent memory leaks.
2. **Passing both `controller` and `initialValue`**:
   - If a `controller` is provided, it serves as the single source of truth. Passing both will ignore `initialValue`.
3. **Confusing validation with carrier reachability**:
   - Metadata validation confirms that a number satisfies national numbering plan length, format, and mobile prefix specifications. It does not ping cellular towers or verify whether a SIM card is active.
4. **Expecting `internationalNumber` on invalid input**:
   - `value.internationalNumber` returns an empty string (and `value.e164` returns `null`) when the phone number is invalid. Use `value.isValid` to check validity before reading E.164 strings.

---

## Contributing & Issues

Contributions, bug reports, and suggestions are welcome!
- Please file issues and feature requests at [GitHub Issues](https://github.com/jpatel62562-sys/phoneatlas/issues).
- Pull requests should include unit or widget test coverage and pass `flutter analyze`.

---

## License

This package is licensed under the [MIT License](LICENSE).
