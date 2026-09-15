import '../../domain/entities/product.dart';

class CachedProduct {
  final Product product;
  final DateTime cachedAt;

  const CachedProduct({required this.product, required this.cachedAt});

  bool isFresh(Duration maxAge) {
    return DateTime.now().difference(cachedAt) < maxAge;
  }

  Map<String, dynamic> toJson() {
    return {
      'cachedAt': cachedAt.toIso8601String(),
      'id': product.id,
      'name': product.name,
      'description': product.description,
      'price': product.price,
      'originalPrice': product.originalPrice,
      'discountPercentage': product.discountPercentage,
      'category': product.category,
      'brand': product.brand,
      'rating': product.rating,
      'reviewCount': product.reviewCount,
      'images': product.images,
      'availableSizes': product.availableSizes,
      'availableColors': product.availableColors,
      'isInStock': product.isInStock,
    };
  }

  factory CachedProduct.fromJson(Map<String, dynamic> json) {
    final cachedAt =
        DateTime.tryParse(json['cachedAt']?.toString() ?? '') ?? DateTime.now();

    final product = Product(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (json['originalPrice'] as num?)?.toDouble(),
      discountPercentage: (json['discountPercentage'] as num?)?.toInt(),
      category: json['category']?.toString() ?? 'General',
      brand: json['brand']?.toString(),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['reviewCount'] as num?)?.toInt(),
      images:
          (json['images'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      availableSizes: (json['availableSizes'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      availableColors: (json['availableColors'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      isInStock: json['isInStock'] as bool? ?? true,
    );

    return CachedProduct(product: product, cachedAt: cachedAt);
  }
}
