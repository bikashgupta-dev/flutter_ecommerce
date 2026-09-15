import 'package:dio/dio.dart';

import '../../../../core/network/network_exceptions.dart';
import '../models/product_dto.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductDto>> getProducts();
  Future<ProductDto> getProductById(String id);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final Dio dio;

  ProductRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ProductDto>> getProducts() async {
    try {
      final response = await dio.get('/products');
      if (response.data is Map<String, dynamic> &&
          response.data['products'] is List) {
        final productsList = response.data['products'] as List;
        return productsList
            .map((json) => ProductDto.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw const ParseException('Unexpected products response format.');
      }
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } catch (e) {
      if (e is NetworkException) rethrow;
      throw NetworkException('Failed to load products: ${e.toString()}');
    }
  }

  @override
  Future<ProductDto> getProductById(String id) async {
    try {
      final cleanId = id.replaceFirst('prod-', '');
      final response = await dio.get('/products/$cleanId');
      if (response.data is Map<String, dynamic>) {
        return ProductDto.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw const ParseException(
          'Unexpected product details response format.',
        );
      }
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } catch (e) {
      if (e is NetworkException) rethrow;
      throw NetworkException('Failed to load product details: ${e.toString()}');
    }
  }
}
