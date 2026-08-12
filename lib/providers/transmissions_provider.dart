import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Demo transmission schedule for the first Web preview.
final transmissionsProvider = StateProvider<List<String>>((ref) => [
      'Hoje 19:00 — Live de Lançamentos',
      'Amanhã 12:30 — Oferta do Almoço',
      'Sexta 20:00 — Super Live ASR',
    ]);
