import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../scenes/scenes_page.dart';
import '../products/products_page.dart';
import '../offers/offers_page.dart';
import '../transmissions/transmissions_page.dart';
import '../overlays/overlays_page.dart';
import '../media/media_library.dart';
import '../../providers/scenes_provider.dart';
import '../../providers/products_provider.dart';
import '../../providers/offers_provider.dart';
import '../../providers/transmissions_provider.dart';
import '../../providers/overlays_provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scenes = ref.watch(scenesProvider);
    final products = ref.watch(productsProvider);
    final offers = ref.watch(offersProvider);
    final transmissions = ref.watch(transmissionsProvider);
    final overlays = ref.watch(overlaysProvider);

    final modules = <({String title, String description, IconData icon, Widget page, int count})>[
      (
        title: 'Cenas',
        description: 'Organize as cenas da sua transmissão',
        icon: Icons.layers_outlined,
        page: const ScenesPage(),
        count: scenes.length,
      ),
      (
        title: 'Produtos',
        description: 'Catálogo, preços e estoque',
        icon: Icons.inventory_2_outlined,
        page: const ProductsPage(),
        count: products.length,
      ),
      (
        title: 'Ofertas',
        description: 'Promoções e campanhas ativas',
        icon: Icons.local_offer_outlined,
        page: const OffersPage(),
        count: offers.length,
      ),
      (
        title: 'Transmissões',
        description: 'Agenda e controle das lives',
        icon: Icons.live_tv_outlined,
        page: const TransmissionsPage(),
        count: transmissions.length,
      ),
      (
        title: 'Overlays',
        description: 'Elementos visuais da live',
        icon: Icons.dashboard_customize_outlined,
        page: const OverlaysPage(),
        count: overlays.length,
      ),
      (
        title: 'Mídia',
        description: 'Imagens, logos e biblioteca',
        icon: Icons.perm_media_outlined,
        page: const MediaLibrary(),
        count: 3,
      ),
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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 760;
              return compact
                  ? Column(
                      children: [
                        _LivePreviewCard(onOpen: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TransmissionsPage()))),
                        const SizedBox(height: 16),
                        _SummaryCard(counts: [scenes.length, products.length, offers.length, transmissions.length]),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: _LivePreviewCard(onOpen: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TransmissionsPage())))),
                        const SizedBox(width: 16),
                        Expanded(flex: 2, child: _SummaryCard(counts: [scenes.length, products.length, offers.length, transmissions.length])),
                      ],
                    );
            },
          ),
          const SizedBox(height: 24),
          Text('Módulos do estúdio', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 340,
              mainAxisExtent: 168,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: modules.length,
            itemBuilder: (context, index) {
              final module = modules[index];
              return Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => module.page)),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(module.icon, size: 30),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text('${module.count}'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(module.title, style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 5),
                        Text(module.description, style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LivePreviewCard extends StatelessWidget {
  final VoidCallback onOpen;
  const _LivePreviewCard({required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 300,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/images/example.jpg', fit: BoxFit.cover),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.05), Colors.black.withOpacity(0.80)],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('EXEMPLO DE LIVE'),
                  ),
                  const SizedBox(height: 10),
                  const Text('LIVE STUDIO ASR', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  const Text('Pré-visualização da sua transmissão', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: onOpen,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Abrir transmissões'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final List<int> counts;
  const _SummaryCard({required this.counts});

  @override
  Widget build(BuildContext context) {
    final labels = ['Cenas', 'Produtos', 'Ofertas', 'Lives'];
    final icons = [Icons.layers_outlined, Icons.inventory_2_outlined, Icons.local_offer_outlined, Icons.live_tv_outlined];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Resumo rápido', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ...List.generate(labels.length, (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(icons[index], size: 22),
                  const SizedBox(width: 10),
                  Expanded(child: Text(labels[index])),
                  Text('${counts[index]}', style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            )),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.circle, size: 12, color: Colors.green),
                const SizedBox(width: 8),
                const Expanded(child: Text('OBS NÃO CONECTADO')),
                Text('Preparado', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
