import 'package:flutter/material.dart';

import '../models/country.dart';

/// A list tile representing a country in the country picker.
class CountryListTile extends StatelessWidget {
  /// The country to display.
  final Country country;

  /// Whether this country is currently selected.
  final bool isSelected;

  /// Callback when the country tile is tapped.
  final VoidCallback? onTap;

  /// Whether to display the ISO code (e.g. 'US').
  final bool showIsoCode;

  /// Whether to display the international dial code (e.g. '+1').
  final bool showDialCode;

  /// Size of the flag emoji.
  final double flagSize;

  /// Text style for the country name.
  final TextStyle? nameStyle;

  /// Text style for the dial code.
  final TextStyle? dialCodeStyle;

  /// Background color when [isSelected] is true.
  final Color? selectedBackgroundColor;

  /// Border when [isSelected] is true.
  final Border? selectedBorder;

  /// Creates a [CountryListTile].
  const CountryListTile({
    super.key,
    required this.country,
    this.isSelected = false,
    this.onTap,
    this.showIsoCode = false,
    this.showDialCode = true,
    this.flagSize = 24.0,
    this.nameStyle,
    this.dialCodeStyle,
    this.selectedBackgroundColor,
    this.selectedBorder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final effectiveSelectedBg = selectedBackgroundColor ??
        colorScheme.primaryContainer.withValues(alpha: 0.35);
    final effectiveSelectedBorder = selectedBorder ??
        Border.all(
          color: colorScheme.primary.withValues(alpha: 0.6),
          width: 1.5,
        );

    return Semantics(
      label: '${country.name}, dial code ${country.dialCode}',
      selected: isSelected,
      button: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2.5),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              constraints: const BoxConstraints(minHeight: 50),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? effectiveSelectedBg : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: isSelected ? effectiveSelectedBorder : null,
              ),
              child: Row(
                children: [
                  Text(country.flag, style: TextStyle(fontSize: flagSize)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            country.name,
                            style: nameStyle ??
                                theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? colorScheme.primary
                                      : null,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (showIsoCode) ...[
                          const SizedBox(width: 6),
                          Text(
                            '(${country.isoCode})',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color
                                  ?.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (showDialCode) ...[
                    const SizedBox(width: 8),
                    Text(
                      country.dialCode,
                      style: dialCodeStyle ??
                          theme.textTheme.bodyMedium?.copyWith(
                            color: isSelected
                                ? colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                    ),
                  ],
                  if (isSelected) ...[
                    const SizedBox(width: 10),
                    Icon(
                      Icons.check_circle_rounded,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
