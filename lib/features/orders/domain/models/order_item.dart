import '../../../cart/data/models/cart_item.dart';

class OrderItem {
  final String productId;
  final String productName;
  final String? imageUrl;
  final double unitPrice;
  final int quantity;
  final double? originalUnitPrice;
  final int? discountPercentage;

  const OrderItem({
    required this.productId,
    required this.productName,
    this.imageUrl,
    required this.unitPrice,
    required this.quantity,
    this.originalUnitPrice,
    this.discountPercentage,
  });

  /// Factory to capture an immutable snapshot from a CartItem at checkout time
  factory OrderItem.fromCartItem(CartItem cartItem) {
    return OrderItem(
      productId: cartItem.product.id,
      productName: cartItem.product.name,
      imageUrl: cartItem.product.images.isNotEmpty
          ? cartItem.product.images.first
          : null,
      unitPrice: cartItem.product.price,
      quantity: cartItem.quantity,
      originalUnitPrice: cartItem.product.originalPrice,
      discountPercentage: cartItem.product.discountPercentage,
    );
  }

  double get totalPrice => unitPrice * quantity;

  double get totalOriginalPrice => (originalUnitPrice ?? unitPrice) * quantity;

  double get totalDiscount => totalOriginalPrice - totalPrice;

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'imageUrl': imageUrl,
      'unitPrice': unitPrice,
      'quantity': quantity,
      'originalUnitPrice': originalUnitPrice,
      'discountPercentage': discountPercentage,
    };
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId']?.toString() ?? '',
      productName: json['productName']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString(),
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      originalUnitPrice: (json['originalUnitPrice'] as num?)?.toDouble(),
      discountPercentage: (json['discountPercentage'] as num?)?.toInt(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderItem &&
          runtimeType == other.runtimeType &&
          productId == other.productId &&
          productName == other.productName &&
          imageUrl == other.imageUrl &&
          unitPrice == other.unitPrice &&
          quantity == other.quantity &&
          originalUnitPrice == other.originalUnitPrice &&
          discountPercentage == other.discountPercentage;

  @override
  int get hashCode => Object.hash(
    productId,
    productName,
    imageUrl,
    unitPrice,
    quantity,
    originalUnitPrice,
    discountPercentage,
  );
}
