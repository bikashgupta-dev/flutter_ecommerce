import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_spacing.dart';
import 'category_card.dart';

class CategorySection extends StatelessWidget {
  const CategorySection({super.key});

  static const List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': Icons.grid_view_rounded},
    {'name': 'Electronics', 'icon': Icons.devices_rounded},
    {'name': 'Fashion', 'icon': Icons.checkroom_rounded},
    {'name': 'Beauty', 'icon': Icons.spa_rounded},
    {'name': 'Home', 'icon': Icons.home_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Categories',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => context.go('/products'),
                child: const Text('See all'),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        SizedBox(
          height: 48,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              return CategoryCard(
                name: category['name'] as String,
                icon: category['icon'] as IconData,
                isSelected: index == 0,
                onTap: () => context.go('/products'),
              );
            },
          ),
        ),
      ],
    );
  }
}
