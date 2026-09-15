import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../products/presentation/providers/product_providers.dart';
import '../../../products/presentation/widgets/product_card.dart';
import '../widgets/category_section.dart';
import '../widgets/featured_products_section.dart';
import '../widgets/home_header.dart';
import '../widgets/home_search_bar.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncFeaturedProducts = ref.watch(featuredProductsAsyncProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header: Branding & Action Icons
            const SliverToBoxAdapter(child: HomeHeader()),

            // Search Bar
            const SliverToBoxAdapter(child: HomeSearchBar()),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),

            // Categories Section
            const SliverToBoxAdapter(child: CategorySection()),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

            // Featured Products Header
            const SliverToBoxAdapter(child: FeaturedProductsSectionHeader()),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xs)),

            // Async Featured Products Grid / Loading / Error
            asyncFeaturedProducts.when(
              data: (featuredProducts) {
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: AppSpacing.md,
                          crossAxisSpacing: AppSpacing.md,
                          childAspectRatio: 0.68,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return ProductCard(product: featuredProducts[index]);
                    }, childCount: featuredProducts.length),
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: LoadingView(message: 'Loading featured products...'),
                ),
              ),
              error: (err, stack) => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: ErrorView(
                    title: 'Unable to load products',
                    message: err.toString(),
                    onRetry: () => ref.invalidate(productsAsyncProvider),
                  ),
                ),
              ),
            ),

            // Bottom Spacing
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
          ],
        ),
      ),
    );
  }
}
