import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/product.dart';
import '../models/cached_product.dart';

abstract class ProductLocalDataSource {
  Future<List<CachedProduct>> getCachedProducts();
  Future<void> saveCachedProducts(List<Product> products);
  Future<CachedProduct?> getCachedProductById(String id);
  Future<void> clearCache();
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  static const String _cachedProductsKey = 'cached_products_v1';
  final SharedPreferences prefs;

  ProductLocalDataSourceImpl({required this.prefs});

  @override
  Future<List<CachedProduct>> getCachedProducts() async {
    try {
      final jsonStringList = prefs.getStringList(_cachedProductsKey);
      if (jsonStringList == null || jsonStringList.isEmpty) {
        return const [];
      }
      return jsonStringList.map((str) {
        final Map<String, dynamic> jsonMap = json.decode(str);
        return CachedProduct.fromJson(jsonMap);
      }).toList();
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<void> saveCachedProducts(List<Product> products) async {
    try {
      final now = DateTime.now();
      final jsonStringList = products.map((product) {
        final cached = CachedProduct(product: product, cachedAt: now);
        return json.encode(cached.toJson());
      }).toList();
      await prefs.setStringList(_cachedProductsKey, jsonStringList);
    } catch (_) {
      // Ignore cache save errors to prevent breaking runtime execution
    }
  }

  @override
  Future<CachedProduct?> getCachedProductById(String id) async {
    final allCached = await getCachedProducts();
    return allCached.cast<CachedProduct?>().firstWhere(
      (item) => item?.product.id == id,
      orElse: () => null,
    );
  }

  @override
  Future<void> clearCache() async {
    await prefs.remove(_cachedProductsKey);
  }
}
