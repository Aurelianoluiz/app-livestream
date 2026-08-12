import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Demo data so the Web preview is useful immediately after first launch.
final scenesProvider = StateProvider<List<String>>((ref) => [
      'Abertura — LIVE STUDIO ASR',
      'Apresentação de Produtos',
      'Oferta Relâmpago',
      'Encerramento',
    ]);
