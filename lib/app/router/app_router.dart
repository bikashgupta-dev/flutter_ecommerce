import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/cart/presentation/pages/cart_page.dart';
import '../../features/checkout/presentation/pages/address_management_page.dart';
import '../../features/checkout/presentation/pages/checkout_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/orders/presentation/pages/order_details_page.dart';
import '../../features/orders/presentation/pages/order_history_page.dart';
import '../../features/orders/presentation/pages/order_success_page.dart';
import '../../features/products/presentation/pages/product_catalog_page.dart';
import '../../features/products/presentation/pages/product_details_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/wishlist/presentation/pages/wishlist_page.dart';

abstract class AppRouter {
  static const String home = '/';
  static const String products = '/products';
  static const String productDetails = '/products/:productId';
  static const String cart = '/cart';
  static const String wishlist = '/wishlist';
  static const String checkout = '/checkout';
  static const String addresses = '/checkout/addresses';
  static const String orderSuccess = '/checkout/success/:orderId';
  static const String orders = '/orders';
  static const String orderDetails = '/orders/:orderId';
  static const String login = '/login';
  static const String register = '/register';
  static const String profile = '/profile';

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
      GoRoute(
        path: checkout,
        builder: (context, state) => const CheckoutPage(),
      ),
      GoRoute(
        path: addresses,
        builder: (context, state) => const AddressManagementPage(),
      ),
      GoRoute(
        path: orderSuccess,
        builder: (context, state) {
          final orderId = state.pathParameters['orderId'] ?? '';
          return OrderSuccessPage(orderId: orderId);
        },
      ),
      GoRoute(
        path: orders,
        builder: (context, state) => const OrderHistoryPage(),
      ),
      GoRoute(
        path: orderDetails,
        builder: (context, state) {
          final orderId = state.pathParameters['orderId'] ?? '';
          return OrderDetailsPage(orderId: orderId);
        },
      ),
      GoRoute(path: login, builder: (context, state) => const LoginPage()),
      GoRoute(
        path: register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(path: profile, builder: (context, state) => const ProfilePage()),
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
