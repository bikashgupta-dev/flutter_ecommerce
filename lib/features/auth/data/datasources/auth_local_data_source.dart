import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/user.dart';

abstract class AuthLocalDataSource {
  Future<User?> getPersistedSession();
  Future<void> saveSession(User user);
  Future<void> clearSession();
  Future<List<Map<String, dynamic>>> getMockUsers();
  Future<void> saveMockUsers(List<Map<String, dynamic>> users);
  Future<void> clearMockUsers();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const String _sessionStorageKey = 'persisted_auth_session_v1';
  static const String _mockUsersStorageKey = 'persisted_mock_users_v1';

  final SharedPreferences prefs;

  AuthLocalDataSourceImpl({required this.prefs});

  @override
  Future<User?> getPersistedSession() async {
    try {
      final jsonStr = prefs.getString(_sessionStorageKey);
      if (jsonStr == null || jsonStr.trim().isEmpty) {
        return null;
      }
      final Map<String, dynamic> jsonMap = json.decode(jsonStr);
      return User.fromJson(jsonMap);
    } catch (_) {
      // Gracefully ignore corrupt session
      return null;
    }
  }

  @override
  Future<void> saveSession(User user) async {
    try {
      final jsonStr = json.encode(user.toJson());
      await prefs.setString(_sessionStorageKey, jsonStr);
    } catch (e) {
      throw Exception('Failed to persist auth session: $e');
    }
  }

  @override
  Future<void> clearSession() async {
    await prefs.remove(_sessionStorageKey);
  }

  @override
  Future<List<Map<String, dynamic>>> getMockUsers() async {
    try {
      final list = prefs.getStringList(_mockUsersStorageKey);
      if (list == null || list.isEmpty) {
        return [];
      }
      final List<Map<String, dynamic>> users = [];
      for (final itemStr in list) {
        try {
          final Map<String, dynamic> map = json.decode(itemStr);
          users.add(map);
        } catch (_) {
          // Skip corrupted record
        }
      }
      return users;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveMockUsers(List<Map<String, dynamic>> users) async {
    try {
      final list = users.map((u) => json.encode(u)).toList();
      await prefs.setStringList(_mockUsersStorageKey, list);
    } catch (e) {
      throw Exception('Failed to persist mock users: $e');
    }
  }

  @override
  Future<void> clearMockUsers() async {
    await prefs.remove(_mockUsersStorageKey);
  }
}
