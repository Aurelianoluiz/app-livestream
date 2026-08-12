import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Demo catalog used to make the first Web preview immediately informative.
final productsProvider = StateProvider<List<String>>((ref) => [
      'Smart TV 50" 4K',
      'Notebook Pro 15',
      'Fone Bluetooth Premium',
      'Câmera Full HD para Live',
      'Kit Iluminação LED',
    ]);
