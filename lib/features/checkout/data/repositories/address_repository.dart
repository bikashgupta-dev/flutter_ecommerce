import 'dart:math';

import '../../domain/models/delivery_address.dart';
import '../datasources/address_local_data_source.dart';

abstract class AddressRepository {
  Future<List<DeliveryAddress>> getAddresses();
  Future<DeliveryAddress> saveAddress(DeliveryAddress address);
  Future<void> deleteAddress(String addressId);
  Future<void> setDefaultAddress(String addressId);
  Future<DeliveryAddress?> getDefaultAddress();
}

class AddressRepositoryImpl implements AddressRepository {
  final AddressLocalDataSource localDataSource;

  AddressRepositoryImpl({required this.localDataSource});

  @override
  Future<List<DeliveryAddress>> getAddresses() async {
    return await localDataSource.getAddresses();
  }

  @override
  Future<DeliveryAddress> saveAddress(DeliveryAddress address) async {
    final currentAddresses = await localDataSource.getAddresses();
    final List<DeliveryAddress> updatedList = List.from(currentAddresses);

    // If ID is empty, generate a unique ID
    String targetId = address.id;
    if (targetId.trim().isEmpty) {
      final rand = (Random().nextInt(9000) + 1000).toString();
      targetId = 'ADDR-${DateTime.now().millisecondsSinceEpoch}-$rand';
    }

    // If this is the only address, make it default automatically
    final shouldBeDefault = address.isDefault || currentAddresses.isEmpty;

    final targetAddress = address.copyWith(
      id: targetId,
      isDefault: shouldBeDefault,
    );

    final existingIndex = updatedList.indexWhere((a) => a.id == targetId);

    if (shouldBeDefault) {
      // Unset default flag on all others
      for (int i = 0; i < updatedList.length; i++) {
        if (updatedList[i].id != targetId && updatedList[i].isDefault) {
          updatedList[i] = updatedList[i].copyWith(isDefault: false);
        }
      }
    }

    if (existingIndex >= 0) {
      updatedList[existingIndex] = targetAddress;
    } else {
      updatedList.add(targetAddress);
    }

    await localDataSource.saveAddresses(updatedList);
    return targetAddress;
  }

  @override
  Future<void> deleteAddress(String addressId) async {
    final currentAddresses = await localDataSource.getAddresses();
    final wasDefault = currentAddresses.any(
      (a) => a.id == addressId && a.isDefault,
    );

    final updatedList = currentAddresses
        .where((a) => a.id != addressId)
        .toList();

    // If we deleted the default address and there are remaining addresses, set the first one as default
    if (wasDefault && updatedList.isNotEmpty) {
      updatedList[0] = updatedList[0].copyWith(isDefault: true);
    }

    await localDataSource.saveAddresses(updatedList);
  }

  @override
  Future<void> setDefaultAddress(String addressId) async {
    final currentAddresses = await localDataSource.getAddresses();
    final updatedList = currentAddresses.map((a) {
      return a.copyWith(isDefault: a.id == addressId);
    }).toList();

    await localDataSource.saveAddresses(updatedList);
  }

  @override
  Future<DeliveryAddress?> getDefaultAddress() async {
    final addresses = await getAddresses();
    if (addresses.isEmpty) return null;
    return addresses.firstWhere(
      (a) => a.isDefault,
      orElse: () => addresses.first,
    );
  }
}
