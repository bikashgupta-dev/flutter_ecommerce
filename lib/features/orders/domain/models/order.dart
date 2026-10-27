import 'dart:math';

import '../../../checkout/domain/models/delivery_address.dart';
import 'order_item.dart';
import 'order_status.dart';
import 'payment_method.dart';

class Order {
  final String id;
  final DateTime createdAt;
  final List<OrderItem> items;
  final DeliveryAddress deliveryAddress;
  final PaymentMethodType paymentMethod;
  final PaymentStatus paymentStatus;
  final OrderStatus orderStatus;
  final double subtotal;
  final double discount;
  final double deliveryCharge;
  final double total;

  const Order({
    required this.id,
    required this.createdAt,
    required this.items,
    required this.deliveryAddress,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.orderStatus,
    required this.subtotal,
    required this.discount,
    required this.deliveryCharge,
    required this.total,
  });

  int get totalItemCount => items.fold(0, (sum, item) => sum + item.quantity);

  /// Generates a reliable, collision-safe demo order ID
  static String generateOrderId() {
    final now = DateTime.now();
    final year = now.year.toString();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final hours = now.hour.toString().padLeft(2, '0');
    final mins = now.minute.toString().padLeft(2, '0');
    final secs = now.second.toString().padLeft(2, '0');
    final rand = (Random().nextInt(9000) + 1000).toString();

    return 'ORD-$year$month$day-$hours$mins$secs-$rand';
  }

  Order copyWith({
    String? id,
    DateTime? createdAt,
    List<OrderItem>? items,
    DeliveryAddress? deliveryAddress,
    PaymentMethodType? paymentMethod,
    PaymentStatus? paymentStatus,
    OrderStatus? orderStatus,
    double? subtotal,
    double? discount,
    double? deliveryCharge,
    double? total,
  }) {
    return Order(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      orderStatus: orderStatus ?? this.orderStatus,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      deliveryCharge: deliveryCharge ?? this.deliveryCharge,
      total: total ?? this.total,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'items': items.map((i) => i.toJson()).toList(),
      'deliveryAddress': deliveryAddress.toJson(),
      'paymentMethod': paymentMethod.name,
      'paymentStatus': paymentStatus.name,
      'orderStatus': orderStatus.name,
      'subtotal': subtotal,
      'discount': discount,
      'deliveryCharge': deliveryCharge,
      'total': total,
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    // Graceful parsing with defaults
    final id = json['id']?.toString() ?? '';
    final createdAt =
        DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
        DateTime.now();

    final List<OrderItem> items = [];
    if (json['items'] is List) {
      for (final itemJson in (json['items'] as List)) {
        if (itemJson is Map<String, dynamic>) {
          items.add(OrderItem.fromJson(itemJson));
        }
      }
    }

    final deliveryAddress = json['deliveryAddress'] is Map<String, dynamic>
        ? DeliveryAddress.fromJson(
            json['deliveryAddress'] as Map<String, dynamic>,
          )
        : const DeliveryAddress(
            id: '',
            recipientName: '',
            phoneNumber: '',
            addressLine: '',
            locality: '',
            city: '',
            state: '',
            postalCode: '',
          );

    final paymentMethodName = json['paymentMethod']?.toString();
    final paymentMethod = PaymentMethodType.values.firstWhere(
      (m) => m.name == paymentMethodName,
      orElse: () => PaymentMethodType.mockOnlinePayment,
    );

    final paymentStatusName = json['paymentStatus']?.toString();
    final paymentStatus = PaymentStatus.values.firstWhere(
      (s) => s.name == paymentStatusName,
      orElse: () => PaymentStatus.simulatedSuccess,
    );

    final orderStatusName = json['orderStatus']?.toString();
    final orderStatus = OrderStatus.values.firstWhere(
      (s) => s.name == orderStatusName,
      orElse: () => OrderStatus.placed,
    );

    final subtotal = (json['subtotal'] as num?)?.toDouble() ?? 0.0;
    final discount = (json['discount'] as num?)?.toDouble() ?? 0.0;
    final deliveryCharge = (json['deliveryCharge'] as num?)?.toDouble() ?? 0.0;
    final total =
        (json['total'] as num?)?.toDouble() ?? (subtotal + deliveryCharge);

    return Order(
      id: id,
      createdAt: createdAt,
      items: items,
      deliveryAddress: deliveryAddress,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus,
      orderStatus: orderStatus,
      subtotal: subtotal,
      discount: discount,
      deliveryCharge: deliveryCharge,
      total: total,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Order && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
