import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart_entry.dart';

abstract class CartLocalDataSource {
  Future<List<CartEntry>> getCartEntries();
  Future<void> saveCartEntries(List<CartEntry> entries);
  Future<void> clearCart();
}

class CartLocalDataSourceImpl implements CartLocalDataSource {
  static const String _cartStorageKey = 'persisted_cart_entries_v1';
  final SharedPreferences prefs;

  CartLocalDataSourceImpl({required this.prefs});

  @override
  Future<List<CartEntry>> getCartEntries() async {
    try {
      final jsonList = prefs.getStringList(_cartStorageKey);
      if (jsonList == null || jsonList.isEmpty) {
        return const [];
      }
      return jsonList.map((str) {
        final Map<String, dynamic> jsonMap = json.decode(str);
        return CartEntry.fromJson(jsonMap);
      }).toList();
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<void> saveCartEntries(List<CartEntry> entries) async {
    try {
      final jsonList = entries.map((e) => json.encode(e.toJson())).toList();
      await prefs.setStringList(_cartStorageKey, jsonList);
    } catch (_) {
      // Safely ignore storage errors
    }
  }

  @override
  Future<void> clearCart() async {
    await prefs.remove(_cartStorageKey);
  }
}
