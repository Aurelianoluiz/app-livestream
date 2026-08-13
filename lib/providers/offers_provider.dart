import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'demo_list_provider.dart';
import '../services/storage_service.dart';

final offersProvider = StateNotifierProvider<DemoListNotifier, List<LiveRecord>>((ref) => DemoListNotifier(
  storage: ref.read(storageServiceProvider),
  boxName: StorageService.offersBox,
  seed: const [
    LiveRecord(id: 'offer-1', name: 'Oferta Flash — Smart TV 50"', imageAsset: 'assets/illustrations/example-ofertas.svg', data: {'originalPrice': '2999.90', 'promoPrice': '2499.90', 'start': 'Hoje 18:00', 'end': 'Hoje 22:00', 'status': 'Ativa'}),
    LiveRecord(id: 'offer-2', name: 'Combo Notebook + Mochila', imageAsset: 'assets/illustrations/example-ofertas.svg', data: {'originalPrice': '4899.90', 'promoPrice': '4199.90', 'start': '2026-08-14', 'end': '2026-08-20', 'status': 'Ativa'}),
    LiveRecord(id: 'offer-3', name: 'Semana do Streaming', imageAsset: 'assets/illustrations/example-ofertas.svg', data: {'originalPrice': '1299.90', 'promoPrice': '999.90', 'start': '2026-08-15', 'end': '2026-08-22', 'status': 'Programada'}),
    LiveRecord(id: 'offer-4', name: 'Frete Grátis em Produtos Selecionados', imageAsset: 'assets/illustrations/example-ofertas.svg', data: {'originalPrice': '0', 'promoPrice': '0', 'start': 'Hoje', 'end': 'Indeterminado', 'status': 'Ativa'}),
  ],
));
