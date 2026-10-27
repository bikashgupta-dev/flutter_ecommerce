import 'dart:convert';
import 'dart:math';

import '../../domain/models/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';

/// Development and demo mock authentication repository.
///
/// NOTE: This is a simulated authentication system for local testing and portfolio
/// demonstration. It does not replace a production identity provider or secure backend.
class MockAuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;

  User? _currentUser;
  bool _isSeeded = false;

  MockAuthRepositoryImpl({required this.localDataSource});

  /// Default demo account credentials for convenient reviewer evaluation
  static const String demoEmail = 'alex.morgan@example.com';
  static const String demoPassword = 'Password123';
  static const String demoName = 'Alex Morgan';
  static const String demoPhone = '9876543210';
  static const String? demoAvatarUrl = null;

  /// Salted transformation to avoid persisting plaintext passwords in demo storage
  static String hashPassword(String password, String salt) {
    final bytes = utf8.encode('$salt:${password.trim()}:$salt');
    return base64.encode(bytes);
  }

  Future<void> _ensureSeeded() async {
    if (_isSeeded) return;
    final existingUsers = await localDataSource.getMockUsers();
    if (existingUsers.isEmpty) {
      const demoSalt = 'shopsphere_demo_salt_001';
      final demoUser = User(
        id: 'usr_demo_001',
        name: demoName,
        email: demoEmail,
        phoneNumber: demoPhone,
        avatarUrl: demoAvatarUrl,
        createdAt: DateTime(2026, 1, 15, 10, 0),
      );

      final demoRecord = {
        'user': demoUser.toJson(),
        'salt': demoSalt,
        'passwordHash': hashPassword(demoPassword, demoSalt),
      };

      await localDataSource.saveMockUsers([demoRecord]);
    }
    _isSeeded = true;
  }

  @override
  Future<User?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;
    _currentUser = await localDataSource.getPersistedSession();
    return _currentUser;
  }

  @override
  Future<User?> restoreSession() async {
    return await getCurrentUser();
  }

  @override
  Future<User> login({required String email, required String password}) async {
    await _ensureSeeded();

    final normalizedEmail = email.trim().toLowerCase();
    final allUsers = await localDataSource.getMockUsers();

    final match = allUsers.cast<Map<String, dynamic>?>().firstWhere((record) {
      if (record == null) return false;
      final userMap = record['user'] as Map<String, dynamic>?;
      final recordEmail = userMap?['email']?.toString().trim().toLowerCase();
      return recordEmail == normalizedEmail;
    }, orElse: () => null);

    if (match == null) {
      throw Exception('Invalid email or password.');
    }

    final salt = match['salt']?.toString() ?? '';
    final storedHash = match['passwordHash']?.toString() ?? '';
    final inputHash = hashPassword(password, salt);

    if (storedHash != inputHash) {
      throw Exception('Invalid email or password.');
    }

    final user = User.fromJson(match['user'] as Map<String, dynamic>);
    _currentUser = user;
    await localDataSource.saveSession(user);
    return user;
  }

  @override
  Future<User> register({
    required String name,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    await _ensureSeeded();

    final normalizedEmail = email.trim().toLowerCase();
    final allUsers = await localDataSource.getMockUsers();

    // Check for duplicate registered email
    final exists = allUsers.any((record) {
      final userMap = record['user'] as Map<String, dynamic>?;
      final recordEmail = userMap?['email']?.toString().trim().toLowerCase();
      return recordEmail == normalizedEmail;
    });

    if (exists) {
      throw Exception('An account with this email already exists.');
    }

    final randomSuffix = (Random().nextInt(9000) + 1000).toString();
    final newId = 'usr_${DateTime.now().millisecondsSinceEpoch}_$randomSuffix';
    final newSalt = 'salt_${DateTime.now().microsecondsSinceEpoch}';

    final newUser = User(
      id: newId,
      name: name.trim(),
      email: normalizedEmail,
      phoneNumber: phoneNumber?.trim().isNotEmpty == true
          ? phoneNumber!.trim()
          : null,
      createdAt: DateTime.now(),
    );

    final newRecord = {
      'user': newUser.toJson(),
      'salt': newSalt,
      'passwordHash': hashPassword(password, newSalt),
    };

    final updatedUsersList = List<Map<String, dynamic>>.from(allUsers)
      ..add(newRecord);
    await localDataSource.saveMockUsers(updatedUsersList);

    _currentUser = newUser;
    await localDataSource.saveSession(newUser);
    return newUser;
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
    await localDataSource.clearSession();
  }

  @override
  Future<User> updateProfile({
    required String name,
    String? phoneNumber,
    String? avatarUrl,
  }) async {
    final current = await getCurrentUser();
    if (current == null) {
      throw Exception('No active user session to update.');
    }

    final updated = current.copyWith(
      name: name.trim(),
      phoneNumber: phoneNumber?.trim(),
      avatarUrl: avatarUrl?.trim(),
      clearPhone: phoneNumber == null || phoneNumber.trim().isEmpty,
      clearAvatar: avatarUrl == null || avatarUrl.trim().isEmpty,
      updatedAt: DateTime.now(),
    );

    // Update in mock users store
    final allUsers = await localDataSource.getMockUsers();
    final updatedList = allUsers.map((record) {
      final userMap = record['user'] as Map<String, dynamic>?;
      if (userMap?['id'] == current.id) {
        return {...record, 'user': updated.toJson()};
      }
      return record;
    }).toList();

    await localDataSource.saveMockUsers(updatedList);
    await localDataSource.saveSession(updated);
    _currentUser = updated;
    return updated;
  }
}
