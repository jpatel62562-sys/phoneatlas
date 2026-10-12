import 'package:flutter/material.dart';

import '../models/country.dart';
import 'country_list_tile.dart';

/// Style configuration for the country picker sheet or dialog.
class CountryPickerThemeData {
  /// The title displayed at the top of the picker.
  final String title;

  /// The placeholder text for the search input field.
  final String searchHint;

  /// The text displayed when no countries match the search query.
  final String noResultsText;

  /// Whether to display international dialing codes in the list.
  final bool showDialCode;

  /// Whether to display ISO alpha-2 country codes in the list.
  final bool showIsoCode;

  /// Flag emoji font size.
  final double flagSize;

  /// Background color of the picker sheet or dialog.
  final Color? backgroundColor;

  /// Border radius of the picker modal.
  final BorderRadius? borderRadius;

  /// Shape of the search text field border.
  final InputBorder? searchInputBorder;

  /// Creates a [CountryPickerThemeData].
  const CountryPickerThemeData({
    this.title = 'Select Country',
    this.searchHint = 'Search country, ISO, or dial code...',
    this.noResultsText = 'No countries found',
    this.showDialCode = true,
    this.showIsoCode = false,
    this.flagSize = 24.0,
    this.backgroundColor,
    this.borderRadius,
    this.searchInputBorder,
  });
}

/// Displays a modal bottom sheet allowing the user to search and select a country.
Future<Country?> showCountryPickerSheet(
  BuildContext context, {
  Country? selectedCountry,
  List<Country>? countries,
  CountryPickerThemeData? themeData,
  ValueChanged<Country>? onSelect,
}) {
  return showModalBottomSheet<Country>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final mediaQuery = MediaQuery.of(ctx);
      final height = mediaQuery.size.height * 0.85;

      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600, maxHeight: height),
          child: Container(
            decoration: BoxDecoration(
              color:
                  themeData?.backgroundColor ??
                  Theme.of(ctx).colorScheme.surface,
              borderRadius:
                  themeData?.borderRadius ??
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: CountryPickerContent(
              selectedCountry: selectedCountry,
              countries: countries,
              themeData: themeData ?? const CountryPickerThemeData(),
              onSelect: (country) {
                onSelect?.call(country);
                Navigator.of(ctx).pop(country);
              },
            ),
          ),
        ),
      );
    },
  );
}

/// Displays an alert dialog allowing the user to search and select a country.
Future<Country?> showCountryPickerDialog(
  BuildContext context, {
  Country? selectedCountry,
  List<Country>? countries,
  CountryPickerThemeData? themeData,
  ValueChanged<Country>? onSelect,
}) {
  return showDialog<Country>(
    context: context,
    useSafeArea: true,
    builder: (ctx) {
      final mediaQuery = MediaQuery.of(ctx);
      return Dialog(
        backgroundColor:
            themeData?.backgroundColor ?? Theme.of(ctx).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: themeData?.borderRadius ?? BorderRadius.circular(16),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 500,
            maxHeight: mediaQuery.size.height * 0.75,
          ),
          child: CountryPickerContent(
            selectedCountry: selectedCountry,
            countries: countries,
            themeData: themeData ?? const CountryPickerThemeData(),
            onSelect: (country) {
              onSelect?.call(country);
              Navigator.of(ctx).pop(country);
            },
          ),
        ),
      );
    },
  );
}

/// The reusable search and list content widget for selecting countries.
class CountryPickerContent extends StatefulWidget {
  /// The currently selected country.
  final Country? selectedCountry;

  /// Custom list of countries to display. Defaults to all 245+ countries.
  final List<Country>? countries;

  /// Visual theme and customization settings.
  final CountryPickerThemeData themeData;

  /// Callback invoked when a country is selected.
  final ValueChanged<Country> onSelect;

  /// Creates a [CountryPickerContent].
  const CountryPickerContent({
    super.key,
    this.selectedCountry,
    this.countries,
    required this.themeData,
    required this.onSelect,
  });

  @override
  State<CountryPickerContent> createState() => _CountryPickerContentState();
}

class _CountryPickerContentState extends State<CountryPickerContent> {
  late final TextEditingController _searchController;
  late final List<Country> _allCountries;
  List<Country> _filteredCountries = const [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _allCountries = widget.countries ?? Country.all;
    _filteredCountries = _allCountries;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        _filteredCountries = _allCountries;
      } else {
        final trimmed = query.trim().toLowerCase();
        final digitsOnly = query.replaceAll(RegExp(r'[^\d]'), '');

        _filteredCountries = _allCountries.where((c) {
          final nameMatch = c.name.toLowerCase().contains(trimmed);
          final isoMatch = c.isoCode.toLowerCase().contains(trimmed);
          final dialMatch =
              c.dialCode.toLowerCase().contains(trimmed) ||
              (digitsOnly.isNotEmpty &&
                  c.dialCode.replaceAll('+', '').contains(digitsOnly));
          return nameMatch || isoMatch || dialMatch;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Handle bar indicator
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),

        // Header Title
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.themeData.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                tooltip: 'Close',
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ],
          ),
        ),

        // Search Input
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _searchController,
            autofocus: false,
            decoration: InputDecoration(
              hintText: widget.themeData.searchHint,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              border:
                  widget.themeData.searchInputBorder ??
                  OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outlineVariant),
                  ),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.4,
              ),
            ),
            onChanged: _onSearchChanged,
          ),
        ),

        const SizedBox(height: 8),

        // Country List
        Expanded(
          child: _filteredCountries.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 48,
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.6,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.themeData.noResultsText,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  itemCount: _filteredCountries.length,
                  itemBuilder: (context, index) {
                    final country = _filteredCountries[index];
                    final isSelected =
                        widget.selectedCountry?.isoCode == country.isoCode;

                    return CountryListTile(
                      country: country,
                      isSelected: isSelected,
                      showIsoCode: widget.themeData.showIsoCode,
                      showDialCode: widget.themeData.showDialCode,
                      flagSize: widget.themeData.flagSize,
                      onTap: () => widget.onSelect(country),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
