import 'package:flutter/material.dart';
import '../scenes/scenes_page.dart';
import '../products/products_page.dart';
import '../offers/offers_page.dart';
import '../transmissions/transmissions_page.dart';
import '../overlays/overlays_page.dart';
import '../media/media_library.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final modules = <({String title, IconData icon, Widget page})>[
      (title: 'Cenas', icon: Icons.layers_outlined, page: const ScenesPage()),
      (title: 'Produtos', icon: Icons.inventory_2_outlined, page: const ProductsPage()),
      (title: 'Ofertas', icon: Icons.local_offer_outlined, page: const OffersPage()),
      (title: 'Transmissões', icon: Icons.live_tv_outlined, page: const TransmissionsPage()),
      (title: 'Overlays', icon: Icons.dashboard_customize_outlined, page: const OverlaysPage()),
      (title: 'Mídia', icon: Icons.perm_media_outlined, page: const MediaLibrary()),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('LIVE STUDIO ASR'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Configurações',
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 280,
          mainAxisExtent: 150,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: modules.length,
        itemBuilder: (context, index) {
          final module = modules[index];
          return Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => module.page),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(module.icon, size: 34),
                    const SizedBox(height: 10),
                    Text(
                      module.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
