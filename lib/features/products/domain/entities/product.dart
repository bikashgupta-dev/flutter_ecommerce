class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final int? discountPercentage;
  final String category;
  final String? brand;
  final double rating;
  final int? reviewCount;
  final List<String> images;
  final List<String>? availableSizes;
  final List<String>? availableColors;
  final bool isInStock;
  final DateTime? createdAt;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    this.discountPercentage,
    required this.category,
    this.brand,
    required this.rating,
    this.reviewCount,
    required this.images,
    this.availableSizes,
    this.availableColors,
    required this.isInStock,
    this.createdAt,
  });
}
