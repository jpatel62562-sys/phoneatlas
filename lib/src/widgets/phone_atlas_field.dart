import 'package:flutter/material.dart';

import '../formatters/phone_input_formatter.dart';
import '../models/country.dart';
import '../models/phone_number_value.dart';
import 'country_picker.dart';
import 'phone_atlas_controller.dart';

/// Presentation mode for the country picker.
enum CountryPickerMode {
  /// Opens a modal bottom sheet.
  bottomSheet,

  /// Opens an alert dialog.
  dialog,
}

/// A production-quality international phone number input field with country selection,
/// Unicode flags, dial codes, real-time formatting, and libphonenumber-based validation.
class PhoneAtlasField extends FormField<PhoneNumberValue> {
  /// The controller that coordinates phone number value, country, and validation.
  final PhoneAtlasController? controller;

  /// The initial country selected if no controller or initialValue is provided.
  final Country? initialCountry;

  /// Callback invoked whenever the parsed [PhoneNumberValue] changes.
  final ValueChanged<PhoneNumberValue>? onChanged;

  /// Callback invoked specifically when the country is changed.
  final ValueChanged<Country>? onCountryChanged;

  /// Focus node for the phone number text input.
  final FocusNode? focusNode;

  /// Input decoration applied to the phone text field.
  final InputDecoration? decoration;

  /// Text style for the phone number input.
  final TextStyle? style;

  /// Keyboard type for the input field. Defaults to [TextInputType.phone].
  final TextInputType keyboardType;

  /// Action button for the software keyboard. Defaults to [TextInputAction.done].
  final TextInputAction? textInputAction;

  /// Whether real-time formatting is enabled. Defaults to `true`.
  final bool enableFormatting;

  /// Presentation mode for the country picker (bottom sheet or dialog).
  final CountryPickerMode pickerMode;

  /// Custom theme settings for the country picker sheet/dialog.
  final CountryPickerThemeData? countryPickerTheme;

  /// Filtered or custom list of countries to show in the picker. Defaults to all.
  final List<Country>? countries;

  /// Whether to display the country flag emoji in the prefix button.
  final bool showFlag;

  /// Whether to display the country name in the prefix button.
  final bool showCountryName;

  /// Whether to display the ISO alpha-2 country code in the prefix button.
  final bool showIsoCode;

  /// Whether to display the international dial code in the prefix button.
  final bool showDialCode;

  /// Whether to display the dropdown indicator icon next to the dial code.
  final bool showDropdownIcon;

  /// Flag emoji font size in the prefix selector.
  final double flagSize;

  /// Text style for the dial code in the selector.
  final TextStyle? dialCodeStyle;

  /// Whether the field is read-only.
  final bool readOnly;

  /// Whether to validate the phone number against country-specific metadata rules.
  ///
  /// When `true` (default), the input is validated against international phone
  /// number metadata for the selected country, showing validation errors when invalid.
  ///
  /// When `false`, the field acts as a normal phone/text input: no phone-number
  /// validation is performed, no validation errors are displayed, and libphonenumber
  /// validation logic is bypassed while keeping the selected country's dial code,
  /// flag, and input limits intact.
  final bool isValidate;

  /// Creates a [PhoneAtlasField].
  PhoneAtlasField({
    super.key,
    this.controller,
    this.initialCountry,
    PhoneNumberValue? initialValue,
    this.isValidate = true,
    this.onChanged,
    this.onCountryChanged,
    this.focusNode,
    this.decoration,
    this.style,
    this.keyboardType = TextInputType.phone,
    this.textInputAction,
    this.enableFormatting = true,
    this.pickerMode = CountryPickerMode.bottomSheet,
    this.countryPickerTheme,
    this.countries,
    this.showFlag = true,
    this.showCountryName = false,
    this.showIsoCode = false,
    this.showDialCode = true,
    this.showDropdownIcon = true,
    this.flagSize = 20.0,
    this.dialCodeStyle,
    super.enabled = true,
    this.readOnly = false,
    super.autovalidateMode,
    FormFieldValidator<PhoneNumberValue>? validator,
    super.onSaved,
  }) : super(
         validator: isValidate
             ? (validator ??
                   (value) {
                     if (value != null && value.isNotEmpty && !value.isValid) {
                       return 'Please enter a valid phone number for ${value.country.name}';
                     }
                     return null;
                   })
             : null,
         initialValue:
             controller?.value ??
             initialValue ??
             (isValidate
                 ? PhoneNumberValue.empty(
                     initialCountry ?? Country.unitedStates,
                   )
                 : PhoneNumberValue.unvalidated(
                     country: initialCountry ?? Country.unitedStates,
                     nationalNumber: '',
                   )),
         builder: (field) {
           final state = field as _PhoneAtlasFieldState;
           return state.buildField();
         },
       );

