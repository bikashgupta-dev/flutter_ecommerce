import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../domain/models/delivery_address.dart';
import '../providers/address_providers.dart';
import '../providers/checkout_provider.dart';
import '../widgets/address_card.dart';
import '../widgets/address_form_sheet.dart';

class AddressManagementPage extends ConsumerWidget {
  final bool isSelectionMode;

  const AddressManagementPage({super.key, this.isSelectionMode = true});

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    DeliveryAddress address,
  ) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text('Delete Address?'),
          content: Text(
            'Are you sure you want to delete the address for "${address.recipientName}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.of(dialogCtx).pop();
                await ref
                    .read(addressListNotifierProvider.notifier)
                    .deleteAddress(address.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Address deleted'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final addressState = ref.watch(addressListNotifierProvider);
    final checkoutState = ref.watch(checkoutNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isSelectionMode ? 'Select Address' : 'Addresses'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/checkout');
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_location_alt_outlined),
            tooltip: 'Add New Address',
            onPressed: () => AddressFormSheet.show(context),
          ),
        ],
      ),
      body: SafeArea(
        child: addressState.when(
          data: (addresses) {
            if (addresses.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_off_outlined,
                        size: 72,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'No Addresses Saved',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Add a delivery address to proceed with checkout.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      ElevatedButton.icon(
                        onPressed: () => AddressFormSheet.show(context),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Add New Address'),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: addresses.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final address = addresses[index];
                final isSelected =
                    checkoutState.selectedAddress?.id == address.id;

                return AddressCard(
                  address: address,
                  isSelected: isSelected,
                  onSelect: () {
                    ref
                        .read(checkoutNotifierProvider.notifier)
                        .selectAddress(address);
                    if (isSelectionMode && context.canPop()) {
                      context.pop();
                    }
                  },
                  onEdit: () =>
                      AddressFormSheet.show(context, initialAddress: address),
                  onDelete: () =>
                      _showDeleteConfirmation(context, ref, address),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Failed to load addresses: $err'),
                  const SizedBox(height: AppSpacing.sm),
                  ElevatedButton(
                    onPressed: () => ref
                        .read(addressListNotifierProvider.notifier)
                        .refresh(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(top: BorderSide(color: colorScheme.outline)),
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () => AddressFormSheet.show(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'Add New Address',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
