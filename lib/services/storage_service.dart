import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

/// Small persistence layer for V1 collections and application settings.
class StorageService {
  static const scenesBox = 'scenes';
  static const productsBox = 'products';
  static const offersBox = 'offers';
  static const transmissionsBox = 'transmissions';
  static const overlaysBox = 'overlays';
  static const settingsBox = 'settings';

  static Future<void>? _initializing;

  Future<void> init() {
    _initializing ??= Hive.initFlutter();
    return _initializing!;
  }

  Future<List<String>> load(String boxName) async {
    final box = await _open(boxName);
    return box.values.toList(growable: false);
  }

  Future<void> save(String boxName, List<String> values) async {
    final box = await _open(boxName);
    await box.clear();
    await box.addAll(values);
  }

  Future<void> clear(String boxName) async {
    final box = await _open(boxName);
    await box.clear();
  }

  Future<Map<String, dynamic>> loadSettings() async {
    final box = await _open(settingsBox);
    final raw = box.get('settings');
    if (raw == null || raw.trim().isEmpty) return {};
    try {
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return {};
    }
  }

  Future<void> saveSettings(Map<String, dynamic> settings) async {
    final box = await _open(settingsBox);
    await box.put('settings', jsonEncode(settings));
  }

  Future<Box<String>> _open(String name) async {
    await init();
    if (Hive.isBoxOpen(name)) return Hive.box<String>(name);
    return Hive.openBox<String>(name);
  }
}
