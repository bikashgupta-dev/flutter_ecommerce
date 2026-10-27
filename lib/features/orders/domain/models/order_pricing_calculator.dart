import '../../../cart/data/models/cart_item.dart';
import 'order_item.dart';

class OrderPricing {
  final double subtotal;
  final double discount;
  final double deliveryCharge;
  final double total;
  final bool isFreeDelivery;
  final double freeDeliveryThreshold;

  const OrderPricing({
    required this.subtotal,
    required this.discount,
    required this.deliveryCharge,
    required this.total,
    required this.isFreeDelivery,
    required this.freeDeliveryThreshold,
  });

  /// Amount remaining before qualifying for free delivery
  double get amountNeededForFreeDelivery {
    if (isFreeDelivery || subtotal <= 0) return 0;
    return (freeDeliveryThreshold - subtotal).clamp(0, freeDeliveryThreshold);
  }
}

abstract class OrderPricingCalculator {
  /// Threshold above which delivery is free of charge
  static const double freeDeliveryThreshold = 999.0;

  /// Standard flat delivery charge when below the threshold
  static const double standardDeliveryCharge = 49.0;

  /// Calculates authoritative pricing from current CartItems
  static OrderPricing calculateFromCart(List<CartItem> items) {
    if (items.isEmpty) {
      return const OrderPricing(
        subtotal: 0.0,
        discount: 0.0,
        deliveryCharge: 0.0,
        total: 0.0,
        isFreeDelivery: false,
        freeDeliveryThreshold: freeDeliveryThreshold,
      );
    }

    double subtotalAcc = 0.0;
    double discountAcc = 0.0;

    for (final item in items) {
      final itemPrice = item.product.price;
      final originalPrice = item.product.originalPrice ?? itemPrice;
      final quantity = item.quantity;

      subtotalAcc += itemPrice * quantity;
      if (originalPrice > itemPrice) {
        discountAcc += (originalPrice - itemPrice) * quantity;
      }
    }

    // Decimal-safe rounding to prevent precision errors
    final roundedSubtotal = (subtotalAcc * 100).round() / 100.0;
    final roundedDiscount = (discountAcc * 100).round() / 100.0;

    final isFreeDelivery = roundedSubtotal >= freeDeliveryThreshold;
    final deliveryCharge = isFreeDelivery ? 0.0 : standardDeliveryCharge;
    final total = ((roundedSubtotal + deliveryCharge) * 100).round() / 100.0;

    return OrderPricing(
      subtotal: roundedSubtotal,
      discount: roundedDiscount,
      deliveryCharge: deliveryCharge,
      total: total,
      isFreeDelivery: isFreeDelivery,
      freeDeliveryThreshold: freeDeliveryThreshold,
    );
  }

  /// Calculates authoritative pricing from snapshot OrderItems
  static OrderPricing calculateFromOrderItems(List<OrderItem> items) {
    if (items.isEmpty) {
      return const OrderPricing(
        subtotal: 0.0,
        discount: 0.0,
        deliveryCharge: 0.0,
        total: 0.0,
        isFreeDelivery: false,
        freeDeliveryThreshold: freeDeliveryThreshold,
      );
    }

    double subtotalAcc = 0.0;
    double discountAcc = 0.0;

    for (final item in items) {
      subtotalAcc += item.totalPrice;
      discountAcc += item.totalDiscount;
    }

    final roundedSubtotal = (subtotalAcc * 100).round() / 100.0;
    final roundedDiscount = (discountAcc * 100).round() / 100.0;

    final isFreeDelivery = roundedSubtotal >= freeDeliveryThreshold;
    final deliveryCharge = isFreeDelivery ? 0.0 : standardDeliveryCharge;
    final total = ((roundedSubtotal + deliveryCharge) * 100).round() / 100.0;

    return OrderPricing(
      subtotal: roundedSubtotal,
      discount: roundedDiscount,
      deliveryCharge: deliveryCharge,
      total: total,
      isFreeDelivery: isFreeDelivery,
      freeDeliveryThreshold: freeDeliveryThreshold,
    );
  }
}
