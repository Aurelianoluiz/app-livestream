import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'demo_list_provider.dart';
import '../services/storage_service.dart';

final scenesProvider = StateNotifierProvider<DemoListNotifier, List<String>>((ref) {
  return DemoListNotifier(
    storage: ref.read(storageServiceProvider),
    boxName: StorageService.scenesBox,
    seed: const [
      'Abertura — LIVE STUDIO ASR',
      'Apresentação de Produtos',
      'Oferta Relâmpago',
      'Encerramento',
    ],
  );
});
