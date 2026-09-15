import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../wishlist/presentation/providers/wishlist_provider.dart';
import '../providers/product_providers.dart';
import '../widgets/product_image_gallery.dart';
import '../widgets/product_info.dart';

class ProductDetailsPage extends ConsumerWidget {
  final String productId;

  const ProductDetailsPage({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Resolve Product via Riverpod Async Provider
    final asyncProduct = ref.watch(productDetailsAsyncProvider(productId));
    final isWishlisted = ref.watch(isWishlistedProvider(productId));

    return asyncProduct.when(
      data: (product) {
        return Scaffold(
          appBar: AppBar(
            title: Text(product.brand ?? product.category),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              tooltip: 'Back',
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/products');
                }
              },
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isWishlisted
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                ),
                color: isWishlisted ? AppColors.error : colorScheme.onSurface,
                tooltip: isWishlisted
                    ? 'Remove from wishlist'
                    : 'Add to wishlist',
                onPressed: () {
                  ref
                      .read(wishlistNotifierProvider.notifier)
                      .toggleWishlist(product.id);
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        !isWishlisted
                            ? 'Added to wishlist'
                            : 'Removed from wishlist',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined),
                tooltip: 'Share product',
                onPressed: () {},
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProductImageGallery(images: product.images),
                  ProductInfo(product: product),
                  const SizedBox(
                    height: 80,
                  ), // Padding for sticky bottom button
                ],
              ),
            ),
          ),
          bottomSheet: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(20),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: product.isInStock
                      ? () {
                          ref
                              .read(cartNotifierProvider.notifier)
                              .addToCart(product);
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Added to cart'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      : null,
                  icon: const Icon(Icons.shopping_bag_outlined),
                  label: Text(
                    product.isInStock ? 'Add to Cart' : 'Out of Stock',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Product Details')),
        body: const LoadingView(message: 'Loading product details...'),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(title: const Text('Product Details')),
        body: ErrorView(
          title: 'Unable to load product',
          message: err.toString(),
          onRetry: () => ref.invalidate(productDetailsAsyncProvider(productId)),
        ),
      ),
    );
  }
}
