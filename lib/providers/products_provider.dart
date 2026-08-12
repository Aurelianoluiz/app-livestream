import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'demo_list_provider.dart';
import '../services/storage_service.dart';

final productsProvider = StateNotifierProvider<DemoListNotifier, List<String>>((ref) {
  return DemoListNotifier(
    storage: ref.read(storageServiceProvider),
    boxName: StorageService.productsBox,
    seed: const [
      'Smart TV 50" 4K',
      'Notebook Pro 15',
      'Fone Bluetooth Premium',
      'Câmera Full HD para Live',
      'Kit Iluminação LED',
    ],
  );
});
