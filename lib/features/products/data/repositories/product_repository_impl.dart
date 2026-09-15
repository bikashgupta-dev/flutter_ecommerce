import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_local_data_source.dart';
import '../datasources/product_remote_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  /// Configurable product cache freshness duration (30 minutes)
  static const Duration productCacheDuration = Duration(minutes: 30);

  final ProductRemoteDataSource remoteDataSource;
  final ProductLocalDataSource localDataSource;

  ProductRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<Product>> getProducts() async {
    // 1. Check Local Cache
    final cachedItems = await localDataSource.getCachedProducts();
    final hasCache = cachedItems.isNotEmpty;
    final isCacheFresh =
        hasCache &&
        cachedItems.every((item) => item.isFresh(productCacheDuration));

    // 2. Return fresh cache directly if available
    if (hasCache && isCacheFresh) {
      return cachedItems.map((item) => item.product).toList();
    }

    // 3. Attempt Remote API Fetch
    try {
      final dtos = await remoteDataSource.getProducts();
      final products = dtos.map((dto) => dto.toDomain()).toList();

      // Save/update local cache upon valid API response
      if (products.isNotEmpty) {
        await localDataSource.saveCachedProducts(products);
      }

      return products;
    } catch (e) {
      // 4. Offline Fallback: Return stale cache if API fails and cache exists
      if (hasCache) {
        return cachedItems.map((item) => item.product).toList();
      }
      rethrow;
    }
  }

  @override
  Future<Product> getProductById(String id) async {
    try {
      final dto = await remoteDataSource.getProductById(id);
      final product = dto.toDomain();
      return product;
    } catch (e) {
      // Offline Fallback for Product Details
      final cachedItem = await localDataSource.getCachedProductById(id);
      if (cachedItem != null) {
        return cachedItem.product;
      }
      rethrow;
    }
  }
}
