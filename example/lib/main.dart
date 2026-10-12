import 'package:flutter/material.dart';
import 'package:phoneatlas/phoneatlas.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PhoneAtlasExampleApp());
}

/// Root widget for the PhoneAtlas example application.
class PhoneAtlasExampleApp extends StatefulWidget {
  const PhoneAtlasExampleApp({super.key});

  @override
  State<PhoneAtlasExampleApp> createState() => _PhoneAtlasExampleAppState();
}

class _PhoneAtlasExampleAppState extends State<PhoneAtlasExampleApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PhoneAtlas Showcase',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF2563EB),
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF2563EB),
        brightness: Brightness.dark,
      ),
      home: PhoneAtlasShowcasePage(
        onToggleTheme: _toggleTheme,
        isDarkMode: _themeMode == ThemeMode.dark,
      ),
    );
  }
}

/// Main showcase page demonstrating PhoneAtlas capabilities.
class PhoneAtlasShowcasePage extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const PhoneAtlasShowcasePage({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<PhoneAtlasShowcasePage> createState() => _PhoneAtlasShowcasePageState();
}

class _PhoneAtlasShowcasePageState extends State<PhoneAtlasShowcasePage> {
  final _formKey = GlobalKey<FormState>();
  late final PhoneAtlasController _controller;
  PhoneNumberValue? _currentValue;
  Country? _standalonePickedCountry;
  String? _submittedNumber;
  bool _isValidate = true;
  CountryPickerMode _pickerMode = CountryPickerMode.bottomSheet;

  @override
  void initState() {
    super.initState();
    _controller = PhoneAtlasController.fromCountry(Country.india, '9876543210');
    _currentValue = _controller.value;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onCountryChipTapped(Country country) {
    _controller.setCountry(country);
    setState(() {
      _currentValue = _controller.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PhoneAtlas Showcase'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Toggle Theme',
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isLarge = constraints.maxWidth >= 720;
          final horizontalPadding = isLarge ? 32.0 : 16.0;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 20,
                ),
                children: [
                  // Header Banner
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withValues(
                        alpha: 0.35,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text('🌍', style: TextStyle(fontSize: 40)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PhoneAtlas Flutter Package',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Production-ready international phone field, country picker with pinned selection, and libphonenumber metadata validation.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Mode Configuration Card
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Configuration Options',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Validation Active (`isValidate`)'),
                            subtitle: Text(
                              _isValidate
                                  ? 'Strict validation against country phone metadata'
                                  : 'Free-form mode: no validation errors, keeping flags & prefixes',
                            ),
                            value: _isValidate,
                            onChanged: (val) {
                              setState(() {
                                _isValidate = val;
                              });
                            },
                          ),
                          const Divider(),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Country Picker Mode'),
                            subtitle: Text(
                              _pickerMode == CountryPickerMode.bottomSheet
                                  ? 'Modal Bottom Sheet (default)'
                                  : 'Center Alert Dialog',
                            ),
                            trailing: SegmentedButton<CountryPickerMode>(
                              segments: const [
                                ButtonSegment(
                                  value: CountryPickerMode.bottomSheet,
                                  label: Text('Sheet'),
                                  icon: Icon(Icons.vertical_align_bottom),
                                ),
                                ButtonSegment(
                                  value: CountryPickerMode.dialog,
                                  label: Text('Dialog'),
                                  icon: Icon(Icons.picture_in_picture_rounded),
                                ),
                              ],
                              selected: {_pickerMode},
                              onSelectionChanged: (selected) {
                                setState(() {
                                  _pickerMode = selected.first;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Section 1: Form Field Demo
                  Text(
                    '1. Interactive PhoneAtlasField Demo',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        PhoneAtlasField(
                          controller: _controller,
                          isValidate: _isValidate,
                          pickerMode: _pickerMode,
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            hintText: 'Enter mobile number',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.25),
                          ),
                          validator: _isValidate
                              ? PhoneValidator.valid(
                                  invalidMessage:
                                      'Please enter a valid phone number',
                                )
                              : null,
                          onChanged: (phone) {
                            setState(() {
                              _currentValue = phone;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            FilledButton.icon(
                              icon: const Icon(Icons.check_circle_outline),
                              label: const Text('Validate & Submit'),
                              onPressed: () {
                                final isValid =
                                    _formKey.currentState?.validate() ?? false;
                                if (isValid) {
                                  setState(() {
                                    _submittedNumber =
                                        _controller.internationalNumber.isNotEmpty
                                            ? _controller.internationalNumber
                                            : _controller.nationalNumber;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Valid! Submitted: $_submittedNumber',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Form contains validation errors.',
                                      ),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                }
                              },
                            ),
                            OutlinedButton.icon(
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Reset Form'),
                              onPressed: () {
                                _formKey.currentState?.reset();
                                setState(() {
                                  _submittedNumber = null;
                                  _currentValue = _controller.value;
                                });
                              },
                            ),
                            OutlinedButton.icon(
                              icon: const Icon(Icons.clear_all_rounded),
                              label: const Text('Clear Digits'),
                              onPressed: () {
                                _controller.clear();
                                setState(() {
                                  _currentValue = _controller.value;
                                  _submittedNumber = null;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Quick Country Switching
                  Text(
                    '2. Quick Country Switching',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap a country to programmatically switch prefix, flag, and validation rules:',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildCountryChip(Country.india),
                      _buildCountryChip(Country.unitedStates),
                      _buildCountryChip(Country.unitedKingdom),
                      _buildCountryChip(Country.germany),
                      _buildCountryChip(Country.japan),
                      _buildCountryChip(Country.austria),
                      _buildCountryChip(Country.australia),
                      _buildCountryChip(Country.brazil),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Live Parsed Value Inspector Card
                  if (_currentValue != null) ...[
                    Text(
                      '3. Live Parsed Value Inspector',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: colorScheme.outlineVariant.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildInspectorRow(
                              'Country Name',
                              '${_currentValue!.country.flag} ${_currentValue!.country.name}',
                            ),
                            const Divider(),
                            _buildInspectorRow(
                              'ISO Alpha-2 Code',
                              _currentValue!.country.isoCode,
                            ),
                            const Divider(),
                            _buildInspectorRow(
                              'Dialing Code',
                              _currentValue!.dialCode,
                            ),
                            const Divider(),
                            _buildInspectorRow(
                              'Raw National Digits',
                              _currentValue!.nationalNumber.isEmpty
                                  ? '(empty)'
                                  : _currentValue!.nationalNumber,
                            ),
                            const Divider(),
                            _buildInspectorRow(
                              'Formatted National',
                              _currentValue!.formattedNationalNumber ?? '(none)',
                            ),
                            const Divider(),
                            _buildInspectorRow(
                              'International / E.164',
                              _currentValue!.internationalNumber.isEmpty
                                  ? '(none)'
                                  : _currentValue!.internationalNumber,
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Validation State',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                Chip(
                                  avatar: Icon(
                                    !_isValidate
                                        ? Icons.info_outline
                                        : _currentValue!.isValid
                                            ? Icons.check_circle_rounded
                                            : Icons.error_outline_rounded,
                                    color: !_isValidate
                                        ? Colors.orange
                                        : _currentValue!.isValid
                                            ? Colors.green
                                            : Colors.red,
                                    size: 18,
                                  ),
                                  label: Text(
                                    !_isValidate
                                        ? 'Bypassed (isValidate: false)'
                                        : _currentValue!.isValid
                                            ? 'Valid Number'
                                            : 'Invalid Length / Format',
                                    style: TextStyle(
                                      color: !_isValidate
                                          ? Colors.orange
                                          : _currentValue!.isValid
                                              ? Colors.green
                                              : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  backgroundColor: (!_isValidate
                                          ? Colors.orange
                                          : _currentValue!.isValid
                                              ? Colors.green
                                              : Colors.red)
                                      .withValues(alpha: 0.1),
                                  side: BorderSide.none,
                                ),
                              ],
                            ),
                            if (_submittedNumber != null) ...[
                              const Divider(),
                              _buildInspectorRow(
                                'Last Submitted Value',
                                _submittedNumber!,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Section 4: Standalone Country Pickers
                  Text(
                    '4. Standalone Country Picker Pickers',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Open the country picker modal directly anywhere in your app:',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.view_agenda_outlined),
                        label: const Text('Open Bottom Sheet'),
                        onPressed: () async {
                          final country = await showCountryPickerSheet(
                            context,
                            selectedCountry:
                                _standalonePickedCountry ??
                                _controller.country,
                          );
                          if (country != null) {
                            setState(() {
                              _standalonePickedCountry = country;
                            });
                          }
                        },
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.picture_in_picture_outlined),
                        label: const Text('Open Dialog'),
                        onPressed: () async {
                          final country = await showCountryPickerDialog(
                            context,
                            selectedCountry:
                                _standalonePickedCountry ??
                                _controller.country,
                          );
                          if (country != null) {
                            setState(() {
                              _standalonePickedCountry = country;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  if (_standalonePickedCountry != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Standalone Picked: ${_standalonePickedCountry!.flag} ${_standalonePickedCountry!.name} (${_standalonePickedCountry!.dialCode})',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCountryChip(Country country) {
    final isSelected = _controller.country.isoCode == country.isoCode;
    return FilterChip(
      avatar: Text(country.flag),
      label: Text('${country.name} (${country.dialCode})'),
      selected: isSelected,
      onSelected: (_) => _onCountryChipTapped(country),
    );
  }

  Widget _buildInspectorRow(String label, String value) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
