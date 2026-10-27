import '../../domain/models/order.dart';
import '../../domain/models/order_status.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_local_data_source.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderLocalDataSource localDataSource;

  OrderRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Order>> getOrders() async {
    final orders = await localDataSource.getOrders();
    final sortedOrders = List<Order>.from(orders);
    // Sort newest orders first
    sortedOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedOrders;
  }

  @override
  Future<Order?> getOrderById(String orderId) async {
    final orders = await localDataSource.getOrders();
    final matches = orders.where((o) => o.id == orderId);
    return matches.isNotEmpty ? matches.first : null;
  }

  @override
  Future<void> saveOrder(Order order) async {
    await localDataSource.saveOrder(order);
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    final orders = await localDataSource.getOrders();
    final index = orders.indexWhere((o) => o.id == orderId);
    if (index >= 0) {
      final updatedOrder = orders[index].copyWith(orderStatus: status);
      orders[index] = updatedOrder;
      await localDataSource.saveOrders(orders);
    } else {
      throw Exception('Order with ID $orderId not found');
    }
  }

  @override
  Future<void> clearOrders() async {
    await localDataSource.clearOrders();
  }
}
