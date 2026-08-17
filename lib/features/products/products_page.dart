import 'package:flutter/material.dart';
import '../common/entity_list_page.dart';
import '../../providers/products_provider.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);
    final studio = base.copyWith(
      cardTheme: base.cardTheme.copyWith(elevation: 0, margin: const EdgeInsets.symmetric(vertical: 6), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(filled: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
      floatingActionButtonTheme: base.floatingActionButtonTheme.copyWith(backgroundColor: const Color(0xFFFF7A00), foregroundColor: Colors.white),
    );
    return Theme(data: studio, child: const EntityListPage(title: 'Produtos', singular: 'Produto', provider: productsProvider));
  }
}
