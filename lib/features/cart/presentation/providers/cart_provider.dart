import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/local_storage_service.dart';
import '../../../products/domain/entities/product.dart';
import '../../../products/presentation/providers/product_providers.dart';
import '../../data/datasources/cart_local_data_source.dart';
import '../../data/models/cart_entry.dart';
import '../../data/models/cart_item.dart';

final cartLocalDataSourceProvider = Provider<CartLocalDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return CartLocalDataSourceImpl(prefs: prefs);
});

class CartState {
  final List<CartItem> items;
  final bool isInitialized;

  const CartState({this.items = const [], this.isInitialized = false});

  int get totalItemCount => items.fold(0, (sum, item) => sum + item.quantity);
  int get uniqueItemCount => items.length;
  double get subtotal => items.fold(0, (sum, item) => sum + item.totalPrice);
  double get totalOriginalPrice =>
      items.fold(0, (sum, item) => sum + item.totalOriginalPrice);
  double get totalDiscount =>
      items.fold(0, (sum, item) => sum + item.totalDiscount);
  bool get isEmpty => items.isEmpty;

  CartState copyWith({List<CartItem>? items, bool? isInitialized}) {
    return CartState(
      items: items ?? this.items,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

class CartNotifier extends Notifier<CartState> {
  @override
  CartState build() {
    // Hydrate cart state from local persistence on build initialization
    Future.microtask(() => _hydrate());
    return const CartState();
  }

  Future<void> _hydrate() async {
    try {
      final localDataSource = ref.read(cartLocalDataSourceProvider);
      final savedEntries = await localDataSource.getCartEntries();

      if (savedEntries.isEmpty) {
        state = state.copyWith(isInitialized: true);
        return;
      }

      // Fetch products to resolve entries
      final repository = ref.read(productRepositoryProvider);
      final products = await repository.getProducts();

      final List<CartItem> hydratedItems = [];
      for (final entry in savedEntries) {
        final product = products.cast<Product?>().firstWhere(
          (p) => p?.id == entry.productId,
          orElse: () => null,
        );
        if (product != null) {
          hydratedItems.add(
            CartItem(product: product, quantity: entry.quantity),
          );
        }
      }

      state = CartState(items: hydratedItems, isInitialized: true);
    } catch (_) {
      state = state.copyWith(isInitialized: true);
    }
  }

  void _persistState() {
    final entries = state.items
        .map(
          (item) =>
              CartEntry(productId: item.product.id, quantity: item.quantity),
        )
        .toList();
    ref.read(cartLocalDataSourceProvider).saveCartEntries(entries);
  }

  void addToCart(Product product) {
    final existingIndex = state.items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex >= 0) {
      final updatedList = List<CartItem>.from(state.items);
      final currentItem = updatedList[existingIndex];
      updatedList[existingIndex] = currentItem.copyWith(
        quantity: currentItem.quantity + 1,
      );
      state = state.copyWith(items: updatedList);
    } else {
      state = state.copyWith(
        items: [
          ...state.items,
          CartItem(product: product, quantity: 1),
        ],
      );
    }
    _persistState();
  }

  void removeFromCart(String productId) {
    state = state.copyWith(
      items: state.items.where((item) => item.product.id != productId).toList(),
    );
    _persistState();
  }

  void increaseQuantity(String productId) {
    final index = state.items.indexWhere(
      (item) => item.product.id == productId,
    );
    if (index >= 0) {
      final updatedList = List<CartItem>.from(state.items);
      final currentItem = updatedList[index];
      updatedList[index] = currentItem.copyWith(
        quantity: currentItem.quantity + 1,
      );
      state = state.copyWith(items: updatedList);
      _persistState();
    }
  }

  void decreaseQuantity(String productId) {
    final index = state.items.indexWhere(
      (item) => item.product.id == productId,
    );
    if (index >= 0) {
      final currentItem = state.items[index];
      if (currentItem.quantity > 1) {
        final updatedList = List<CartItem>.from(state.items);
        updatedList[index] = currentItem.copyWith(
          quantity: currentItem.quantity - 1,
        );
        state = state.copyWith(items: updatedList);
        _persistState();
      }
    }
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) return;
    final index = state.items.indexWhere(
      (item) => item.product.id == productId,
    );
    if (index >= 0) {
      final updatedList = List<CartItem>.from(state.items);
      updatedList[index] = updatedList[index].copyWith(quantity: quantity);
      state = state.copyWith(items: updatedList);
      _persistState();
    }
  }

  void clearCart() {
    state = state.copyWith(items: const []);
    ref.read(cartLocalDataSourceProvider).clearCart();
  }
}

final cartNotifierProvider = NotifierProvider<CartNotifier, CartState>(
  CartNotifier.new,
);

final cartItemCountProvider = Provider<int>((ref) {
  return ref.watch(cartNotifierProvider).totalItemCount;
});
