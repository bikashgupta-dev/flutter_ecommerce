import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/cart/presentation/pages/cart_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/products/presentation/pages/product_catalog_page.dart';
import '../../features/products/presentation/pages/product_details_page.dart';
import '../../features/wishlist/presentation/pages/wishlist_page.dart';

abstract class AppRouter {
  static const String home = '/';
  static const String products = '/products';
  static const String productDetails = '/products/:productId';
  static const String cart = '/cart';
  static const String wishlist = '/wishlist';

  static final GoRouter config = GoRouter(
    initialLocation: home,
    routes: [
      GoRoute(path: home, builder: (context, state) => const HomePage()),
      GoRoute(
        path: products,
        builder: (context, state) => const ProductCatalogPage(),
      ),
      GoRoute(
        path: productDetails,
        builder: (context, state) {
          final productId = state.pathParameters['productId'] ?? '';
          return ProductDetailsPage(productId: productId);
        },
      ),
      GoRoute(path: cart, builder: (context, state) => const CartPage()),
      GoRoute(
        path: wishlist,
        builder: (context, state) => const WishlistPage(),
      ),
    ],
    errorBuilder: (context, state) => const _NotFoundPage(),
  );
}

class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRouter.home),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
