enum PaymentMethodType {
  mockOnlinePayment,
  cashOnDelivery;

  String get displayName {
    switch (this) {
      case PaymentMethodType.mockOnlinePayment:
        return 'Mock Online Payment';
      case PaymentMethodType.cashOnDelivery:
        return 'Cash on Delivery (COD)';
    }
  }

  String get subtitle {
    switch (this) {
      case PaymentMethodType.mockOnlinePayment:
        return 'Simulated UPI, Card & NetBanking (No actual charge)';
      case PaymentMethodType.cashOnDelivery:
        return 'Pay in cash upon simulated delivery';
    }
  }

  bool get isSimulatedOnline => this == PaymentMethodType.mockOnlinePayment;
}

enum PaymentStatus {
  pending,
  simulatedSuccess,
  cashOnDelivery,
  failed;

  String get displayName {
    switch (this) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.simulatedSuccess:
        return 'Simulated Success';
      case PaymentStatus.cashOnDelivery:
        return 'Cash On Delivery';
      case PaymentStatus.failed:
        return 'Failed';
    }
  }
}
