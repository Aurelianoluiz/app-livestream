import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Demo offers used by the Web preview.
final offersProvider = StateProvider<List<String>>((ref) => [
      'Oferta Flash — Smart TV 50"',
      'Combo Notebook + Mochila',
      'Semana do Streaming',
      'Frete Grátis em Produtos Selecionados',
    ]);
