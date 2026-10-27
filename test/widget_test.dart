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

  testWidgets('Navigates to checkout page and displays empty cart view', (
    WidgetTester tester,
  ) async {
    final app = await _createTestApp();
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    AppRouter.config.go(AppRouter.checkout);
    await tester.pumpAndSettle();

    expect(find.text('Checkout'), findsOneWidget);
    expect(find.text('Your cart is empty'), findsOneWidget);
    expect(find.text('Browse Catalog'), findsOneWidget);
  });

  testWidgets('Navigates to addresses page and displays empty state', (
    WidgetTester tester,
  ) async {
    final app = await _createTestApp();
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    AppRouter.config.go(AppRouter.addresses);
    await tester.pumpAndSettle();

    expect(find.text('Select Address'), findsOneWidget);
    expect(find.text('No Addresses Saved'), findsOneWidget);
    expect(find.text('Add New Address'), findsWidgets);
  });

  testWidgets('Navigates to orders history page and displays empty state', (
    WidgetTester tester,
  ) async {
    final app = await _createTestApp();
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    AppRouter.config.go(AppRouter.orders);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    expect(find.text('My Orders'), findsOneWidget);
    expect(find.text('No Orders Yet'), findsOneWidget);
    expect(find.text('Start Shopping'), findsOneWidget);
  });

  testWidgets(
    'Full checkout journey: item in cart, place order, navigate to success',
    (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        'persisted_cart_entries_v1': [
          '{"productId": "prod-001", "quantity": 1}',
        ],
        'persisted_delivery_addresses_v1': [
          '{"id": "addr-1", "recipientName": "Ananya Sharma", "phoneNumber": "9876543210", "addressLine": "Flat 204", "locality": "Indiranagar", "city": "Bengaluru", "state": "Karnataka", "postalCode": "560038", "isDefault": true}',
        ],
      });
      final prefs = await SharedPreferences.getInstance();
      final app = ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          productsAsyncProvider.overrideWith((ref) async => mockProducts),
          productDetailsAsyncProvider.overrideWith((ref, id) async {
            return mockProducts.firstWhere((p) => p.id == id);
          }),
        ],
        child: const ShopSphereApp(),
      );

      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      // Add item to cart via Product Details
      AppRouter.config.go('/products/prod-001');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add to Cart'));
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Navigate to checkout
      AppRouter.config.go(AppRouter.checkout);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(find.text('Checkout'), findsOneWidget);
      expect(find.text('Ananya Sharma'), findsOneWidget);
      expect(find.text('Mock Online Payment'), findsOneWidget);
      expect(find.text('Place Order'), findsOneWidget);

      // Tap Place Order
      await tester.tap(find.text('Place Order'));
      await tester.pumpAndSettle();

      expect(find.text('Order Placed Successfully!'), findsOneWidget);
      expect(find.text('View Order Details'), findsOneWidget);
      expect(find.text('View Order History'), findsOneWidget);
    },
  );

  testWidgets(
    'Navigates to login page and displays sign in form with demo account card',
    (WidgetTester tester) async {
      final app = await _createTestApp();
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      AppRouter.config.go('/login');
      await tester.pumpAndSettle();

      expect(find.text('Sign In'), findsWidgets);
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Demo Account Available'), findsOneWidget);
      expect(find.text('Autofill Demo Credentials'), findsOneWidget);
      expect(find.text('Email Address *'), findsOneWidget);
      expect(find.text('Password *'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
    },
  );

  testWidgets('Navigates to register page and displays registration form', (
    WidgetTester tester,
  ) async {
    final app = await _createTestApp();
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    AppRouter.config.go('/register');
    await tester.pumpAndSettle();

    expect(find.text('Create Account'), findsWidgets);
    expect(find.text('Join ShopSphere'), findsOneWidget);
    expect(find.text('Full Name *'), findsOneWidget);
    expect(find.text('Email Address *'), findsOneWidget);
    expect(find.text('Phone Number (Optional)'), findsOneWidget);
    expect(find.text('Password (min 6 characters) *'), findsOneWidget);
    expect(find.text('Confirm Password *'), findsOneWidget);
  });

  testWidgets('Navigates to profile page as guest and displays guest state', (
    WidgetTester tester,
  ) async {
    final app = await _createTestApp();
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    AppRouter.config.go('/profile');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    expect(find.text('My Profile'), findsOneWidget);
    expect(find.text('Welcome to ShopSphere'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);
    expect(find.text('My Orders'), findsOneWidget);
    expect(find.text('Delivery Addresses'), findsOneWidget);
    expect(find.text('My Wishlist'), findsOneWidget);
    expect(find.text('Portfolio Simulation Mode'), findsOneWidget);
  });

  testWidgets(
    'Full authentication flow: login with demo autofill, view profile, and sign out',
    (WidgetTester tester) async {
      final app = await _createTestApp();
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      // Navigate to login
      AppRouter.config.go('/login');
      await tester.pumpAndSettle();

      // Tap autofill demo credentials
      await tester.tap(find.text('Autofill Demo Credentials'));
      await tester.pumpAndSettle();

      // Submit login form
      final signInButtonFinder = find.widgetWithText(ElevatedButton, 'Sign In');
      await tester.ensureVisible(signInButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(signInButtonFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // Should now be on profile page showing Alex Morgan
      expect(find.text('Alex Morgan'), findsOneWidget);
      expect(find.text('alex.morgan@example.com'), findsOneWidget);
      expect(find.text('AM'), findsOneWidget);
      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Sign Out'), findsOneWidget);

      // Tap Sign Out
      final signOutButtonFinder = find.text('Sign Out');
      await tester.ensureVisible(signOutButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(signOutButtonFinder);
      await tester.pumpAndSettle();

      // Confirm sign out in dialog
      expect(
        find.text('Are you sure you want to sign out of your account?'),
        findsOneWidget,
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Out'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // State is back to guest
      expect(find.text('Welcome to ShopSphere'), findsOneWidget);
    },
  );
}
