class CartEntry {
  final String productId;
  final int quantity;

  const CartEntry({required this.productId, required this.quantity});

  Map<String, dynamic> toJson() {
    return {'productId': productId, 'quantity': quantity};
  }

  factory CartEntry.fromJson(Map<String, dynamic> json) {
    return CartEntry(
      productId: json['productId']?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );
  }
}