  @override
  FormFieldState<PhoneNumberValue> createState() => _PhoneAtlasFieldState();
}

class _PhoneAtlasFieldState extends FormFieldState<PhoneNumberValue> {
  PhoneAtlasController? _internalController;
  late TextEditingController _textController;
  late PhoneInputFormatter _formatter;
  FocusNode? _internalFocusNode;

  PhoneAtlasField get _field => widget as PhoneAtlasField;

  PhoneAtlasController get _effectiveController =>
      _field.controller ?? _internalController!;

  FocusNode get _effectiveFocusNode => _field.focusNode ?? _internalFocusNode!;

  @override
  void initState() {
    super.initState();
    if (_field.controller == null) {
      _internalController = PhoneAtlasController(value);
    }
    if (_field.focusNode == null) {
      _internalFocusNode = FocusNode();
    }

    final initialCountry = _effectiveController.country;
    final initialDigits = _effectiveController.nationalNumber;

    if (_field.isValidate) {
      if (initialDigits.isNotEmpty) {
        final reevaluated = PhoneNumberValue.parse(
          country: initialCountry,
          nationalNumber: initialDigits,
        );
        if (_effectiveController.value != reevaluated) {
          _effectiveController.value = reevaluated;
        }
      }
    } else {
      if (!_effectiveController.isValid) {
        _effectiveController.value = PhoneNumberValue.unvalidated(
          country: initialCountry,
          nationalNumber: initialDigits,
        );
      }
    }

    _formatter = PhoneInputFormatter(
      country: initialCountry,
      enableFormatting: _field.enableFormatting,
      isValidate: _field.isValidate,
    );

    final initialFormatted = initialDigits.isNotEmpty
        ? PhoneInputFormatter.formatNationalNumber(
            initialCountry,
            initialDigits,
          )
        : '';

    _textController = TextEditingController(text: initialFormatted);

    _effectiveController.addListener(_handleControllerChanged);
    _textController.addListener(_handleTextControllerChanged);
  }

