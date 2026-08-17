import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../providers/demo_list_provider.dart';
import '../../providers/offers_provider.dart';
import '../../providers/overlays_provider.dart';
import '../../providers/products_provider.dart';
import '../../providers/scenes_provider.dart';
import '../../providers/transmissions_provider.dart';
import '../media/media_library.dart';
import '../offers/offers_page.dart';
import '../overlays/overlays_page.dart';
import '../products/products_page.dart';
import '../scenes/scenes_page.dart';
import '../settings/settings_page.dart';
import '../transmissions/transmissions_page.dart';

class DashboardPage extends ConsumerWidget {
  final Future<void> Function()? onLogout;

  const DashboardPage({super.key, this.onLogout});

  Widget _asset(String path) {
    return path.toLowerCase().endsWith('.svg')
        ? SvgPicture.asset(path, fit: BoxFit.cover)
        : Image.asset(path, fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final scenes = ref.watch(scenesProvider);
    final products = ref.watch(productsProvider);
    final offers = ref.watch(offersProvider);
    final transmissions = ref.watch(transmissionsProvider);
    final overlays = ref.watch(overlaysProvider);

    final current = transmissions.where((r) {
      final status = '${r.data['status'] ?? ''}';
      return status == 'running' || status == 'paused';
    }).firstOrNull;
    final runningCount = transmissions
        .where((r) => '${r.data['status'] ?? ''}' == 'running')
        .length;
    final finishedCount = transmissions
        .where((r) => '${r.data['status'] ?? ''}' == 'finished')
        .length;
    final pausedCount = transmissions
        .where((r) => '${r.data['status'] ?? ''}' == 'paused')
        .length;

    final modules = <({
      String title,
      String description,
      String eyebrow,
      IconData icon,
      Widget page,
      int count,
      String asset,
    })>[
      (
        title: 'Cenas',
        description: 'Organize as cenas e a composição da live.',
        eyebrow: 'STUDIO',
        icon: Icons.layers_outlined,
        page: const ScenesPage(),
        count: scenes.length,
        asset: 'assets/illustrations/example-cenas.svg',
      ),
      (
        title: 'Produtos',
        description: 'Catálogo, preços e estoque em um único lugar.',
        eyebrow: 'CATÁLOGO',
        icon: Icons.inventory_2_outlined,
        page: const ProductsPage(),
        count: products.length,
        asset: 'assets/illustrations/example-produtos.svg',
      ),
      (
        title: 'Ofertas',
        description: 'Crie campanhas e destaque produtos em promoção.',
        eyebrow: 'COMERCIAL',
        icon: Icons.local_offer_outlined,
        page: const OffersPage(),
        count: offers.length,
        asset: 'assets/illustrations/example-ofertas.svg',
      ),
      (
        title: 'Transmissões',
        description: 'Controle agenda, estados e operação das lives.',
        eyebrow: 'LIVE CONTROL',
        icon: Icons.live_tv_outlined,
        page: const TransmissionsPage(),
        count: transmissions.length,
        asset: 'assets/illustrations/example-transmissoes.svg',
      ),
      (
        title: 'Overlays',
        description: 'Identidade visual, banners e elementos da live.',
        eyebrow: 'ON AIR',
        icon: Icons.dashboard_customize_outlined,
        page: const OverlaysPage(),
        count: overlays.length,
        asset: 'assets/illustrations/example-overlays.svg',
      ),
      (
        title: 'Mídia',
        description: 'Imagens, logos e arquivos usados pelo estúdio.',
        eyebrow: 'MEDIA',
        icon: Icons.perm_media_outlined,
        page: const MediaLibrary(),
        count: 8,
        asset: 'assets/images/example.jpg',
      ),
    ];

    void openSettings() {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SettingsPage(onLogout: onLogout ?? () async {}),
        ),
      );
    }

