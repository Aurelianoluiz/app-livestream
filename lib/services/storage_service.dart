import 'package:hive_flutter/hive_flutter.dart';

/// Small persistence layer for V1 collections.
/// Models remain plain Dart objects; collections are stored as UTF-8 strings.
class StorageService {
  static const scenesBox = 'scenes';
  static const productsBox = 'products';
  static const offersBox = 'offers';
  static const transmissionsBox = 'transmissions';
  static const overlaysBox = 'overlays';

  Future<void>? _initializing;

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

  Future<Box<String>> _open(String name) async {
    await init();
    if (Hive.isBoxOpen(name)) return Hive.box<String>(name);
    return Hive.openBox<String>(name);
  }
}
