import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'demo_list_provider.dart';
import '../services/storage_service.dart';

final scenesProvider = StateNotifierProvider<DemoListNotifier, List<LiveRecord>>((ref) => DemoListNotifier(
  storage: ref.read(storageServiceProvider),
  boxName: StorageService.scenesBox,
  seed: const [
    LiveRecord(id: 'scene-1', name: 'Abertura — LIVE STUDIO ASR', imageAsset: 'assets/illustrations/example-cenas.svg', data: {'kind': 'abertura', 'description': 'Cena de abertura com logo e apresentador'}),
    LiveRecord(id: 'scene-2', name: 'Apresentação de Produtos', imageAsset: 'assets/illustrations/example-cenas.svg', data: {'kind': 'produto', 'description': 'Cena para demonstração de produtos'}),
    LiveRecord(id: 'scene-3', name: 'Oferta Relâmpago', imageAsset: 'assets/illustrations/example-ofertas.svg', data: {'kind': 'oferta', 'description': 'Cena promocional com preço e chamada'}),
    LiveRecord(id: 'scene-4', name: 'Encerramento', imageAsset: 'assets/illustrations/example-cenas.svg', data: {'kind': 'encerramento', 'description': 'Cena final com CTA e redes sociais'}),
  ],
));
