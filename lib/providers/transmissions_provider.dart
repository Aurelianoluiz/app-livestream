import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'demo_list_provider.dart';
import '../services/storage_service.dart';

final transmissionsProvider = StateNotifierProvider<DemoListNotifier, List<LiveRecord>>((ref) => DemoListNotifier(
  storage: ref.read(storageServiceProvider),
  boxName: StorageService.transmissionsBox,
  seed: const [
    LiveRecord(id: 'tx-1', name: 'Live de Lançamentos', imageAsset: 'assets/illustrations/example-transmissoes.svg', data: {'schedule': 'Hoje 19:00', 'status': 'Programada', 'scene': 'Abertura', 'duration': '60 min'}),
    LiveRecord(id: 'tx-2', name: 'Oferta do Almoço', imageAsset: 'assets/illustrations/example-transmissoes.svg', data: {'schedule': 'Amanhã 12:30', 'status': 'Agendada', 'scene': 'Oferta Relâmpago', 'duration': '45 min'}),
    LiveRecord(id: 'tx-3', name: 'Super Live ASR', imageAsset: 'assets/illustrations/example-transmissoes.svg', data: {'schedule': 'Sexta 20:00', 'status': 'Agendada', 'scene': 'Apresentação de Produtos', 'duration': '120 min'}),
  ],
));
