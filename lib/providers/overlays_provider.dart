import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'demo_list_provider.dart';
import '../services/storage_service.dart';

final overlaysProvider = StateNotifierProvider<DemoListNotifier, List<String>>((ref) {
  return DemoListNotifier(
    storage: ref.read(storageServiceProvider),
    boxName: StorageService.overlaysBox,
    seed: const [
      'Logo LIVE STUDIO ASR',
      'Título da Live',
      'Preço + Oferta',
      'PIX + WhatsApp',
      'Banner Promocional',
    ],
  );
});
