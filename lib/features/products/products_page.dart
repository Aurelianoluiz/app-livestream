import 'package:flutter/material.dart';
import '../common/entity_list_page.dart';
import '../../providers/products_provider.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});
  @override
  Widget build(BuildContext context) => EntityListPage(title: 'Produtos', singular: 'Produto', provider: productsProvider);
}
