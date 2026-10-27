import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../cart/presentation/providers/cart_provider.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final cartItemCount = ref.watch(cartItemCountProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppSpacing.xs),
                ),
                child: const Center(
                  child: Text(
                    'S',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'ShopSphere',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.person_outline_rounded),
                tooltip: 'My Profile',
                onPressed: () => context.push('/profile'),
              ),
              IconButton(
                icon: const Icon(Icons.receipt_long_outlined),
                tooltip: 'My Orders',
                onPressed: () => context.push('/orders'),
              ),
              IconButton(
                icon: const Icon(Icons.favorite_border_rounded),
                tooltip: 'Wishlist',
                onPressed: () => context.go('/wishlist'),
              ),
              IconButton(
                icon: cartItemCount > 0
                    ? Badge(
                        label: Text('$cartItemCount'),
                        child: const Icon(Icons.shopping_bag_outlined),
                      )
                    : const Icon(Icons.shopping_bag_outlined),
                tooltip: 'Shopping Cart',
                onPressed: () => context.go('/cart'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
