import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../providers/product_providers.dart';
import '../widgets/product_card.dart';
import '../widgets/product_filter_sheet.dart';
import '../widgets/product_sort_sheet.dart';

class ProductCatalogPage extends ConsumerStatefulWidget {
  const ProductCatalogPage({super.key});

  @override
  ConsumerState<ProductCatalogPage> createState() => _ProductCatalogPageState();
}

class _ProductCatalogPageState extends ConsumerState<ProductCatalogPage> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    final initialQuery = ref.read(productCatalogNotifierProvider).searchQuery;
    _searchController = TextEditingController(text: initialQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final catalogState = ref.watch(productCatalogNotifierProvider);
    final asyncProducts = ref.watch(filteredProductsAsyncProvider);
    final cartItemCount = ref.watch(cartItemCountProvider);

    // Keep text controller in sync if search query is reset externally
    if (_searchController.text != catalogState.searchQuery) {
      _searchController.text = catalogState.searchQuery;
      _searchController.selection = TextSelection.fromPosition(
        TextPosition(offset: _searchController.text.length),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back to Home',
          onPressed: () => context.go('/'),
        ),
        actions: [
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
      body: SafeArea(
        child: Column(
          children: [
            // Search & Filter Controls Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      ref
                          .read(productCatalogNotifierProvider.notifier)
                          .setSearchQuery(val);
                    },
                    decoration: InputDecoration(
                      hintText:
                          'Search products by name, brand, or category...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: catalogState.searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              tooltip: 'Clear search',
                              onPressed: () {
                                _searchController.clear();
                                ref
                                    .read(
                                      productCatalogNotifierProvider.notifier,
                                    )
                                    .setSearchQuery('');
                              },
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      // Filter Button Chip
                      FilterChip(
                        selected: catalogState.isFiltered,
                        label: Text(
                          catalogState.isFiltered
                              ? 'Filters (${catalogState.category ?? 'Active'})'
                              : 'Filter',
                        ),
                        avatar: Icon(
                          Icons.filter_list_rounded,
                          size: 18,
                          color: catalogState.isFiltered
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface,
                        ),
                        onSelected: (_) {
                          final currentCriteria = ProductFilterCriteria(
                            category: catalogState.category,
                            minPrice: catalogState.minPrice,
                            maxPrice: catalogState.maxPrice,
                            minRating: catalogState.minRating,
                            onlyInStock: catalogState.onlyInStock,
                          );

                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (ctx) => ProductFilterSheet(
                              initialCriteria: currentCriteria,
                              onApply: (newCriteria) {
                                ref
                                    .read(
                                      productCatalogNotifierProvider.notifier,
                                    )
                                    .updateFilterCriteria(
                                      category: newCriteria.category,
                                      minPrice: newCriteria.minPrice,
                                      maxPrice: newCriteria.maxPrice,
                                      minRating: newCriteria.minRating,
                                      onlyInStock: newCriteria.onlyInStock,
                                    );
                              },
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: AppSpacing.xs),

                      // Sort Button Chip
                      ActionChip(
                        label: Text(catalogState.sortOption.label),
                        avatar: const Icon(Icons.swap_vert_rounded, size: 18),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (ctx) => ProductSortSheet(
                              selectedOption: catalogState.sortOption,
                              onSelect: (newOption) {
                                ref
                                    .read(
                                      productCatalogNotifierProvider.notifier,
                                    )
                                    .setSortOption(newOption);
                              },
                            ),
                          );
                        },
                      ),
                      const Spacer(),

                      // Product Count Indicator
                      asyncProducts.when(
                        data: (products) => Text(
                          '${products.length} items',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (err, stack) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Main Async Product Grid, Loading View, or Error View
            Expanded(
              child: asyncProducts.when(
                data: (products) {
                  if (products.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 64,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'No products found',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Try adjusting your search or filters to find what you are looking for.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            ElevatedButton.icon(
                              onPressed: () {
                                _searchController.clear();
                                ref
                                    .read(
                                      productCatalogNotifierProvider.notifier,
                                    )
                                    .resetSearchAndFilters();
                              },
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Clear Search & Filters'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(productsAsyncProvider);
                      await ref.read(productsAsyncProvider.future);
                    },
                    child: GridView.builder(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: AppSpacing.md,
                            crossAxisSpacing: AppSpacing.md,
                            childAspectRatio: 0.68,
                          ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        return ProductCard(product: products[index]);
                      },
                    ),
                  );
                },
                loading: () =>
                    const LoadingView(message: 'Loading products...'),
                error: (err, stack) => ErrorView(
                  title: 'Unable to load products',
                  message: err.toString(),
                  onRetry: () => ref.invalidate(productsAsyncProvider),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
