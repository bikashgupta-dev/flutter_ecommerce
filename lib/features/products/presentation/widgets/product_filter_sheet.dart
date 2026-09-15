import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';

class ProductFilterCriteria {
  final String? category;
  final double minPrice;
  final double maxPrice;
  final double minRating;
  final bool onlyInStock;

  const ProductFilterCriteria({
    this.category,
    this.minPrice = 0,
    this.maxPrice = 5000,
    this.minRating = 0,
    this.onlyInStock = false,
  });

  bool get isDefault =>
      category == null &&
      minPrice == 0 &&
      maxPrice == 5000 &&
      minRating == 0 &&
      !onlyInStock;

  ProductFilterCriteria copyWith({
    String? category,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    bool? onlyInStock,
    bool clearCategory = false,
  }) {
    return ProductFilterCriteria(
      category: clearCategory ? null : (category ?? this.category),
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minRating: minRating ?? this.minRating,
      onlyInStock: onlyInStock ?? this.onlyInStock,
    );
  }
}

class ProductFilterSheet extends StatefulWidget {
  final ProductFilterCriteria initialCriteria;
  final ValueChanged<ProductFilterCriteria> onApply;

  const ProductFilterSheet({
    super.key,
    required this.initialCriteria,
    required this.onApply,
  });

  @override
  State<ProductFilterSheet> createState() => _ProductFilterSheetState();
}

class _ProductFilterSheetState extends State<ProductFilterSheet> {
  late String? _selectedCategory;
  late RangeValues _priceRange;
  late double _minRating;
  late bool _onlyInStock;

  static const List<String> _categories = [
    'Electronics',
    'Fashion',
    'Beauty',
    'Home',
    'Sports',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCriteria.category;
    _priceRange = RangeValues(
      widget.initialCriteria.minPrice,
      widget.initialCriteria.maxPrice,
    );
    _minRating = widget.initialCriteria.minRating;
    _onlyInStock = widget.initialCriteria.onlyInStock;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.md),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter Products',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedCategory = null;
                        _priceRange = const RangeValues(0, 5000);
                        _minRating = 0;
                        _onlyInStock = false;
                      });
                    },
                    child: const Text('Clear All'),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: AppSpacing.sm),

              // Categories
              Text(
                'Category',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = selected ? cat : null;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.md),

              // Price Range
              Text(
                'Price Range (₹${_priceRange.start.round()} - ₹${_priceRange.end.round()})',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              RangeSlider(
                values: _priceRange,
                min: 0,
                max: 5000,
                divisions: 50,
                labels: RangeLabels(
                  '₹${_priceRange.start.round()}',
                  '₹${_priceRange.end.round()}',
                ),
                onChanged: (values) {
                  setState(() {
                    _priceRange = values;
                  });
                },
              ),
              const SizedBox(height: AppSpacing.md),

              // Minimum Rating
              Text(
                'Minimum Rating (${_minRating > 0 ? "${_minRating.toStringAsFixed(1)}★ & up" : "Any"})',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Slider(
                value: _minRating,
                min: 0,
                max: 5,
                divisions: 10,
                label: '${_minRating.toStringAsFixed(1)}★',
                onChanged: (val) {
                  setState(() {
                    _minRating = val;
                  });
                },
              ),
              const SizedBox(height: AppSpacing.sm),

              // Stock Switch
              SwitchListTile(
                title: const Text('In Stock Only'),
                value: _onlyInStock,
                contentPadding: EdgeInsets.zero,
                activeTrackColor: AppColors.primary,
                onChanged: (val) {
                  setState(() {
                    _onlyInStock = val;
                  });
                },
              ),
              const SizedBox(height: AppSpacing.md),

              // Apply Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final criteria = ProductFilterCriteria(
                      category: _selectedCategory,
                      minPrice: _priceRange.start,
                      maxPrice: _priceRange.end,
                      minRating: _minRating,
                      onlyInStock: _onlyInStock,
                    );
                    widget.onApply(criteria);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