  @override
  void didUpdateWidget(PhoneAtlasField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_field.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_handleControllerChanged);
      if (_field.controller == null) {
        _internalController = PhoneAtlasController(value);
      } else {
        _internalController?.dispose();
        _internalController = null;
      }
      _effectiveController.addListener(_handleControllerChanged);
    }

    if (_field.enableFormatting != oldWidget.enableFormatting ||
        _field.isValidate != oldWidget.isValidate) {
      _formatter = PhoneInputFormatter(
        country: _effectiveController.country,
        enableFormatting: _field.enableFormatting,
        isValidate: _field.isValidate,
      );
    }

    if (_field.isValidate != oldWidget.isValidate) {
      final currentDigits = _effectiveController.nationalNumber;
      final currentCountry = _effectiveController.country;
      final updated = _field.isValidate
          ? PhoneNumberValue.parse(
              country: currentCountry,
              nationalNumber: currentDigits,
            )
          : PhoneNumberValue.unvalidated(
              country: currentCountry,
              nationalNumber: currentDigits,
              formattedNationalNumber: _field.enableFormatting
                  ? PhoneInputFormatter.formatNationalNumber(
                      currentCountry,
                      currentDigits,
                    )
                  : currentDigits,
            );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _effectiveController.value = updated;
        didChange(updated);
        _field.onChanged?.call(updated);
      });
    }
  }

  @override
  void dispose() {
    _effectiveController.removeListener(_handleControllerChanged);
    _textController.removeListener(_handleTextControllerChanged);
    _textController.dispose();
    _internalController?.dispose();
    _internalFocusNode?.dispose();
    super.dispose();
  }

  @override
  void reset() {
    super.reset();
    final initial =
        widget.initialValue ??
        (_field.isValidate
            ? PhoneNumberValue.empty(
                _field.initialCountry ?? Country.unitedStates,
              )
            : PhoneNumberValue.unvalidated(
                country: _field.initialCountry ?? Country.unitedStates,
                nationalNumber: '',
              ));
    _effectiveController.value = initial;
    _formatter.country = initial.country;
    _textController.text =
        initial.formattedNationalNumber ?? initial.nationalNumber;
  }

  void _handleControllerChanged() {
    var currentPhone = _effectiveController.value;
    if (!_field.isValidate && !currentPhone.isValid) {
      currentPhone = PhoneNumberValue.unvalidated(
        country: currentPhone.country,
        nationalNumber: currentPhone.nationalNumber,
      );
      _effectiveController.value = currentPhone;
    }
    if (value != currentPhone) {
      didChange(currentPhone);
    }

    // Synchronize formatter country
    final countryChanged = _formatter.country != currentPhone.country;
    if (countryChanged) {
      _formatter.country = currentPhone.country;
    }

    // Synchronize text field text if changed externally
    final cleanCurrentText = _textController.text.replaceAll(
      RegExp(r'[^\d]'),
      '',
    );
    if (countryChanged || cleanCurrentText != currentPhone.nationalNumber) {
      final formatted = _field.enableFormatting
          ? PhoneInputFormatter.formatNationalNumber(
              currentPhone.country,
              currentPhone.nationalNumber,
            )
          : currentPhone.nationalNumber;
      _textController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  void _handleTextControllerChanged() {
    final rawDigits = PhoneNumberValue.extractNationalDigits(
      _effectiveController.country,
      _textController.text,
    );
    if (rawDigits != _effectiveController.nationalNumber) {
      final updated = _field.isValidate
          ? PhoneNumberValue.parse(
              country: _effectiveController.country,
              nationalNumber: rawDigits,
            )
          : PhoneNumberValue.unvalidated(
              country: _effectiveController.country,
              nationalNumber: rawDigits,
              formattedNationalNumber: _field.enableFormatting
                  ? PhoneInputFormatter.formatNationalNumber(
                      _effectiveController.country,
                      rawDigits,
                    )
                  : rawDigits,
            );
      _effectiveController.value = updated;
      didChange(updated);
      _field.onChanged?.call(updated);
    }
  }

  Future<void> _pickCountry() async {
    if (!_field.enabled || _field.readOnly) return;

    final selected = _effectiveController.country;
    Country? picked;

    if (_field.pickerMode == CountryPickerMode.dialog) {
      picked = await showCountryPickerDialog(
        context,
        selectedCountry: selected,
        countries: _field.countries,
        themeData: _field.countryPickerTheme,
      );
    } else {
      picked = await showCountryPickerSheet(
        context,
        selectedCountry: selected,
        countries: _field.countries,
        themeData: _field.countryPickerTheme,
      );
    }

    if (picked != null && picked != selected) {
      _onCountrySelected(picked);
    }
  }

  void _onCountrySelected(Country newCountry) {
    _formatter.country = newCountry;

    // Retain existing digits without silent truncation and re-validate under new country rules
    final existingDigits = _effectiveController.nationalNumber;
    final updated = _field.isValidate
        ? PhoneNumberValue.parse(
            country: newCountry,
            nationalNumber: existingDigits,
          )
        : PhoneNumberValue.unvalidated(
            country: newCountry,
            nationalNumber: existingDigits,
            formattedNationalNumber: _field.enableFormatting
                ? PhoneInputFormatter.formatNationalNumber(
                    newCountry,
                    existingDigits,
                  )
                : existingDigits,
          );

    _effectiveController.value = updated;
    didChange(updated);

    final remappedFormatted = _field.enableFormatting
        ? PhoneInputFormatter.formatNationalNumber(newCountry, existingDigits)
        : existingDigits;

    _textController.value = TextEditingValue(
      text: remappedFormatted,
      selection: TextSelection.collapsed(offset: remappedFormatted.length),
    );

    _field.onCountryChanged?.call(newCountry);
    _field.onChanged?.call(updated);
  }

  Widget _buildCountryButton(BuildContext context) {
    final country = _effectiveController.country;
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      enabled: _field.enabled && !_field.readOnly,
      label:
          'Country selector: ${country.name}, dialing code ${country.dialCode}',
      child: InkWell(
        onTap: _pickCountry,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_field.showFlag) ...[
                Text(country.flag, style: TextStyle(fontSize: _field.flagSize)),
                const SizedBox(width: 6),
              ],
              if (_field.showCountryName) ...[
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 100),
                  child: Text(
                    country.name,
                    overflow: TextOverflow.ellipsis,
                    style:
                        _field.dialCodeStyle ??
                        theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
                const SizedBox(width: 4),
              ],
              if (_field.showDialCode) ...[
                Text(
                  country.dialCode,
                  style:
                      _field.dialCodeStyle ??
                      theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
              if (_field.showDropdownIcon) ...[
                const SizedBox(width: 2),
                Icon(
                  Icons.arrow_drop_down_rounded,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
              const SizedBox(width: 4),
              Container(
                height: 20,
                width: 1,
                color: theme.colorScheme.outlineVariant,
              ),
              const SizedBox(width: 6),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildField() {
    final theme = Theme.of(context);
    final effectiveDecoration =
        (_field.decoration ??
                const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Phone number',
                ))
            .applyDefaults(theme.inputDecorationTheme)
            .copyWith(
              prefixIcon: _buildCountryButton(context),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 0,
                minHeight: 0,
              ),
              errorText: errorText,
              enabled: _field.enabled,
            );

    return TextField(
      controller: _textController,
      focusNode: _effectiveFocusNode,
      keyboardType: _field.keyboardType,
      textInputAction: _field.textInputAction,
      style: _field.style,
      enabled: _field.enabled,
      readOnly: _field.readOnly,
      inputFormatters: [_formatter],
      decoration: effectiveDecoration,
    );
  }
}
