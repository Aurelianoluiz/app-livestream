import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AuthService {
  static const _boxName = 'auth';
  static const _authenticatedKey = 'authenticated';
  static const _userKey = 'user';

  // V1 local account. Replace with server-side authentication before production use.
  static const defaultUsername = 'admin@livestudioasr.com';
  static const defaultPassword = 'ASR@2026';

  Future<Box<String>> _box() async {
    await Hive.initFlutter();
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
