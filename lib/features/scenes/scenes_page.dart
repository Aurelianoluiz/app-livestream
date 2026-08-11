import 'package:flutter/material.dart';
import '../common/entity_list_page.dart';
import '../../providers/scenes_provider.dart';

class ScenesPage extends StatelessWidget {
  const ScenesPage({super.key});
  @override
  Widget build(BuildContext context) => EntityListPage(title: 'Cenas', singular: 'Cena', provider: scenesProvider);
}
