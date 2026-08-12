import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

/// Generic persistent list store used by the V1 catalog-style features.
class DemoListNotifier extends StateNotifier<List<String>> {
  DemoListNotifier({
    required StorageService storage,
    required this.boxName,
    required this.seed,
  })  : _storage = storage,
        super(List<String>.from(seed)) {
    _load();
  }

  final StorageService _storage;
  final String boxName;
  final List<String> seed;

  Future<void> _load() async {
    try {
      final values = await _storage.load(boxName);
      if (values.isEmpty) {
        state = List<String>.from(seed);
        await _storage.save(boxName, state);
      } else {
        state = List<String>.from(values);
      }
    } catch (_) {
      // Keep the seeded demo state if storage is not available yet.
    }
  }

  Future<void> addItem(String value) async {
    final normalized = value.trim();
    if (normalized.isEmpty) return;
    state = [...state, normalized];
    await _storage.save(boxName, state);
  }

  Future<void> deleteAt(int index) async {
    if (index < 0 || index >= state.length) return;
    final next = [...state]..removeAt(index);
    state = next;
    await _storage.save(boxName, state);
  }

  Future<void> replaceAt(int index, String value) async {
    if (index < 0 || index >= state.length) return;
    final normalized = value.trim();
    if (normalized.isEmpty) return;
    final next = [...state];
    next[index] = normalized;
    state = next;
    await _storage.save(boxName, state);
  }

  Future<void> resetToSeed() async {
    state = List<String>.from(seed);
    await _storage.save(boxName, state);
  }
}

final storageServiceProvider = Provider<StorageService>((ref) => StorageService());
