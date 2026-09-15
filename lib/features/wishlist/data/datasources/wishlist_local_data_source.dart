import 'package:shared_preferences/shared_preferences.dart';

abstract class WishlistLocalDataSource {
  Future<Set<String>> getWishlistIds();
  Future<void> saveWishlistIds(Set<String> ids);
  Future<void> clearWishlist();
}

class WishlistLocalDataSourceImpl implements WishlistLocalDataSource {
  static const String _wishlistStorageKey = 'persisted_wishlist_ids_v1';
  final SharedPreferences prefs;

  WishlistLocalDataSourceImpl({required this.prefs});

  @override
  Future<Set<String>> getWishlistIds() async {
    try {
      final list = prefs.getStringList(_wishlistStorageKey);
      if (list == null || list.isEmpty) {
        return const {};
      }
      return list.toSet();
    } catch (_) {
      return const {};
    }
  }

  @override
  Future<void> saveWishlistIds(Set<String> ids) async {
    try {
      await prefs.setStringList(_wishlistStorageKey, ids.toList());
    } catch (_) {
      // Safely ignore storage errors
    }
  }

  @override
  Future<void> clearWishlist() async {
    await prefs.remove(_wishlistStorageKey);
  }
}
