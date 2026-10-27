import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/delivery_address.dart';
import '../../../orders/domain/models/payment_method.dart';
import 'address_providers.dart';

class CheckoutState {
  final DeliveryAddress? selectedAddress;
  final PaymentMethodType selectedPaymentMethod;
  final bool isPlacingOrder;
  final String? errorMessage;

  const CheckoutState({
    this.selectedAddress,
    this.selectedPaymentMethod = PaymentMethodType.mockOnlinePayment,
    this.isPlacingOrder = false,
    this.errorMessage,
  });

  CheckoutState copyWith({
    DeliveryAddress? selectedAddress,
    PaymentMethodType? selectedPaymentMethod,
    bool? isPlacingOrder,
    String? errorMessage,
    bool clearAddress = false,
    bool clearError = false,
  }) {
    return CheckoutState(
      selectedAddress: clearAddress
          ? null
          : (selectedAddress ?? this.selectedAddress),
      selectedPaymentMethod:
          selectedPaymentMethod ?? this.selectedPaymentMethod,
      isPlacingOrder: isPlacingOrder ?? this.isPlacingOrder,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class CheckoutNotifier extends Notifier<CheckoutState> {
  @override
  CheckoutState build() {
    // Listen to address list to auto-select default address if none is selected
    ref.listen(addressListNotifierProvider, (previous, next) {
      next.whenData((addresses) {
        if (addresses.isEmpty) {
          if (state.selectedAddress != null) {
            state = state.copyWith(clearAddress: true);
          }
          return;
        }

        // If currently selected address was deleted, or no address is selected yet:
        final currentSelected = state.selectedAddress;
        if (currentSelected == null ||
            !addresses.any((a) => a.id == currentSelected.id)) {
          final defaultAddr = addresses.firstWhere(
            (a) => a.isDefault,
            orElse: () => addresses.first,
          );
          state = state.copyWith(selectedAddress: defaultAddr);
        } else {
          // Keep current selection updated with any edits
          final updated = addresses.firstWhere(
            (a) => a.id == currentSelected.id,
          );
          state = state.copyWith(selectedAddress: updated);
        }
      });
    }, fireImmediately: true);

    return const CheckoutState();
  }

  void selectAddress(DeliveryAddress address) {
    state = state.copyWith(selectedAddress: address, clearError: true);
  }

  void selectPaymentMethod(PaymentMethodType method) {
    state = state.copyWith(selectedPaymentMethod: method, clearError: true);
  }

  void setPlacingOrder(bool isPlacing) {
    state = state.copyWith(isPlacingOrder: isPlacing);
  }

  void setError(String? message) {
    state = state.copyWith(errorMessage: message);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void reset() {
    state = const CheckoutState();
  }
}

final checkoutNotifierProvider =
    NotifierProvider<CheckoutNotifier, CheckoutState>(CheckoutNotifier.new);
