import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'auth_provider.dart';

/// Development-only local authentication fallback.
/// Production builds should configure a remote authentication backend.
class LocalAuthProvider implements AuthProvider {
  static const _boxName = 'auth';
  static const _authenticatedKey = 'authenticated';
  static const _userKey = 'user';

  static const username = 'admin@livestudioasr.com';
  static const password = 'ASR@2026';

  static Future<void>? _initializing;

  @override
  Future<void> initialize() {
    _initializing ??= Hive.initFlutter();
    return _initializing!;
  }

  static Future<void> initializeForTest(String path) {
    _initializing ??= Future<void>(() => Hive.init(path));
    return _initializing!;
  }

  static Future<void> resetTestInitialization() async {
    _initializing = null;
    if (Hive.isBoxOpen(_boxName)) {
      await Hive.box<String>(_boxName).close();
    }
  }

  Future<Box<String>> _box() async {
    await initialize();
    if (Hive.isBoxOpen(_boxName)) return Hive.box<String>(_boxName);
    return Hive.openBox<String>(_boxName);
  }

  String _hash(String value) => sha256.convert(utf8.encode(value)).toString();

  @override
  Future<bool> isAuthenticated() async {
    final box = await _box();
    return box.get(_authenticatedKey) == 'true';
  }

  @override
  Future<String?> currentUser() async {
    final box = await _box();
    return box.get(_userKey);
  }

  @override
  Future<bool> login(String usernameInput, String passwordInput) async {
    final valid = usernameInput.trim().toLowerCase() == username &&
        _hash(passwordInput) == _hash(password);
    final box = await _box();
    if (!valid) {
      await box.put(_authenticatedKey, 'false');
      await box.delete(_userKey);
      return false;
    }
    await box.put(_authenticatedKey, 'true');
    await box.put(_userKey, username);
    return true;
  }

  @override
  Future<void> logout() async {
    final box = await _box();
    await box.put(_authenticatedKey, 'false');
    await box.delete(_userKey);
  }
}
