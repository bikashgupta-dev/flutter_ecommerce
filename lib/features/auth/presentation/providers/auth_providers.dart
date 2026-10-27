import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/local_storage_service.dart';
import '../../data/datasources/auth_local_data_source.dart';
import '../../data/repositories/mock_auth_repository_impl.dart';
import '../../domain/models/auth_state.dart';
import '../../domain/models/user.dart';
import '../../domain/repositories/auth_repository.dart';

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AuthLocalDataSourceImpl(prefs: prefs);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final localDataSource = ref.watch(authLocalDataSourceProvider);
  return MockAuthRepositoryImpl(localDataSource: localDataSource);
});

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    // Attempt automatic session restoration on startup
    Future.microtask(() => restoreSession());
    return const AuthState();
  }

  Future<void> restoreSession() async {
    try {
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.restoreSession();
      if (user != null) {
        state = state.copyWith(user: user, isLoading: false);
      }
    } catch (_) {
      // Ignored during startup session restoration
    }
  }

  Future<bool> login({required String email, required String password}) async {
    if (state.isLoading) return false;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.login(email: email, password: password);
      state = AuthState(user: user, isLoading: false);
      return true;
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(isLoading: false, errorMessage: message);
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    if (state.isLoading) return false;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.register(
        name: name,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
      );
      state = AuthState(user: user, isLoading: false);
      return true;
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(isLoading: false, errorMessage: message);
      return false;
    }
  }

  Future<void> logout() async {
    final repository = ref.read(authRepositoryProvider);
    await repository.logout();
    state = const AuthState();
  }

  Future<bool> updateProfile({
    required String name,
    String? phoneNumber,
    String? avatarUrl,
  }) async {
    if (state.isLoading) return false;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final repository = ref.read(authRepositoryProvider);
      final updated = await repository.updateProfile(
        name: name,
        phoneNumber: phoneNumber,
        avatarUrl: avatarUrl,
      );
      state = AuthState(user: updated, isLoading: false);
      return true;
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(isLoading: false, errorMessage: message);
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authNotifierProvider).user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authNotifierProvider).isAuthenticated;
});
