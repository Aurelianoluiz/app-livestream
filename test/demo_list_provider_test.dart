import 'package:flutter_test/flutter_test.dart';
import 'package:app_livestream/providers/demo_list_provider.dart';
import 'package:app_livestream/services/storage_service.dart';

class MemoryStorage extends StorageService {
  final Map<String, List<String>> _data = {};

  @override
  Future<List<String>> load(String boxName) async =>
      List<String>.from(_data[boxName] ?? const []);

  @override
  Future<void> save(String boxName, List<String> values) async {
    _data[boxName] = List<String>.from(values);
  }
}

LiveRecord record(String id, String name, {bool active = true}) => LiveRecord(
      id: id,
      name: name,
      active: active,
      imageAsset: 'assets/images/example.jpg',
      data: const {'status': 'draft'},
    );

void main() {
  group('LiveRecord serialization', () {
    test('encodes and decodes all core fields', () {
      final original = record('1', 'Teste', active: false);
      final decoded = LiveRecord.decode(original.encode());

      expect(decoded.id, original.id);
      expect(decoded.name, original.name);
      expect(decoded.active, original.active);
      expect(decoded.imageAsset, original.imageAsset);
      expect(decoded.data, original.data);
    });
  });

  group('DemoListNotifier', () {
    late MemoryStorage storage;
    late DemoListNotifier notifier;

    setUp(() async {
      storage = MemoryStorage();
      notifier = DemoListNotifier(
        storage: storage,
        boxName: 'test',
        seed: [record('1', 'Inicial')],
      );
      await Future<void>.delayed(Duration.zero);
    });

    test('loads seed and persists it when storage is empty', () async {
      expect(notifier.state, hasLength(1));
      expect(notifier.state.first.name, 'Inicial');
      expect(await storage.load('test'), hasLength(1));
    });

    test('rejects empty names on add and replace', () async {
      await notifier.addItem(record('2', ''));
      expect(notifier.state, hasLength(1));

      await notifier.replaceAt(0, record('1', ''));
      expect(notifier.state.first.name, 'Inicial');
    });

    test('adds, toggles, replaces and deletes records', () async {
      await notifier.addItem(record('2', 'Segundo'));
      expect(notifier.state, hasLength(2));

      await notifier.toggleAt(1);
      expect(notifier.state[1].active, isFalse);

      await notifier.replaceAt(1, record('2', 'Atualizado'));
      expect(notifier.state[1].name, 'Atualizado');
      expect(notifier.state[1].active, isTrue);

      await notifier.deleteAt(1);
      expect(notifier.state, hasLength(1));
    });
  });
}
