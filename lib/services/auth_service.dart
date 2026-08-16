import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AuthService {
  static const _boxName = 'auth';
  static const _authenticatedKey = 'authenticated';
  static const _userKey = 'user';
  static Future<void>? _initializing;

  // V1 local account. Replace with server-side authentication before production use.
  static const defaultUsername = 'admin@livestudioasr.com';
  static const defaultPassword = 'ASR@2026';

  static Future<void> initialize() {
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

  Future<bool> isAuthenticated() async {
    final box = await _box();
    return box.get(_authenticatedKey) == 'true';
  }

  Future<String?> currentUser() async {
    final box = await _box();
    return box.get(_userKey);
  }

  Future<bool> login(String username, String password) async {
    final valid = username.trim().toLowerCase() == defaultUsername &&
        _hash(password) == _hash(defaultPassword);
    final box = await _box();
    if (!valid) {
      await box.put(_authenticatedKey, 'false');
      await box.delete(_userKey);
      return false;
    }
    await box.put(_authenticatedKey, 'true');
    await box.put(_userKey, defaultUsername);
    return true;
  }

  Future<void> logout() async {
    final box = await _box();
    await box.put(_authenticatedKey, 'false');
    await box.delete(_userKey);
  }
}
