import '../../../../core/network/network_exceptions.dart';
import '../../domain/entities/product.dart';

class ProductDto {
  /// Development conversion constant for converting USD API prices to INR display.
  static const double usdToInrRate = 80.0;

  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final String? brand;
  final String? thumbnail;
  final List<String> images;

  const ProductDto({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    this.brand,
    this.thumbnail,
    required this.images,
  });

  factory ProductDto.fromJson(Map<String, dynamic> json) {
    // 1. Strict ID validation
    final rawId = json['id'];
    final parsedId = rawId is int
        ? rawId
        : int.tryParse(rawId?.toString() ?? '');
    if (parsedId == null) {
      throw const ParseException('Invalid or missing product ID.');
    }

    // 2. Strict Title validation
    final rawTitle = json['title']?.toString();
    if (rawTitle == null || rawTitle.trim().isEmpty) {
      throw const ParseException('Invalid or missing product title.');
    }

    // 3. Strict Price validation
    final rawPrice = (json['price'] as num?)?.toDouble();
    if (rawPrice == null) {
      throw const ParseException('Invalid or missing product price.');
    }

    List<String> parsedImages = [];
    if (json['images'] is List) {
      parsedImages = (json['images'] as List)
          .map((img) => img.toString())
          .where((img) => img.isNotEmpty)
          .toList();
    }
    if (parsedImages.isEmpty && json['thumbnail'] != null) {
      parsedImages = [json['thumbnail'].toString()];
    }

    return ProductDto(
      id: parsedId,
      title: rawTitle.trim(),
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? 'General',
      price: rawPrice,
      discountPercentage:
          (json['discountPercentage'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      brand: json['brand']?.toString(),
      thumbnail: json['thumbnail']?.toString(),
      images: parsedImages,
    );
  }

  /// Maps DTO to application domain Product entity
  Product toDomain() {
    final formattedCategory = category.isNotEmpty
        ? category[0].toUpperCase() + category.substring(1)
        : 'General';

    // Convert API price into INR using development conversion constant
    final inrPrice = (price * usdToInrRate).roundToDouble();
    final double? inrOriginalPrice = discountPercentage > 0
        ? ((price / (1 - (discountPercentage / 100))) * usdToInrRate)
              .roundToDouble()
        : null;

    final formattedDiscount = discountPercentage > 0
        ? discountPercentage.round()
        : null;

    return Product(
      id: 'prod-$id',
      name: title,
      description: description,
      price: inrPrice > 0 ? inrPrice : 499,
      originalPrice: inrOriginalPrice,
      discountPercentage: formattedDiscount,
      category: formattedCategory,
      brand: (brand != null && brand!.trim().isNotEmpty) ? brand!.trim() : null,
      rating: rating,
      reviewCount: null, // Omit fake review count; API does not supply it
      images: images.isNotEmpty
          ? images
          : const [
              'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=800&q=80',
            ],
      isInStock: stock > 0,
      createdAt: null, // Omit fake creation timestamp
    );
  }
}
