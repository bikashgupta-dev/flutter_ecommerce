import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/local_storage_service.dart';
import '../../../products/domain/entities/product.dart';
import '../../../products/presentation/providers/product_providers.dart';
import '../../data/datasources/wishlist_local_data_source.dart';

final wishlistLocalDataSourceProvider = Provider<WishlistLocalDataSource>((
  ref,
) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return WishlistLocalDataSourceImpl(prefs: prefs);
});

class WishlistNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    // Hydrate wishlist state from local persistence on build initialization
    Future.microtask(() => _hydrate());
    return const {};
  }

  Future<void> _hydrate() async {
    try {
      final localDataSource = ref.read(wishlistLocalDataSourceProvider);
      final savedIds = await localDataSource.getWishlistIds();
      if (savedIds.isNotEmpty) {
        state = savedIds;
      }
    } catch (_) {}
  }

  void _persistState() {
    ref.read(wishlistLocalDataSourceProvider).saveWishlistIds(state);
  }

  void toggleWishlist(String productId) {
    if (state.contains(productId)) {
      state = Set<String>.from(state)..remove(productId);
    } else {
      state = Set<String>.from(state)..add(productId);
    }
    _persistState();
  }

  void addToWishlist(String productId) {
    if (!state.contains(productId)) {
      state = Set<String>.from(state)..add(productId);
      _persistState();
    }
  }

  void removeFromWishlist(String productId) {
    if (state.contains(productId)) {
      state = Set<String>.from(state)..remove(productId);
      _persistState();
    }
  }

  void clearWishlist() {
    state = const {};
    ref.read(wishlistLocalDataSourceProvider).clearWishlist();
  }
}

final wishlistNotifierProvider =
    NotifierProvider<WishlistNotifier, Set<String>>(WishlistNotifier.new);

final isWishlistedProvider = Provider.family<bool, String>((ref, productId) {
  final wishlist = ref.watch(wishlistNotifierProvider);
  return wishlist.contains(productId);
});

final wishlistProductsProvider = Provider<List<Product>>((ref) {
  final wishlistIds = ref.watch(wishlistNotifierProvider);
  final asyncProducts = ref.watch(productsAsyncProvider);

  return asyncProducts.when(
    data: (products) =>
        products.where((product) => wishlistIds.contains(product.id)).toList(),
    loading: () => const [],
    error: (err, stack) => const [],
  );
});
