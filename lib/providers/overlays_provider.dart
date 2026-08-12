import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Demo overlay presets for the first Web preview.
final overlaysProvider = StateProvider<List<String>>((ref) => [
      'Logo LIVE STUDIO ASR',
      'Título da Live',
      'Preço + Oferta',
      'PIX + WhatsApp',
      'Banner Promocional',
    ]);
