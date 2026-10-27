import '../models/order.dart';
import '../models/order_status.dart';

abstract class OrderRepository {
  Future<List<Order>> getOrders();
  Future<Order?> getOrderById(String orderId);
  Future<void> saveOrder(Order order);
  Future<void> updateOrderStatus(String orderId, OrderStatus status);
  Future<void> clearOrders();
}
