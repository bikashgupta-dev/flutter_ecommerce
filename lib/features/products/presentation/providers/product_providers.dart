import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../data/datasources/product_local_data_source.dart';
import '../../data/datasources/product_remote_data_source.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../widgets/product_sort_sheet.dart';

/// Centralized Dio Client Provider
final dioProvider = Provider<Dio>((ref) {
  return DioClient.createDio();
});

/// Remote Data Source Provider
final productRemoteDataSourceProvider = Provider<ProductRemoteDataSource>((
  ref,
) {
  return ProductRemoteDataSourceImpl(dio: ref.watch(dioProvider));
});

/// Local Data Source Provider
final productLocalDataSourceProvider = Provider<ProductLocalDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ProductLocalDataSourceImpl(prefs: prefs);
});

/// Product Repository Provider
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(
    remoteDataSource: ref.watch(productRemoteDataSourceProvider),
    localDataSource: ref.watch(productLocalDataSourceProvider),
  );
});

/// Async FutureProvider fetching products from REST API / Local Cache
final productsAsyncProvider = FutureProvider<List<Product>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getProducts();
});

/// Async FutureProvider.family fetching a single product by ID
final productDetailsAsyncProvider = FutureProvider.family<Product, String>((
  ref,
  id,
) async {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getProductById(id);
});

/// Derived AsyncValue provider for Featured Products on Home screen
final featuredProductsAsyncProvider = Provider<AsyncValue<List<Product>>>((
  ref,
) {
  final asyncProducts = ref.watch(productsAsyncProvider);
  return asyncProducts.whenData((products) => products.take(6).toList());
});

/// Immutable state model representing all product catalog browsing controls
class ProductCatalogState {
  final String searchQuery;
  final String? category;
  final double minPrice;
  final double maxPrice;
  final double minRating;
  final bool onlyInStock;
  final ProductSortOption sortOption;

  const ProductCatalogState({
    this.searchQuery = '',
    this.category,
    this.minPrice = 0,
    this.maxPrice = 50000,
    this.minRating = 0,
    this.onlyInStock = false,
    this.sortOption = ProductSortOption.featured,
  });

  bool get isFiltered =>
      category != null ||
      minPrice > 0 ||
      maxPrice < 50000 ||
      minRating > 0 ||
      onlyInStock;

  bool get isDefault =>
      searchQuery.isEmpty &&
      !isFiltered &&
      sortOption == ProductSortOption.featured;

  ProductCatalogState copyWith({
    String? searchQuery,
    String? category,
    bool clearCategory = false,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    bool? onlyInStock,
    ProductSortOption? sortOption,
  }) {
    return ProductCatalogState(
      searchQuery: searchQuery ?? this.searchQuery,
      category: clearCategory ? null : (category ?? this.category),
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minRating: minRating ?? this.minRating,
      onlyInStock: onlyInStock ?? this.onlyInStock,
      sortOption: sortOption ?? this.sortOption,
    );
  }
}

/// Notifier managing catalog search, filter, and sort state updates
class ProductCatalogNotifier extends Notifier<ProductCatalogState> {
  @override
  ProductCatalogState build() => const ProductCatalogState();

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setCategory(String? category) {
    if (category == null) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(category: category);
    }
  }

  void updateFilterCriteria({
    String? category,
    required double minPrice,
    required double maxPrice,
    required double minRating,
    required bool onlyInStock,
  }) {
    state = state.copyWith(
      category: category,
      clearCategory: category == null,
      minPrice: minPrice,
      maxPrice: maxPrice,
      minRating: minRating,
      onlyInStock: onlyInStock,
    );
  }

  void setSortOption(ProductSortOption option) {
    state = state.copyWith(sortOption: option);
  }

  void resetSearchAndFilters() {
    state = const ProductCatalogState();
  }
}

/// NotifierProvider for ProductCatalogNotifier
final productCatalogNotifierProvider =
    NotifierProvider<ProductCatalogNotifier, ProductCatalogState>(
      ProductCatalogNotifier.new,
    );

/// Derived AsyncValue Provider applying search, filters, and sorting to API products
final filteredProductsAsyncProvider = Provider<AsyncValue<List<Product>>>((
  ref,
) {
  final asyncProducts = ref.watch(productsAsyncProvider);
  final catalogState = ref.watch(productCatalogNotifierProvider);

  return asyncProducts.whenData((allProducts) {
    // 1. Search Filter
    Iterable<Product> result = allProducts;
    if (catalogState.searchQuery.isNotEmpty) {
      final query = catalogState.searchQuery.toLowerCase();
      result = result.where(
        (p) =>
            p.name.toLowerCase().contains(query) ||
            p.category.toLowerCase().contains(query) ||
            (p.brand != null && p.brand!.toLowerCase().contains(query)),
      );
    }

    // 2. Criteria Filtering
    result = result.where((p) {
      if (catalogState.category != null &&
          p.category.toLowerCase() != catalogState.category!.toLowerCase()) {
        return false;
      }
      if (p.price < catalogState.minPrice || p.price > catalogState.maxPrice) {
        return false;
      }
      if (p.rating < catalogState.minRating) {
        return false;
      }
      if (catalogState.onlyInStock && !p.isInStock) {
        return false;
      }
      return true;
    });

    final list = result.toList();

    // 3. Sorting
    switch (catalogState.sortOption) {
      case ProductSortOption.priceLowToHigh:
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case ProductSortOption.priceHighToLow:
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case ProductSortOption.rating:
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case ProductSortOption.featured:
        break;
    }

    return list;
  });
});
