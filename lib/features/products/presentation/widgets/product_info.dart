import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../domain/entities/product.dart';

class ProductInfo extends StatefulWidget {
  final Product product;

  const ProductInfo({super.key, required this.product});

  @override
  State<ProductInfo> createState() => _ProductInfoState();
}

class _ProductInfoState extends State<ProductInfo> {
  String? _selectedSize;
  String? _selectedColor;

  @override
  void initState() {
    super.initState();
    if (widget.product.availableSizes != null &&
        widget.product.availableSizes!.isNotEmpty) {
      _selectedSize = widget.product.availableSizes!.first;
    }
    if (widget.product.availableColors != null &&
        widget.product.availableColors!.isNotEmpty) {
      _selectedColor = widget.product.availableColors!.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final product = widget.product;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand & Stock Status Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (product.brand != null && product.brand!.isNotEmpty)
                Text(
                  product.brand!.toUpperCase(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                )
              else
                Text(
                  product.category.toUpperCase(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: product.isInStock
                      ? AppColors.success.withAlpha(30)
                      : AppColors.error.withAlpha(30),
                  borderRadius: BorderRadius.circular(AppSpacing.xs),
                ),
                child: Row(
                  children: [
                    Icon(
                      product.isInStock
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      size: 14,
                      color: product.isInStock
                          ? AppColors.success
                          : AppColors.error,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      product.isInStock ? 'In Stock' : 'Out of Stock',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: product.isInStock
                            ? AppColors.success
                            : AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),

          // Title
          Text(
            product.name,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),

          // Rating Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warning.withAlpha(40),
                  borderRadius: BorderRadius.circular(AppSpacing.xxs),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      product.rating.toStringAsFixed(1),
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (product.reviewCount != null) ...[
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '(${product.reviewCount} customer reviews)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Price Row
          Row(
            children: [
              Text(
                '₹${product.price.toInt()}',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              if (product.originalPrice != null) ...[
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '₹${product.originalPrice!.toInt()}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    decoration: TextDecoration.lineThrough,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              if (product.discountPercentage != null) ...[
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(AppSpacing.xxs),
                  ),
                  child: Text(
                    '${product.discountPercentage}% OFF',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(),
          const SizedBox(height: AppSpacing.sm),

          // Colors Selector (if available)
          if (product.availableColors != null &&
              product.availableColors!.isNotEmpty) ...[
            Text(
              'Color: ${_selectedColor ?? ''}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              children: product.availableColors!.map((colorName) {
                final isSelected = colorName == _selectedColor;
                return ChoiceChip(
                  label: Text(colorName),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedColor = colorName;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          // Sizes Selector (if available)
          if (product.availableSizes != null &&
              product.availableSizes!.isNotEmpty) ...[
            Text(
              'Size: ${_selectedSize ?? ''}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              children: product.availableSizes!.map((size) {
                final isSelected = size == _selectedSize;
                return ChoiceChip(
                  label: Text(size),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedSize = size;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          // Description Section
          Text(
            'Description',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            product.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
