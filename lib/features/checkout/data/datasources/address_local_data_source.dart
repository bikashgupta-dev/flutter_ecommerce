import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/delivery_address.dart';

abstract class AddressLocalDataSource {
  Future<List<DeliveryAddress>> getAddresses();
  Future<void> saveAddresses(List<DeliveryAddress> addresses);
  Future<void> clearAddresses();
}

class AddressLocalDataSourceImpl implements AddressLocalDataSource {
  static const String _addressStorageKey = 'persisted_delivery_addresses_v1';
  final SharedPreferences prefs;

  AddressLocalDataSourceImpl({required this.prefs});

  @override
  Future<List<DeliveryAddress>> getAddresses() async {
    try {
      final jsonList = prefs.getStringList(_addressStorageKey);
      if (jsonList == null || jsonList.isEmpty) {
        return const [];
      }
      final List<DeliveryAddress> list = [];
      for (final str in jsonList) {
        try {
          final Map<String, dynamic> jsonMap = json.decode(str);
          list.add(DeliveryAddress.fromJson(jsonMap));
        } catch (_) {
          // Gracefully skip single corrupted address entry
        }
      }
      return list;
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<void> saveAddresses(List<DeliveryAddress> addresses) async {
    try {
      final jsonList = addresses.map((a) => json.encode(a.toJson())).toList();
      await prefs.setStringList(_addressStorageKey, jsonList);
    } catch (e) {
      throw Exception('Failed to persist delivery addresses locally.');
    }
  }

  @override
  Future<void> clearAddresses() async {
    await prefs.remove(_addressStorageKey);
  }
}
