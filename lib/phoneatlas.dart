/// A production-quality, lightweight Flutter package for international phone
/// number input, validation, formatting, and country selection with Unicode flag support.
///
/// To use this package, import:
/// ```dart
/// import 'package:phoneatlas/phoneatlas.dart';
/// ```
library;

export 'src/data/countries.dart' show CountriesData;
export 'src/formatters/phone_input_formatter.dart';
export 'src/models/country.dart';
export 'src/models/phone_number_value.dart';
export 'src/utils/flag_utils.dart' show FlagUtils, countryFlagFromIsoCode;
export 'src/validators/phone_validator.dart'
    show PhoneValidator, PhoneValidationError;
export 'src/widgets/country_list_tile.dart';
export 'src/widgets/country_picker.dart'
    show
        CountryPickerThemeData,
        CountryPickerContent,
        showCountryPickerSheet,
        showCountryPickerDialog;
export 'src/widgets/phone_atlas_controller.dart';
export 'src/widgets/phone_atlas_field.dart';

export 'package:phone_numbers_parser/phone_numbers_parser.dart'
    show PhoneNumberType;
