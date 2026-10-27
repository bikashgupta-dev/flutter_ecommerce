import 'package:flutter_ecommerce/core/storage/local_storage_service.dart';
import 'package:flutter_ecommerce/features/cart/presentation/providers/cart_provider.dart';
import 'package:flutter_ecommerce/features/checkout/domain/models/delivery_address.dart';
import 'package:flutter_ecommerce/features/checkout/presentation/providers/checkout_provider.dart';
import 'package:flutter_ecommerce/features/orders/domain/models/order.dart';
import 'package:flutter_ecommerce/features/orders/domain/models/order_status.dart';
import 'package:flutter_ecommerce/features/orders/domain/repositories/order_repository.dart';
import 'package:flutter_ecommerce/features/orders/presentation/providers/order_providers.dart';
import 'package:flutter_ecommerce/features/products/domain/entities/product.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FailingOrderRepository implements OrderRepository {
  @override
  Future<List<Order>> getOrders() async => [];

  @override
  Future<Order?> getOrderById(String orderId) async => null;

  @override
  Future<void> saveOrder(Order order) async {
    throw Exception('Simulated disk failure during order persistence');
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {}

  @override
  Future<void> clearOrders() async {}
}

Product _sampleProduct() {
  return const Product(
    id: 'prod-001',
    name: 'AuraSound Wireless Headphones',
    description: 'Test headphones',
    price: 1999,
    originalPrice: 2499,
    discountPercentage: 20,
    category: 'Electronics',
    rating: 4.6,
    images: ['https://example.com/headphones.jpg'],
    isInStock: true,
  );
}

DeliveryAddress _sampleAddress({bool valid = true}) {
  return DeliveryAddress(
    id: 'addr-001',
    recipientName: 'Kavita Iyer',
    phoneNumber: valid ? '9876543210' : '123', // invalid phone
    addressLine: 'Flat 101, Lake View',
    locality: 'Whitefield',
    city: 'Bengaluru',
    state: 'Karnataka',
    postalCode: valid ? '560066' : '000000', // invalid PIN
    isDefault: true,
  );
}

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  group('OrderPlacementController', () {
    test('Rejects order placement when cart is empty', () async {
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );

      final controller = container.read(orderPlacementControllerProvider);
      container
          .read(checkoutNotifierProvider.notifier)
          .selectAddress(_sampleAddress());

      final order = await controller.placeOrder();

      expect(order, isNull);
      final checkoutState = container.read(checkoutNotifierProvider);
      expect(checkoutState.errorMessage, contains('cart is empty'));
      expect(checkoutState.isPlacingOrder, isFalse);
    });

    test('Rejects order placement when no address is selected', () async {
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );

      // Add item to cart
      container.read(cartNotifierProvider.notifier).addToCart(_sampleProduct());
      expect(container.read(cartNotifierProvider).items.length, 1);

      final controller = container.read(orderPlacementControllerProvider);
      final order = await controller.placeOrder();

      expect(order, isNull);
      final checkoutState = container.read(checkoutNotifierProvider);
      expect(checkoutState.errorMessage, contains('delivery address'));
      // Cart items must be preserved!
      expect(container.read(cartNotifierProvider).items.length, 1);
    });

    test('Rejects order placement when selected address is invalid', () async {
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );

      container.read(cartNotifierProvider.notifier).addToCart(_sampleProduct());
      container
          .read(checkoutNotifierProvider.notifier)
          .selectAddress(_sampleAddress(valid: false));

      final controller = container.read(orderPlacementControllerProvider);
      final order = await controller.placeOrder();

      expect(order, isNull);
      final checkoutState = container.read(checkoutNotifierProvider);
      expect(checkoutState.errorMessage, contains('incomplete or invalid'));
      expect(container.read(cartNotifierProvider).items.length, 1);
    });

    test('Successful placement saves order and clears cart', () async {
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );

      container.read(cartNotifierProvider.notifier).addToCart(_sampleProduct());
      container
          .read(checkoutNotifierProvider.notifier)
          .selectAddress(_sampleAddress());

      final controller = container.read(orderPlacementControllerProvider);
      final order = await controller.placeOrder();

      expect(order, isNotNull);
      expect(order!.items.length, 1);
      expect(order.deliveryAddress.recipientName, 'Kavita Iyer');
      expect(order.total, 1999.0);

      // Cart MUST be cleared after successful order placement
      expect(container.read(cartNotifierProvider).isEmpty, isTrue);

      // Check repository contains the newly placed order
      final savedOrders = await container
          .read(orderRepositoryProvider)
          .getOrders();
      expect(savedOrders.length, 1);
      expect(savedOrders.first.id, order.id);
    });

    test(
      'Failed persistence does NOT clear cart and exposes safe error',
      () async {
        final container = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            orderRepositoryProvider.overrideWithValue(FailingOrderRepository()),
          ],
        );

        container
            .read(cartNotifierProvider.notifier)
            .addToCart(_sampleProduct());
        container
            .read(checkoutNotifierProvider.notifier)
            .selectAddress(_sampleAddress());

        final controller = container.read(orderPlacementControllerProvider);
        final order = await controller.placeOrder();

        expect(order, isNull);
        // Cart MUST NOT be cleared on save failure!
        expect(container.read(cartNotifierProvider).items.length, 1);

        final checkoutState = container.read(checkoutNotifierProvider);
        expect(checkoutState.errorMessage, isNotNull);
        expect(
          checkoutState.errorMessage,
          'Unable to process and save your order. Please try again.',
        );
        expect(checkoutState.isPlacingOrder, isFalse);
      },
    );

    test(
      'Repeated submissions while placing order do not duplicate orders',
      () async {
        final container = ProviderContainer(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        );

        container
            .read(cartNotifierProvider.notifier)
            .addToCart(_sampleProduct());
        container
            .read(checkoutNotifierProvider.notifier)
            .selectAddress(_sampleAddress());

        // Simulate placing order flag already in progress
        container.read(checkoutNotifierProvider.notifier).setPlacingOrder(true);

        final controller = container.read(orderPlacementControllerProvider);
        final order = await controller.placeOrder();

        // Guard should block concurrent execution
        expect(order, isNull);
      },
    );
  });
}
