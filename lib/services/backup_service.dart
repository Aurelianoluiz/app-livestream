import 'dart:convert';

import 'storage_service.dart';

class BackupService {
  static const schema = 'ASR_BACKUP_V1';

  static const _collections = <String>[
    StorageService.scenesBox,
    StorageService.productsBox,
    StorageService.offersBox,
    StorageService.transmissionsBox,
    StorageService.overlaysBox,
  ];

  final StorageService storage;

  BackupService({StorageService? storage}) : storage = storage ?? StorageService();

  Future<String> exportJson() async {
    await storage.init();

    final collections = <String, List<String>>{};
    for (final boxName in _collections) {
      collections[boxName] = await storage.load(boxName);
    }

    final settings = await storage.loadSettings();

    final payload = <String, dynamic>{
      'schema': schema,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
      'collections': collections,
      'settings': settings,
    };

    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  Future<void> importJson(String raw) async {
    final decoded = jsonDecode(raw);
    final normalized = _validate(decoded);

    final previous = <String, List<String>>{};
    for (final boxName in _collections) {
      previous[boxName] = await storage.load(boxName);
    }
    final previousSettings = await storage.loadSettings();

    try {
      for (final boxName in _collections) {
        await storage.save(boxName, normalized.collections[boxName]!);
      }
      await storage.saveSettings(normalized.settings);
    } catch (error) {
      for (final entry in previous.entries) {
        await storage.save(entry.key, entry.value);
      }
      await storage.saveSettings(previousSettings);
      rethrow;
    }
  }

  _ValidatedBackup _validate(dynamic value) {
    if (value is! Map) {
      throw const FormatException('Backup inválido: formato JSON não é um objeto.');
    }

    if (value['schema'] != schema) {
      throw const FormatException('Backup inválido: versão de esquema não suportada.');
    }

    final collectionsRaw = value['collections'];
    if (collectionsRaw is! Map) {
      throw const FormatException('Backup inválido: coleções ausentes.');
    }

    final collections = <String, List<String>>{};
    for (final boxName in _collections) {
      final rawItems = collectionsRaw[boxName];
      if (rawItems is! List || rawItems.any((item) => item is! String)) {
        throw FormatException('Backup inválido: coleção "$boxName" está corrompida.');
      }
      collections[boxName] = rawItems.cast<String>();
    }

    final settingsRaw = value['settings'];
    if (settingsRaw is! Map) {
      throw const FormatException('Backup inválido: configurações ausentes.');
    }

    return _ValidatedBackup(
      collections: collections,
      settings: Map<String, dynamic>.from(settingsRaw),
    );
  }
}

class _ValidatedBackup {
  final Map<String, List<String>> collections;
  final Map<String, dynamic> settings;

  const _ValidatedBackup({
    required this.collections,
    required this.settings,
  });
}
