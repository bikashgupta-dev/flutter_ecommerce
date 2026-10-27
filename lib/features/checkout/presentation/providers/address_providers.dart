import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/local_storage_service.dart';
import '../../data/datasources/address_local_data_source.dart';
import '../../data/repositories/address_repository.dart';
import '../../domain/models/delivery_address.dart';

final addressLocalDataSourceProvider = Provider<AddressLocalDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AddressLocalDataSourceImpl(prefs: prefs);
});

final addressRepositoryProvider = Provider<AddressRepository>((ref) {
  final localDataSource = ref.watch(addressLocalDataSourceProvider);
  return AddressRepositoryImpl(localDataSource: localDataSource);
});

class AddressListNotifier extends AsyncNotifier<List<DeliveryAddress>> {
  @override
  Future<List<DeliveryAddress>> build() async {
    final repository = ref.read(addressRepositoryProvider);
    return await repository.getAddresses();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(addressRepositoryProvider);
      return await repository.getAddresses();
    });
  }

  Future<DeliveryAddress> saveAddress(DeliveryAddress address) async {
    final repository = ref.read(addressRepositoryProvider);
    final saved = await repository.saveAddress(address);
    await refresh();
    return saved;
  }

  Future<void> deleteAddress(String addressId) async {
    final repository = ref.read(addressRepositoryProvider);
    await repository.deleteAddress(addressId);
    await refresh();
  }

  Future<void> setDefaultAddress(String addressId) async {
    final repository = ref.read(addressRepositoryProvider);
    await repository.setDefaultAddress(addressId);
    await refresh();
  }
}

final addressListNotifierProvider =
    AsyncNotifierProvider<AddressListNotifier, List<DeliveryAddress>>(
      AddressListNotifier.new,
    );
