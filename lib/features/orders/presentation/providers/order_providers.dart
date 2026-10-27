import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/local_storage_service.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../checkout/presentation/providers/address_providers.dart';
import '../../../checkout/presentation/providers/checkout_provider.dart';
import '../../data/datasources/order_local_data_source.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../domain/models/order.dart';
import '../../domain/models/order_item.dart';
import '../../domain/models/order_pricing_calculator.dart';
import '../../domain/models/order_status.dart';
import '../../domain/models/payment_method.dart';
import '../../domain/repositories/order_repository.dart';

final orderLocalDataSourceProvider = Provider<OrderLocalDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return OrderLocalDataSourceImpl(prefs: prefs);
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final localDataSource = ref.watch(orderLocalDataSourceProvider);
  return OrderRepositoryImpl(localDataSource: localDataSource);
});

class OrderHistoryNotifier extends AsyncNotifier<List<Order>> {
  @override
  Future<List<Order>> build() async {
    final repository = ref.read(orderRepositoryProvider);
    return await repository.getOrders();
  }

  Future<void> refreshOrders() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(orderRepositoryProvider);
      return await repository.getOrders();
    });
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    final repository = ref.read(orderRepositoryProvider);
    await repository.updateOrderStatus(orderId, status);
    await refreshOrders();
  }
}

final orderHistoryNotifierProvider =
    AsyncNotifierProvider<OrderHistoryNotifier, List<Order>>(
      OrderHistoryNotifier.new,
    );

final orderByIdProvider = FutureProvider.family<Order?, String>((
  ref,
  orderId,
) async {
  final repository = ref.read(orderRepositoryProvider);
  return await repository.getOrderById(orderId);
});

class OrderPlacementController {
  final Ref ref;

  OrderPlacementController(this.ref);

  /// Executes the 9-step order creation sequence with concurrency lock and strict rollback
  Future<Order?> placeOrder() async {
    final checkoutNotifier = ref.read(checkoutNotifierProvider.notifier);
    final checkoutState = ref.read(checkoutNotifierProvider);
    final cartState = ref.read(cartNotifierProvider);

    // 1. Concurrency lock against duplicate submissions
    if (checkoutState.isPlacingOrder) {
      return null;
    }

    checkoutNotifier.setPlacingOrder(true);
    checkoutNotifier.clearError();

    // 2. Validate Cart
    if (cartState.isEmpty) {
      checkoutNotifier.setError(
        'Your cart is empty. Please add products before checking out.',
      );
      checkoutNotifier.setPlacingOrder(false);
      return null;
    }

    // 3. Validate Address Selection & Completeness
    final address =
        checkoutState.selectedAddress ??
        (ref.read(addressListNotifierProvider).value?.isNotEmpty == true
            ? ref
                  .read(addressListNotifierProvider)
                  .value!
                  .firstWhere(
                    (a) => a.isDefault,
                    orElse: () =>
                        ref.read(addressListNotifierProvider).value!.first,
                  )
            : null);
    if (address == null) {
      checkoutNotifier.setError('Please select or add a delivery address.');
      checkoutNotifier.setPlacingOrder(false);
      return null;
    }

    if (!address.isValid) {
      checkoutNotifier.setError(
        'The selected delivery address is incomplete or invalid. Please edit it.',
      );
      checkoutNotifier.setPlacingOrder(false);
      return null;
    }

    // 4. Create Immutable OrderItem Snapshots from Cart
    final items = cartState.items
        .map((ci) => OrderItem.fromCartItem(ci))
        .toList();

    // 5. Compute Authoritative Pricing
    final pricing = OrderPricingCalculator.calculateFromCart(cartState.items);

    // 6. Generate Unique Order ID & Timestamp
    final orderId = Order.generateOrderId();
    final createdAt = DateTime.now();

    // 7. Determine Simulated Payment Status
    final paymentMethod = checkoutState.selectedPaymentMethod;
    final paymentStatus = paymentMethod == PaymentMethodType.mockOnlinePayment
        ? PaymentStatus.simulatedSuccess
        : PaymentStatus.cashOnDelivery;

    final order = Order(
      id: orderId,
      createdAt: createdAt,
      items: items,
      deliveryAddress: address,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus,
      orderStatus: OrderStatus.placed,
      subtotal: pricing.subtotal,
      discount: pricing.discount,
      deliveryCharge: pricing.deliveryCharge,
      total: pricing.total,
    );

    // 8. Persist Order to Storage
    try {
      final repository = ref.read(orderRepositoryProvider);
      await repository.saveOrder(order);
    } catch (_) {
      // Failure rollback: DO NOT clear cart, keep checkout intact, set actionable error
      checkoutNotifier.setError(
        'Unable to process and save your order. Please try again.',
      );
      checkoutNotifier.setPlacingOrder(false);
      return null;
    }

    // 9. Post-Success Actions: Clear Cart, Reset Checkout, Refresh History
    ref.read(cartNotifierProvider.notifier).clearCart();
    checkoutNotifier.reset();
    checkoutNotifier.setPlacingOrder(false);

    // Trigger background refresh of order history
    ref.read(orderHistoryNotifierProvider.notifier).refreshOrders();

    return order;
  }
}

final orderPlacementControllerProvider = Provider<OrderPlacementController>((
  ref,
) {
  return OrderPlacementController(ref);
});
