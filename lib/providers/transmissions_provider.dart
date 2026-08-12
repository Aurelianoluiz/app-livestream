import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'demo_list_provider.dart';
import '../services/storage_service.dart';

final transmissionsProvider = StateNotifierProvider<DemoListNotifier, List<String>>((ref) {
  return DemoListNotifier(
    storage: ref.read(storageServiceProvider),
    boxName: StorageService.transmissionsBox,
    seed: const [
      'Hoje 19:00 — Live de Lançamentos',
      'Amanhã 12:30 — Oferta do Almoço',
      'Sexta 20:00 — Super Live ASR',
    ],
  );
});
