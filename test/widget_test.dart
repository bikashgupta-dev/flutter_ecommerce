import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/app/app.dart';
import 'package:flutter_ecommerce/app/router/app_router.dart';
import 'package:flutter_ecommerce/core/storage/local_storage_service.dart';
import 'package:flutter_ecommerce/features/products/data/mock/mock_products.dart';
import 'package:flutter_ecommerce/features/products/presentation/providers/product_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Widget> _createTestApp() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      productsAsyncProvider.overrideWith((ref) async => mockProducts),
      productDetailsAsyncProvider.overrideWith((ref, id) async {
        return mockProducts.firstWhere((p) => p.id == id);
      }),
    ],
    child: const ShopSphereApp(),
  );
}

void main() {
  testWidgets('ShopSphereApp home route smoke test', (
    WidgetTester tester,
  ) async {
    final app = await _createTestApp();
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    expect(find.text('ShopSphere'), findsOneWidget);
    expect(find.text('Categories'), findsOneWidget);
    expect(find.text('Featured Products'), findsOneWidget);
  });

  testWidgets('Navigates to product catalog page', (WidgetTester tester) async {
    final app = await _createTestApp();
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    AppRouter.config.go('/products');
    await tester.pumpAndSettle();

    expect(find.text('Products'), findsOneWidget);
  });

  testWidgets('Navigates to product details page', (WidgetTester tester) async {
    final app = await _createTestApp();
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    AppRouter.config.go('/products/prod-001');
    await tester.pumpAndSettle();

    expect(find.text('AuraSound Wireless Headphones'), findsOneWidget);
    expect(find.text('Add to Cart'), findsOneWidget);
  });

  testWidgets('Navigates to cart page and displays empty state', (
    WidgetTester tester,
  ) async {
    final app = await _createTestApp();
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    AppRouter.config.go('/cart');
    await tester.pumpAndSettle();

    expect(find.text('Shopping Cart'), findsOneWidget);
    expect(find.text('Your cart is empty'), findsOneWidget);
    expect(find.text('Continue Shopping'), findsOneWidget);
  });

  testWidgets('Navigates to wishlist page and displays empty state', (
    WidgetTester tester,
  ) async {
    final app = await _createTestApp();
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    AppRouter.config.go('/wishlist');
    await tester.pumpAndSettle();

    expect(find.text('My Wishlist'), findsOneWidget);
    expect(find.text('Your wishlist is empty'), findsOneWidget);
    expect(find.text('Explore Products'), findsOneWidget);
  });

  testWidgets('Invalid route displays page not found error page', (
    WidgetTester tester,
  ) async {
    final app = await _createTestApp();
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    AppRouter.config.go('/invalid-route-test');
    await tester.pumpAndSettle();

    expect(find.text('Page not found'), findsOneWidget);
    expect(find.text('Back to Home'), findsOneWidget);
  });
}
