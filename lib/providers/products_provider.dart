import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'demo_list_provider.dart';
import '../services/storage_service.dart';

final productsProvider = StateNotifierProvider<DemoListNotifier, List<LiveRecord>>((ref) => DemoListNotifier(
  storage: ref.read(storageServiceProvider),
  boxName: StorageService.productsBox,
  seed: const [
    LiveRecord(id: 'prod-1', name: 'Smart TV 50" 4K', imageAsset: 'assets/illustrations/example-produtos.svg', data: {'sku': 'TV50-4K', 'price': '2999.90', 'promoPrice': '2499.90', 'stock': 12}),
    LiveRecord(id: 'prod-2', name: 'Notebook Pro 15', imageAsset: 'assets/illustrations/example-produtos.svg', data: {'sku': 'NOTE15-PRO', 'price': '4599.90', 'promoPrice': '3999.90', 'stock': 8}),
    LiveRecord(id: 'prod-3', name: 'Fone Bluetooth Premium', imageAsset: 'assets/illustrations/example-produtos.svg', data: {'sku': 'FONE-BT-P', 'price': '299.90', 'promoPrice': '199.90', 'stock': 35}),
    LiveRecord(id: 'prod-4', name: 'Câmera Full HD para Live', imageAsset: 'assets/illustrations/example-produtos.svg', data: {'sku': 'CAM-FHD-LIVE', 'price': '799.90', 'promoPrice': '649.90', 'stock': 14}),
    LiveRecord(id: 'prod-5', name: 'Kit Iluminação LED', imageAsset: 'assets/illustrations/example-produtos.svg', data: {'sku': 'KIT-LED', 'price': '499.90', 'promoPrice': '399.90', 'stock': 21}),
  ],
));
