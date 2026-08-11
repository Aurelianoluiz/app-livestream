import 'package:flutter/material.dart';
import '../common/entity_list_page.dart';
import '../../providers/overlays_provider.dart';

class OverlaysPage extends StatelessWidget {
  const OverlaysPage({super.key});
  @override
  Widget build(BuildContext context) => EntityListPage(title: 'Overlays', singular: 'Overlay', provider: overlaysProvider);
}
