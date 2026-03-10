import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user_model.dart';

/// Mock authentication service.
///
/// Registered users are stored in a static in-memory map so they survive
/// provider rebuilds within a single app session. Session persistence via
/// SharedPreferences is optional – if the plugin fails, the app continues
/// to work without persistent sessions.
class AuthService {
  static const String _sessionKey = 'current_session';

  // ── In-memory user registry (survives within app session) ──
  // Key = email, Value = { name, password, id }
  static final Map<String, Map<String, String>> _registeredUsers = {};

  // ── Session persistence helpers (safe – never crashes) ──
  Future<SharedPreferences?> _tryGetPrefs() async {
    try {
      return await SharedPreferences.getInstance();
    } catch (e) {
      debugPrint('SharedPreferences unavailable: $e');
      return null;
    }
  }

  Future<void> _trySaveSession(UserModel user) async {
    try {
      final prefs = await _tryGetPrefs();
      await prefs?.setString(_sessionKey, jsonEncode(user.toJson()));
    } catch (e) {
      debugPrint('Failed to save session: $e');
    }
  }

  Future<void> _tryClearSession() async {
    try {
      final prefs = await _tryGetPrefs();
      await prefs?.remove(_sessionKey);
    } catch (e) {
      debugPrint('Failed to clear session: $e');
    }
  }

  // ── Public API ──

  /// Login with email and password.
  Future<UserModel> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final userData = _registeredUsers[email.toLowerCase()];
    if (userData != null && userData['password'] == password) {
      final user = UserModel(
        id: userData['id']!,
        email: email.toLowerCase(),
        name: userData['name']!,
        isNewUser: false,
      );
      await _trySaveSession(user);
      return user;
    }

    throw Exception("Invalid email or password");
  }

  /// Register a new user.
  Future<UserModel> signup(String name, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final lowerEmail = email.toLowerCase();

    if (_registeredUsers.containsKey(lowerEmail)) {
      throw Exception("An account with this email already exists");
    }

    final userId = DateTime.now().millisecondsSinceEpoch.toString();

    // Store in memory
    _registeredUsers[lowerEmail] = {
      'id': userId,
      'name': name,
      'password': password,
    };

    final user = UserModel(
      id: userId,
      email: lowerEmail,
      name: name,
      isNewUser: true,
    );

    await _trySaveSession(user);
    return user;
  }

  /// Logout – clear session.
  Future<void> logout() async {
    await _tryClearSession();
  }

  /// Try to restore a saved session from SharedPreferences.
  Future<UserModel?> restoreSession() async {
    try {
      final prefs = await _tryGetPrefs();
      final sessionJson = prefs?.getString(_sessionKey);
      if (sessionJson != null) {
        final data = jsonDecode(sessionJson) as Map<String, dynamic>;
        return UserModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('Failed to restore session: $e');
    }
    return null;
  }

  /// Update session (e.g. after completing onboarding).
  Future<void> updateSession(UserModel user) async {
    await _trySaveSession(user);
  }
}
