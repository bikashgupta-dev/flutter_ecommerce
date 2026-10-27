import 'package:flutter_ecommerce/core/storage/local_storage_service.dart';
import 'package:flutter_ecommerce/features/auth/data/repositories/mock_auth_repository_impl.dart';
import 'package:flutter_ecommerce/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  group('AuthNotifier', () {
    test('Successful login updates state to authenticated with user', () async {
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );

      final notifier = container.read(authNotifierProvider.notifier);
      final success = await notifier.login(
        email: MockAuthRepositoryImpl.demoEmail,
        password: MockAuthRepositoryImpl.demoPassword,
      );

      expect(success, isTrue);
      final state = container.read(authNotifierProvider);
      expect(state.isAuthenticated, isTrue);
      expect(state.user?.email, MockAuthRepositoryImpl.demoEmail);
      expect(state.errorMessage, isNull);
      expect(state.isLoading, isFalse);
    });

    test(
      'Failed login sets error message and leaves state unauthenticated',
      () async {
        final container = ProviderContainer(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        );

        final notifier = container.read(authNotifierProvider.notifier);
        final success = await notifier.login(
          email: MockAuthRepositoryImpl.demoEmail,
          password: 'IncorrectPassword',
        );

        expect(success, isFalse);
        final state = container.read(authNotifierProvider);
        expect(state.isAuthenticated, isFalse);
        expect(state.user, isNull);
        expect(state.errorMessage, contains('Invalid email or password'));
        expect(state.isLoading, isFalse);
      },
    );

    test(
      'Successful register updates state to authenticated with new user',
      () async {
        final container = ProviderContainer(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        );

        final notifier = container.read(authNotifierProvider.notifier);
        final success = await notifier.register(
          name: 'Karan Mehra',
          email: 'karan@example.com',
          password: 'Password999',
        );

        expect(success, isTrue);
        final state = container.read(authNotifierProvider);
        expect(state.isAuthenticated, isTrue);
        expect(state.user?.name, 'Karan Mehra');
        expect(state.user?.email, 'karan@example.com');
      },
    );

    test('Logout clears authenticated user and resets state', () async {
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );

      final notifier = container.read(authNotifierProvider.notifier);
      await notifier.login(
        email: MockAuthRepositoryImpl.demoEmail,
        password: MockAuthRepositoryImpl.demoPassword,
      );
      expect(container.read(authNotifierProvider).isAuthenticated, isTrue);

      await notifier.logout();
      final state = container.read(authNotifierProvider);
      expect(state.isAuthenticated, isFalse);
      expect(state.user, isNull);
    });

    test('Update profile updates user fields in state', () async {
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );

      final notifier = container.read(authNotifierProvider.notifier);
      await notifier.login(
        email: MockAuthRepositoryImpl.demoEmail,
        password: MockAuthRepositoryImpl.demoPassword,
      );

      final success = await notifier.updateProfile(
        name: 'Alexander Morgan',
        phoneNumber: '9876543211',
      );

      expect(success, isTrue);
      final state = container.read(authNotifierProvider);
      expect(state.user?.name, 'Alexander Morgan');
      expect(state.user?.phoneNumber, '9876543211');
    });
  });
}
