import '../../../products/domain/entities/product.dart';

class CartItem {
  final Product product;
  final int quantity;

  const CartItem({required this.product, required this.quantity});

  double get totalPrice => product.price * quantity;

  double get totalOriginalPrice =>
      (product.originalPrice ?? product.price) * quantity;

  double get totalDiscount => totalOriginalPrice - totalPrice;

  CartItem copyWith({Product? product, int? quantity}) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}
