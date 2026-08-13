import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

class LiveRecord {
  final String id;
  final String name;
  final bool active;
  final String imageAsset;
  final Map<String, dynamic> data;

  const LiveRecord({
    required this.id,
    required this.name,
    this.active = true,
    required this.imageAsset,
    this.data = const {},
  });

  LiveRecord copyWith({String? id, String? name, bool? active, String? imageAsset, Map<String, dynamic>? data}) {
    return LiveRecord(
      id: id ?? this.id,
      name: name ?? this.name,
      active: active ?? this.active,
      imageAsset: imageAsset ?? this.imageAsset,
      data: data ?? this.data,
    );
  }

  String encode() => jsonEncode({
        'id': id,
        'name': name,
        'active': active,
        'imageAsset': imageAsset,
        'data': data,
      });

  static LiveRecord decode(String value) {
    final map = jsonDecode(value) as Map<String, dynamic>;
    return LiveRecord(
      id: map['id'] as String,
      name: map['name'] as String,
      active: map['active'] as bool? ?? true,
      imageAsset: map['imageAsset'] as String? ?? 'assets/images/example.jpg',
      data: Map<String, dynamic>.from(map['data'] as Map? ?? {}),
    );
  }
}

class DemoListNotifier extends StateNotifier<List<LiveRecord>> {
  DemoListNotifier({required StorageService storage, required this.boxName, required this.seed})
      : _storage = storage,
        super(List<LiveRecord>.from(seed)) {
    _load();
  }

  final StorageService _storage;
  final String boxName;
  final List<LiveRecord> seed;

  Future<void> _load() async {
    try {
      final values = await _storage.load(boxName);
      if (values.isEmpty) {
        state = List<LiveRecord>.from(seed);
        await _storage.save(boxName, state.map((e) => e.encode()).toList());
      } else {
        state = values.map(LiveRecord.decode).toList();
      }
    } catch (_) {
      state = List<LiveRecord>.from(seed);
    }
  }

  Future<void> addItem(LiveRecord value) async {
    if (value.name.trim().isEmpty) return;
    state = [...state, value];
    await _persist();
  }

  Future<void> deleteAt(int index) async {
    if (index < 0 || index >= state.length) return;
    state = [...state]..removeAt(index);
    await _persist();
  }

  Future<void> replaceAt(int index, LiveRecord value) async {
    if (index < 0 || index >= state.length || value.name.trim().isEmpty) return;
    final next = [...state];
    next[index] = value;
    state = next;
    await _persist();
  }

  Future<void> toggleAt(int index) async {
    if (index < 0 || index >= state.length) return;
    final next = [...state];
    next[index] = next[index].copyWith(active: !next[index].active);
    state = next;
    await _persist();
  }

  Future<void> resetToSeed() async {
    state = List<LiveRecord>.from(seed);
    await _persist();
  }

  Future<void> _persist() async => _storage.save(boxName, state.map((e) => e.encode()).toList());
}

final storageServiceProvider = Provider<StorageService>((ref) => StorageService());
