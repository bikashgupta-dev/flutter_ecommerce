import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/order.dart';

abstract class OrderLocalDataSource {
  Future<List<Order>> getOrders();
  Future<void> saveOrder(Order order);
  Future<void> saveOrders(List<Order> orders);
  Future<void> clearOrders();
}

class OrderLocalDataSourceImpl implements OrderLocalDataSource {
  static const String _ordersStorageKey = 'persisted_orders_v1';
  final SharedPreferences prefs;

  OrderLocalDataSourceImpl({required this.prefs});

  @override
  Future<List<Order>> getOrders() async {
    try {
      final jsonList = prefs.getStringList(_ordersStorageKey);
      if (jsonList == null || jsonList.isEmpty) {
        return const [];
      }

      final List<Order> validOrders = [];
      for (final jsonStr in jsonList) {
        try {
          final Map<String, dynamic> jsonMap = json.decode(jsonStr);
          validOrders.add(Order.fromJson(jsonMap));
        } catch (_) {
          // Gracefully isolate and skip corrupted single order record
        }
      }
      return validOrders;
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<void> saveOrder(Order order) async {
    try {
      final currentOrders = await getOrders();
      final updatedOrders = List<Order>.from(currentOrders);
      final existingIndex = updatedOrders.indexWhere((o) => o.id == order.id);

      if (existingIndex >= 0) {
        updatedOrders[existingIndex] = order;
      } else {
        // Prepend new orders to maintain recency
        updatedOrders.insert(0, order);
      }

      await saveOrders(updatedOrders);
    } catch (e) {
      throw Exception('Failed to persist order: $e');
    }
  }

  @override
  Future<void> saveOrders(List<Order> orders) async {
    try {
      final jsonList = orders.map((o) => json.encode(o.toJson())).toList();
      await prefs.setStringList(_ordersStorageKey, jsonList);
    } catch (e) {
      throw Exception('Failed to write orders to local storage: $e');
    }
  }

  @override
  Future<void> clearOrders() async {
    await prefs.remove(_ordersStorageKey);
  }
}
