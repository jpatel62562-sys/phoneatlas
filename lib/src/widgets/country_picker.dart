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

  /// Background color for the selected country item tile.
  final Color? selectedItemBackgroundColor;

  /// Border for the selected country item tile.
  final Border? selectedItemBorder;

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
    this.selectedItemBackgroundColor,
    this.selectedItemBorder,
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
      return LayoutBuilder(
        builder: (context, constraints) {
          final isLargeScreen = constraints.maxWidth >= 768;
          final height = constraints.maxHeight * (isLargeScreen ? 0.75 : 0.85);
          final maxWidth = isLargeScreen ? 550.0 : 600.0;

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: height),
              child: Container(
                decoration: BoxDecoration(
                  color:
                      themeData?.backgroundColor ??
                      Theme.of(ctx).colorScheme.surface,
                  borderRadius:
                      themeData?.borderRadius ??
                      (isLargeScreen
                          ? BorderRadius.circular(20)
                          : const BorderRadius.vertical(
                              top: Radius.circular(20),
                            )),
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
      return LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 400;
          final dialogMaxWidth =
              isCompact ? constraints.maxWidth * 0.95 : 500.0;
          final dialogMaxHeight = constraints.maxHeight * 0.75;

          return Dialog(
            backgroundColor:
                themeData?.backgroundColor ?? Theme.of(ctx).colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius:
                  themeData?.borderRadius ?? BorderRadius.circular(16),
            ),
            insetPadding: EdgeInsets.symmetric(
              horizontal: isCompact ? 12 : 20,
              vertical: 24,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: dialogMaxWidth,
                maxHeight: dialogMaxHeight,
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
  late final ScrollController _scrollController;
  late List<Country> _baseCountries;
  late List<Country> _allCountries;
  List<Country> _filteredCountries = const [];
  Country? _selectedCountry;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController = ScrollController();
    _selectedCountry = widget.selectedCountry;
    _baseCountries =
        List<Country>.unmodifiable(widget.countries ?? Country.all);
    _allCountries = _reorderCountries(_baseCountries, _selectedCountry);
    _filteredCountries = _allCountries;
  }

  @override
  void didUpdateWidget(CountryPickerContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCountry != oldWidget.selectedCountry ||
        widget.countries != oldWidget.countries) {
      _selectedCountry = widget.selectedCountry;
      _baseCountries =
          List<Country>.unmodifiable(widget.countries ?? Country.all);
      _allCountries = _reorderCountries(_baseCountries, _selectedCountry);
      _applyFilter(_searchController.text);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Places [selected] at index 0 of [list] without duplicating entries,
  /// preserving the relative order of remaining countries.
  static List<Country> _reorderCountries(
    List<Country> list,
    Country? selected,
  ) {
    if (selected == null) return List<Country>.from(list);
    final index = list.indexWhere((c) => c.isoCode == selected.isoCode);
    if (index <= 0) {
      return List<Country>.from(list);
    }
    final reordered = List<Country>.from(list);
    final item = reordered.removeAt(index);
    reordered.insert(0, item);
    return reordered;
  }

  void _applyFilter(String query) {
    if (query.trim().isEmpty) {
      _filteredCountries = _allCountries;
    } else {
      final trimmed = query.trim().toLowerCase();
      final digitsOnly = query.replaceAll(RegExp(r'[^\d]'), '');

      final matches = _baseCountries.where((c) {
        final nameMatch = c.name.toLowerCase().contains(trimmed);
        final isoMatch = c.isoCode.toLowerCase().contains(trimmed);
        final dialMatch =
            c.dialCode.toLowerCase().contains(trimmed) ||
            (digitsOnly.isNotEmpty &&
                c.dialCode.replaceAll('+', '').contains(digitsOnly));
        return nameMatch || isoMatch || dialMatch;
      }).toList();

      _filteredCountries = _reorderCountries(matches, _selectedCountry);
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _applyFilter(query);
    });
  }

  void _selectCountry(Country country) {
    setState(() {
      _selectedCountry = country;
      _allCountries = _reorderCountries(_baseCountries, country);
      _applyFilter(_searchController.text);
    });
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
    widget.onSelect(country);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 360;
        final horizontalPadding = isCompact ? 12.0 : 16.0;

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
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                6,
                horizontalPadding,
                10,
              ),
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
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
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
                        borderSide:
                            BorderSide(color: colorScheme.outlineVariant),
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
                      controller: _scrollController,
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      itemCount: _filteredCountries.length,
                      itemBuilder: (context, index) {
                        final country = _filteredCountries[index];
                        final isSelected =
                            _selectedCountry?.isoCode == country.isoCode;

                        final tile = CountryListTile(
                          country: country,
                          isSelected: isSelected,
                          showIsoCode: widget.themeData.showIsoCode,
                          showDialCode: widget.themeData.showDialCode,
                          flagSize: widget.themeData.flagSize,
                          selectedBackgroundColor:
                              widget.themeData.selectedItemBackgroundColor,
                          selectedBorder: widget.themeData.selectedItemBorder,
                          onTap: () => _selectCountry(country),
                        );

                        if (index == 0 &&
                            isSelected &&
                            _filteredCountries.length > 1) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              tile,
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                child: Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: colorScheme.outlineVariant.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }

                        return tile;
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
