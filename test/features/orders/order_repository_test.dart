import 'package:flutter_ecommerce/features/checkout/domain/models/delivery_address.dart';
import 'package:flutter_ecommerce/features/orders/data/datasources/order_local_data_source.dart';
import 'package:flutter_ecommerce/features/orders/data/repositories/order_repository_impl.dart';
import 'package:flutter_ecommerce/features/orders/domain/models/order.dart';
import 'package:flutter_ecommerce/features/orders/domain/models/order_item.dart';
import 'package:flutter_ecommerce/features/orders/domain/models/order_status.dart';
import 'package:flutter_ecommerce/features/orders/domain/models/payment_method.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Order _createSampleOrder({
  required String id,
  required DateTime createdAt,
  OrderStatus status = OrderStatus.placed,
}) {
  return Order(
    id: id,
    createdAt: createdAt,
    items: const [
      OrderItem(
        productId: 'prod-001',
        productName: 'AuraSound Wireless Headphones',
        unitPrice: 1999,
        quantity: 1,
      ),
    ],
    deliveryAddress: const DeliveryAddress(
      id: 'addr-1',
      recipientName: 'Bikash Gupta',
      phoneNumber: '9876543210',
      addressLine: '123 MG Road',
      locality: 'Indiranagar',
      city: 'Bengaluru',
      state: 'Karnataka',
      postalCode: '560038',
      isDefault: true,
    ),
    paymentMethod: PaymentMethodType.mockOnlinePayment,
    paymentStatus: PaymentStatus.simulatedSuccess,
    orderStatus: status,
    subtotal: 1999,
    discount: 0,
    deliveryCharge: 0,
    total: 1999,
  );
}

void main() {
  late SharedPreferences prefs;
  late OrderLocalDataSource dataSource;
  late OrderRepositoryImpl repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    dataSource = OrderLocalDataSourceImpl(prefs: prefs);
    repository = OrderRepositoryImpl(localDataSource: dataSource);
  });

  group('OrderRepository', () {
    test('Saves and retrieves orders successfully', () async {
      final order1 = _createSampleOrder(
        id: 'ORD-001',
        createdAt: DateTime(2026, 10, 25, 10, 0),
      );

      await repository.saveOrder(order1);
      final orders = await repository.getOrders();

      expect(orders.length, 1);
      expect(orders.first.id, 'ORD-001');
      expect(
        orders.first.items.first.productName,
        'AuraSound Wireless Headphones',
      );
    });

    test('Retrieves order by ID correctly', () async {
      final order1 = _createSampleOrder(
        id: 'ORD-001',
        createdAt: DateTime(2026, 10, 25, 10, 0),
      );
      final order2 = _createSampleOrder(
        id: 'ORD-002',
        createdAt: DateTime(2026, 10, 26, 11, 0),
      );

      await repository.saveOrder(order1);
      await repository.saveOrder(order2);

      final found = await repository.getOrderById('ORD-002');
      expect(found, isNotNull);
      expect(found!.id, 'ORD-002');

      final notFound = await repository.getOrderById('NON-EXISTENT');
      expect(notFound, isNull);
    });

    test('Orders are returned sorted newest first', () async {
      final olderOrder = _createSampleOrder(
        id: 'ORD-OLD',
        createdAt: DateTime(2026, 10, 20),
      );
      final newerOrder = _createSampleOrder(
        id: 'ORD-NEW',
        createdAt: DateTime(2026, 10, 27),
      );
      final middleOrder = _createSampleOrder(
        id: 'ORD-MID',
        createdAt: DateTime(2026, 10, 24),
      );

      await repository.saveOrder(olderOrder);
      await repository.saveOrder(newerOrder);
      await repository.saveOrder(middleOrder);

      final orders = await repository.getOrders();
      expect(orders.length, 3);
      expect(orders[0].id, 'ORD-NEW');
      expect(orders[1].id, 'ORD-MID');
      expect(orders[2].id, 'ORD-OLD');
    });

    test('Handles malformed stored data without crashing', () async {
      // Simulate a list in SharedPreferences containing one valid JSON and one corrupted string
      await prefs.setStringList('persisted_orders_v1', [
        'INVALID_NON_JSON_STRING{{{',
        '{"id": "ORD-VALID", "createdAt": "2026-10-27T10:00:00.000", "items": [], "subtotal": 0, "total": 0}',
      ]);

      final orders = await repository.getOrders();
      // Should gracefully parse the valid order and ignore the corrupted entry
      expect(orders.length, 1);
      expect(orders.first.id, 'ORD-VALID');
    });

    test('Updates order status in storage', () async {
      final order = _createSampleOrder(
        id: 'ORD-STATUS-TEST',
        createdAt: DateTime.now(),
        status: OrderStatus.placed,
      );

      await repository.saveOrder(order);
      await repository.updateOrderStatus(
        'ORD-STATUS-TEST',
        OrderStatus.confirmed,
      );

      final updated = await repository.getOrderById('ORD-STATUS-TEST');
      expect(updated, isNotNull);
      expect(updated!.orderStatus, OrderStatus.confirmed);
    });
  });
}
