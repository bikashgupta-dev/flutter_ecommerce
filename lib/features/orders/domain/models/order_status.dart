import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

enum OrderStatus {
  placed,
  confirmed,
  shipped,
  delivered,
  cancelled;

  String get displayName {
    switch (this) {
      case OrderStatus.placed:
        return 'Placed';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.placed:
        return AppColors.primary;
      case OrderStatus.confirmed:
        return const Color(0xFF0284C7); // Light blue
      case OrderStatus.shipped:
        return AppColors.warning;
      case OrderStatus.delivered:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.error;
    }
  }

  IconData get icon {
    switch (this) {
      case OrderStatus.placed:
        return Icons.shopping_bag_outlined;
      case OrderStatus.confirmed:
        return Icons.verified_outlined;
      case OrderStatus.shipped:
        return Icons.local_shipping_outlined;
      case OrderStatus.delivered:
        return Icons.check_circle_outline_rounded;
      case OrderStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }

  /// Sensible simulated next transitions for demo purposes
  List<OrderStatus> get allowedNextTransitions {
    switch (this) {
      case OrderStatus.placed:
        return const [OrderStatus.confirmed, OrderStatus.cancelled];
      case OrderStatus.confirmed:
        return const [OrderStatus.shipped, OrderStatus.cancelled];
      case OrderStatus.shipped:
        return const [OrderStatus.delivered];
      case OrderStatus.delivered:
      case OrderStatus.cancelled:
        return const [];
    }
  }
}
