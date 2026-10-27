import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../orders/domain/models/order_pricing_calculator.dart';
import '../../../orders/presentation/providers/order_providers.dart';
import '../providers/address_providers.dart';
import '../providers/checkout_provider.dart';
import '../widgets/address_card.dart';
import '../widgets/address_form_sheet.dart';
import '../widgets/order_items_preview.dart';
import '../widgets/order_pricing_card.dart';
import '../widgets/payment_method_selector.dart';

class CheckoutPage extends ConsumerWidget {
  const CheckoutPage({super.key});

  Future<void> _handlePlaceOrder(BuildContext context, WidgetRef ref) async {
    final controller = ref.read(orderPlacementControllerProvider);
    final order = await controller.placeOrder();

    if (order != null && context.mounted) {
      // Seamlessly navigate to order confirmation
      context.go('/checkout/success/${order.id}');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final cartState = ref.watch(cartNotifierProvider);
    final checkoutState = ref.watch(checkoutNotifierProvider);
    final addressState = ref.watch(addressListNotifierProvider);

    final selectedAddress =
        checkoutState.selectedAddress ??
        (addressState.value?.isNotEmpty == true
            ? addressState.value!.firstWhere(
                (a) => a.isDefault,
                orElse: () => addressState.value!.first,
              )
            : null);

    // Authoritative calculation from cart items
    final pricing = OrderPricingCalculator.calculateFromCart(cartState.items);
    final hasAddress = selectedAddress != null;
    final canPlaceOrder =
        !cartState.isEmpty && hasAddress && !checkoutState.isPlacingOrder;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back to Cart',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/cart');
            }
          },
        ),
      ),
      body: SafeArea(
        child: cartState.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 72,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Your cart is empty',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Add items to your cart to proceed with checkout.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ElevatedButton(
                        onPressed: () => context.go('/products'),
                        child: const Text('Browse Catalog'),
                      ),
                    ],
                  ),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Error Banner
                    if (checkoutState.errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.error.withAlpha(20),
                          borderRadius: BorderRadius.circular(AppSpacing.xs),
                          border: Border.all(color: AppColors.error),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: AppColors.error,
                              size: 20,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: Text(
                                checkoutState.errorMessage!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded, size: 16),
                              color: AppColors.error,
                              tooltip: 'Dismiss',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => ref
                                  .read(checkoutNotifierProvider.notifier)
                                  .clearError(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],

                    // User / Guest status indicator
                    Builder(
                      builder: (context) {
                        final currentUser = ref.watch(currentUserProvider);
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(AppSpacing.xs),
                            border: Border.all(color: colorScheme.outline),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                currentUser != null
                                    ? Icons.account_circle_outlined
                                    : Icons.person_outline_rounded,
                                size: 18,
                                color: currentUser != null
                                    ? AppColors.primary
                                    : colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Expanded(
                                child: Text(
                                  currentUser != null
                                      ? 'Signed in as ${currentUser.name}'
                                      : 'Checking out as Guest',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (currentUser == null)
                                TextButton(
                                  onPressed: () => context.push('/login'),
                                  style: TextButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: const Text(
                                    'Sign In',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Section 1: Delivery Address
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '1. Delivery Address',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.push('/checkout/addresses'),
                          child: Text(
                            hasAddress ? 'Change' : 'Select / Add',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    if (selectedAddress != null)
                      AddressCard(
                        address: selectedAddress,
                        isSelected: true,
                        showActions: false,
                        onSelect: () => context.push('/checkout/addresses'),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(AppSpacing.md),
                          border: Border.all(
                            color: AppColors.error.withAlpha(80),
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.location_off_outlined,
                              size: 36,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'No delivery address selected',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            ElevatedButton.icon(
                              onPressed: () {
                                addressState.whenData((addresses) {
                                  if (addresses.isEmpty) {
                                    AddressFormSheet.show(context);
                                  } else {
                                    context.push('/checkout/addresses');
                                  }
                                });
                              },
                              icon: const Icon(Icons.add_location_alt_outlined),
                              label: const Text('Add Delivery Address'),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: AppSpacing.lg),

                    // Section 2: Payment Method
                    Text(
                      '2. Payment Option',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    PaymentMethodSelector(
                      selectedMethod: checkoutState.selectedPaymentMethod,
                      onMethodSelected: (method) => ref
                          .read(checkoutNotifierProvider.notifier)
                          .selectPaymentMethod(method),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Section 3: Order Items Summary
                    Text(
                      '3. Review Order Items',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    OrderItemsPreview(items: cartState.items),

                    const SizedBox(height: AppSpacing.lg),

                    // Section 4: Price Breakdown
                    OrderPricingCard(
                      pricing: pricing,
                      totalItemCount: cartState.totalItemCount,
                    ),

                    const SizedBox(
                      height: 100,
                    ), // Spacing for sticky bottom button
                  ],
                ),
              ),
      ),
      bottomNavigationBar: cartState.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border(top: BorderSide(color: colorScheme.outline)),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Amount',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            '₹${pricing.total.toInt()}',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: canPlaceOrder
                              ? () => _handlePlaceOrder(context, ref)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: checkoutState.isPlacingOrder
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Place Order',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