    void openTransmissions() {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const TransmissionsPage()),
      );
    }

    final active = current != null;
    final paused = active && '${current!.data['status']}' == 'paused';

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 76,
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: scheme.primary,
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(Icons.graphic_eq, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('LIVE STUDIO ASR', style: text.titleMedium?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 1)),
                Text('Central de comando', style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: OutlinedButton.icon(
              onPressed: openSettings,
              icon: const Icon(Icons.tune_rounded, size: 18),
              label: const Text('Configurações'),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 36),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(
                colors: [
                  scheme.primary.withOpacity(0.18),
                  scheme.surface,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: scheme.primary.withOpacity(0.35)),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 840;
                final content = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: active ? scheme.primary : scheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(active ? Icons.circle : Icons.schedule_outlined, size: 11, color: active ? Colors.white : scheme.onSurfaceVariant),
                              const SizedBox(width: 7),
                              Text(
                                active ? (paused ? 'LIVE PAUSADA' : 'AO VIVO') : 'PRONTO PARA LIVE',
                                style: text.labelMedium?.copyWith(color: active ? Colors.white : scheme.onSurfaceVariant, fontWeight: FontWeight.w900, letterSpacing: 0.7),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Text('01', style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w900, color: scheme.primary)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      active ? current!.name : 'Sua central de comando para a próxima live.',
                      style: text.headlineMedium?.copyWith(fontWeight: FontWeight.w900, height: 1.05),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      active
                          ? (paused ? 'A transmissão está pausada. Retome o controle quando estiver pronto.' : 'A transmissão está ativa e pronta para ser controlada.')
                          : 'Organize cenas, produtos, ofertas, overlays e mídia em um fluxo rápido de operação.',
                      style: text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant, height: 1.45),
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        FilledButton.icon(
                          onPressed: openTransmissions,
                          icon: Icon(active ? Icons.tune_rounded : Icons.play_arrow_rounded),
                          label: Text(active ? 'Controlar transmissão' : 'Abrir transmissões'),
                        ),
                        OutlinedButton.icon(
                          onPressed: openSettings,
                          icon: const Icon(Icons.settings_input_antenna_rounded),
                          label: const Text('Configurar OBS'),
                        ),
                      ],
                    ),
                  ],
                );

                final stats = Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _MetricTile(label: 'Cenas', value: scenes.length.toString(), icon: Icons.layers_outlined),
                    _MetricTile(label: 'Produtos', value: products.length.toString(), icon: Icons.inventory_2_outlined),
                    _MetricTile(label: 'Ofertas', value: offers.length.toString(), icon: Icons.local_offer_outlined),
                    _MetricTile(label: 'Lives', value: transmissions.length.toString(), icon: Icons.live_tv_outlined),
                  ],
                );

                return compact
                    ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [content, const SizedBox(height: 22), stats])
                    : Row(crossAxisAlignment: CrossAxisAlignment.end, children: [Expanded(child: content), const SizedBox(width: 20), SizedBox(width: 330, child: stats)]);
              },
            ),
          ),
          const SizedBox(height: 26),
          Row(
            children: [
              Expanded(
                child: Text('Operação', style: text.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
              ),
              Text('$runningCount ao vivo  •  $pausedCount pausadas  •  $finishedCount finalizadas', style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                Chip(avatar: Icon(active ? Icons.circle : Icons.schedule_outlined, size: 12, color: active ? scheme.primary : null), label: Text(active ? (paused ? 'PAUSADA' : 'AO VIVO') : 'PRONTO')),
                FilledButton.icon(onPressed: openTransmissions, icon: const Icon(Icons.live_tv_rounded), label: const Text('Transmissões')),
                OutlinedButton.icon(onPressed: openSettings, icon: const Icon(Icons.settings_input_antenna_rounded), label: const Text('OBS Studio')),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(child: Text('Módulos do estúdio', style: text.titleLarge?.copyWith(fontWeight: FontWeight.w900))),
              Text('6 áreas', style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 360,
              mainAxisExtent: 278,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
            ),
            itemCount: modules.length,
            itemBuilder: (context, index) {
              final module = modules[index];
              return Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => module.page)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          SizedBox(height: 132, width: double.infinity, child: _asset(module.asset)),
                          Positioned(
                            top: 10,
                            left: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                              decoration: BoxDecoration(color: Colors.black.withOpacity(0.64), borderRadius: BorderRadius.circular(999)),
                              child: Text(module.eyebrow, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(15, 13, 15, 13),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(color: scheme.primary.withOpacity(0.11), borderRadius: BorderRadius.circular(12)),
                                child: Icon(module.icon, color: scheme.primary, size: 21),
                              ),
                              const SizedBox(width: 11),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(child: Text(module.title, style: text.titleMedium?.copyWith(fontWeight: FontWeight.w900))),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(color: scheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(999)),
                                          child: Text('${module.count}', style: text.labelMedium?.copyWith(fontWeight: FontWeight.w900)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(module.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant, height: 1.35)),
                                    const Spacer(),
                                    Row(
                                      children: [
                                        Text('Abrir módulo', style: text.labelMedium?.copyWith(color: scheme.primary, fontWeight: FontWeight.w900)),
                                        const SizedBox(width: 4),
                                        Icon(Icons.arrow_forward_rounded, size: 16, color: scheme.primary),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _MetricTile({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 152,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: scheme.surface.withOpacity(0.76),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: scheme.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant))),
          Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
