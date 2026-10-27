import '../models/user.dart';

abstract class AuthRepository {
  /// Returns currently authenticated user if present in memory/session
  Future<User?> getCurrentUser();

  /// Attempts mock login with email and password
  Future<User> login({required String email, required String password});

  /// Registers a new mock account
  Future<User> register({
    required String name,
    required String email,
    required String password,
    String? phoneNumber,
  });

  /// Restores active session from persistent local storage
  Future<User?> restoreSession();

  /// Clears active session
  Future<void> logout();

  /// Updates allowed profile fields (name, phone, avatar) for the active user
  Future<User> updateProfile({
    required String name,
    String? phoneNumber,
    String? avatarUrl,
  });
}
