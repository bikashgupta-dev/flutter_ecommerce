import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';

enum ProductSortOption {
  featured('Featured'),
  priceLowToHigh('Price: Low to High'),
  priceHighToLow('Price: High to Low'),
  rating('Rating: High to Low');

  final String label;
  const ProductSortOption(this.label);
}

class ProductSortSheet extends StatelessWidget {
  final ProductSortOption selectedOption;
  final ValueChanged<ProductSortOption> onSelect;

  const ProductSortSheet({
    super.key,
    required this.selectedOption,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.md),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(
                'Sort Products',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(),
            ...ProductSortOption.values.map((option) {
              final isSelected = option == selectedOption;
              return ListTile(
                title: Text(
                  option.label,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                  ),
                ),
                trailing: isSelected
                    ? Icon(Icons.check_rounded, color: colorScheme.primary)
                    : null,
                onTap: () {
                  onSelect(option);
                  Navigator.of(context).pop();
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
