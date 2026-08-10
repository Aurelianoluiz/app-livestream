import 'package:flutter/material.dart';
import '../common/entity_list_page.dart';
import '../../providers/offers_provider.dart';

class OffersPage extends StatelessWidget {
  const OffersPage({super.key});
  @override
  Widget build(BuildContext context) => EntityListPage(title: 'Ofertas', singular: 'Oferta', provider: offersProvider);
}
