import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'demo_list_provider.dart';
import '../services/storage_service.dart';

final offersProvider = StateNotifierProvider<DemoListNotifier, List<String>>((ref) {
  return DemoListNotifier(
    storage: ref.read(storageServiceProvider),
    boxName: StorageService.offersBox,
    seed: const [
      'Oferta Flash — Smart TV 50"',
      'Combo Notebook + Mochila',
      'Semana do Streaming',
      'Frete Grátis em Produtos Selecionados',
    ],
  );
});
