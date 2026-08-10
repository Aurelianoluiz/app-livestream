import 'package:flutter/material.dart';
import '../common/entity_list_page.dart';
import '../../providers/transmissions_provider.dart';

class TransmissionsPage extends StatelessWidget {
  const TransmissionsPage({super.key});
  @override
  Widget build(BuildContext context) => EntityListPage(title: 'Transmissões', singular: 'Transmissão', provider: transmissionsProvider);
}
