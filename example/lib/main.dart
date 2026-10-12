import 'package:flutter/material.dart';
import 'package:phoneatlas/phoneatlas.dart';

void main() {
  runApp(const PhoneAtlasExampleApp());
}

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
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
      ),
      home: PhoneAtlasShowcasePage(
        onToggleTheme: _toggleTheme,
        isDarkMode: _themeMode == ThemeMode.dark,
      ),
    );
  }
}

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PhoneAtlas Showcase'),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Toggle Theme',
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Header
              Card(
                elevation: 0,
                color: colorScheme.primaryContainer.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text('🌍', style: TextStyle(fontSize: 36)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PhoneAtlas',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Production-grade international phone input, formatting, and validation.',
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
              ),

              const SizedBox(height: 24),

              // Section 1: Standard Form Field
              Text(
                '1. Form Field & Controller Integration',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PhoneAtlasField(
                      controller: _controller,

                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        hintText: 'Enter phone number',
                        border: OutlineInputBorder(),
                      ),
                      validator: PhoneValidator.valid(
                        invalidMessage: 'Please enter a valid phone number',
                      ),
                      onChanged: (phone) {
                        setState(() {
                          _currentValue = phone;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        FilledButton.icon(
                          icon: const Icon(Icons.check_rounded),
                          label: const Text('Validate & Submit'),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                _submittedNumber =
                                    _controller.internationalNumber;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Submitted: ${_controller.internationalNumber}',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () {
                            _formKey.currentState!.reset();
                            _controller.clear();
                            setState(() {
                              _submittedNumber = null;
                            });
                          },
                          child: const Text('Reset'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Live Inspector Card
              if (_currentValue != null) ...[
                Text(
                  'Live Parsed Value Inspector',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildInspectorRow(
                          'Country',
                          '${_currentValue!.country.flag} ${_currentValue!.country.name} (${_currentValue!.country.isoCode})',
                        ),
                        const Divider(),
                        _buildInspectorRow(
                          'Dial Code',
                          _currentValue!.dialCode,
                        ),
                        const Divider(),
                        _buildInspectorRow(
                          'National Number',
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
                              'Validation Status',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Chip(
                              avatar: Icon(
                                _currentValue!.isValid
                                    ? Icons.check_circle_rounded
                                    : Icons.error_outline_rounded,
                                color: _currentValue!.isValid
                                    ? Colors.green
                                    : Colors.red,
                                size: 18,
                              ),
                              label: Text(
                                _currentValue!.isValid ? 'Valid' : 'Invalid',
                                style: TextStyle(
                                  color: _currentValue!.isValid
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor: _currentValue!.isValid
                                  ? Colors.green.withValues(alpha: 0.1)
                                  : Colors.red.withValues(alpha: 0.1),
                              side: BorderSide.none,
                            ),
                          ],
                        ),
                        if (_submittedNumber != null) ...[
                          const Divider(),
                          _buildInspectorRow(
                            'Last Submitted',
                            _submittedNumber!,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Section 2: Programmatic Quick Actions
              Text(
                '2. Programmatic Controller Actions',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ActionChip(
                    avatar: const Text('🇺🇸'),
                    label: const Text('Switch to US'),
                    onPressed: () =>
                        _controller.setCountry(Country.unitedStates),
                  ),
                  ActionChip(
                    avatar: const Text('🇬🇧'),
                    label: const Text('Switch to UK'),
                    onPressed: () =>
                        _controller.setCountry(Country.unitedKingdom),
                  ),
                  ActionChip(
                    avatar: const Text('🇩🇪'),
                    label: const Text('Switch to Germany'),
                    onPressed: () => _controller.setCountry(Country.germany),
                  ),
                  ActionChip(
                    avatar: const Text('🇯🇵'),
                    label: const Text('Switch to Japan'),
                    onPressed: () => _controller.setCountry(Country.japan),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.paste_rounded, size: 16),
                    label: const Text('Set Raw E.164 (+12025550123)'),
                    onPressed: () => _controller.setRaw('+12025550123'),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.clear_all_rounded, size: 16),
                    label: const Text('Clear Number'),
                    onPressed: () => _controller.clear(),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Section 3: Custom Styling
              Text(
                '3. Custom Visual Styling & Dialog Mode',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              PhoneAtlasField(
                initialCountry: Country.unitedKingdom,
                pickerMode: CountryPickerMode.dialog,
                showCountryName: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.4,
                  ),
                  hintText: 'Custom rounded filled field',
                  labelText: 'UK Phone',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Section 4: Standalone Country Pickers
              Text(
                '4. Standalone Country Picker Sheet & Dialog',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.view_agenda_rounded),
                    label: const Text('Open Bottom Sheet'),
                    onPressed: () async {
                      final country = await showCountryPickerSheet(
                        context,
                        selectedCountry: _standalonePickedCountry,
                      );
                      if (country != null) {
                        setState(() {
                          _standalonePickedCountry = country;
                        });
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.picture_in_picture_rounded),
                    label: const Text('Open Dialog'),
                    onPressed: () async {
                      final country = await showCountryPickerDialog(
                        context,
                        selectedCountry: _standalonePickedCountry,
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
                const SizedBox(height: 8),
                Text(
                  'Selected: ${_standalonePickedCountry!.flag} ${_standalonePickedCountry!.name} (${_standalonePickedCountry!.dialCode})',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
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
