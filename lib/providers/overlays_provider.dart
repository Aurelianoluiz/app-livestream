import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'demo_list_provider.dart';
import '../services/storage_service.dart';

final overlaysProvider = StateNotifierProvider<DemoListNotifier, List<LiveRecord>>((ref) => DemoListNotifier(
  storage: ref.read(storageServiceProvider),
  boxName: StorageService.overlaysBox,
  seed: const [
    LiveRecord(id: 'ov-1', name: 'Logo LIVE STUDIO ASR', imageAsset: 'assets/illustrations/example-overlays.svg', data: {'type': 'logo', 'position': 'top-right', 'visible': true}),
    LiveRecord(id: 'ov-2', name: 'Título da Live', imageAsset: 'assets/illustrations/example-overlays.svg', data: {'type': 'title', 'position': 'top-left', 'visible': true}),
    LiveRecord(id: 'ov-3', name: 'Preço + Oferta', imageAsset: 'assets/illustrations/example-overlays.svg', data: {'type': 'price', 'position': 'bottom-left', 'visible': true}),
    LiveRecord(id: 'ov-4', name: 'PIX + WhatsApp', imageAsset: 'assets/illustrations/example-overlays.svg', data: {'type': 'contact', 'position': 'bottom-right', 'visible': true}),
    LiveRecord(id: 'ov-5', name: 'Banner Promocional', imageAsset: 'assets/illustrations/example-overlays.svg', data: {'type': 'banner', 'position': 'bottom', 'visible': true}),
  ],
));
