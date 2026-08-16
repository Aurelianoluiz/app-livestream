import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../media/media_library.dart';
import '../offers/offers_page.dart';
import '../overlays/overlays_page.dart';
import '../products/products_page.dart';
import '../scenes/scenes_page.dart';
import '../settings/settings_page.dart';
import '../transmissions/transmissions_page.dart';
import '../../providers/offers_provider.dart';
import '../../providers/overlays_provider.dart';
import '../../providers/products_provider.dart';
import '../../providers/scenes_provider.dart';
import '../../providers/transmissions_provider.dart';

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
      IconData icon,
      Widget page,
      int count,
      String asset
    })>[
      (
        title: 'Cenas',
        description: 'Organize as cenas da transmissão',
        icon: Icons.layers_outlined,
        page: const ScenesPage(),
        count: scenes.length,
        asset: 'assets/illustrations/example-cenas.svg'
      ),
      (
        title: 'Produtos',
        description: 'Catálogo, preços e estoque',
        icon: Icons.inventory_2_outlined,
        page: const ProductsPage(),
        count: products.length,
        asset: 'assets/illustrations/example-produtos.svg'
      ),
      (
        title: 'Ofertas',
        description: 'Promoções e campanhas',
        icon: Icons.local_offer_outlined,
        page: const OffersPage(),
        count: offers.length,
        asset: 'assets/illustrations/example-ofertas.svg'
      ),
      (
        title: 'Transmissões',
        description: 'Agenda e controle das lives',
        icon: Icons.live_tv_outlined,
        page: const TransmissionsPage(),
        count: transmissions.length,
        asset: 'assets/illustrations/example-transmissoes.svg'
      ),
      (
        title: 'Overlays',
        description: 'Elementos visuais da live',
        icon: Icons.dashboard_customize_outlined,
        page: const OverlaysPage(),
        count: overlays.length,
        asset: 'assets/illustrations/example-overlays.svg'
      ),
      (
        title: 'Mídia',
        description: 'Imagens, logos e biblioteca',
        icon: Icons.perm_media_outlined,
        page: const MediaLibrary(),
        count: 8,
        asset: 'assets/images/example.jpg'
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('LIVE STUDIO ASR'),
        actions: [
          IconButton(
            onPressed: openSettings,
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
              final preview = _LivePreviewCard(
                current: current,
                onOpen: openTransmissions,
              );
              final summary = _SummaryCard(
                counts: [
                  scenes.length,
                  products.length,
                  offers.length,
                  transmissions.length,
                ],
                running: runningCount,
                paused: pausedCount,
                finished: finishedCount,
              );
              return compact
                  ? Column(
                      children: [preview, const SizedBox(height: 16), summary],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: preview),
                        const SizedBox(width: 16),
                        Expanded(flex: 2, child: summary),
                      ],
                    );
            },
          ),
          const SizedBox(height: 24),
          Text(
            'Operação da live',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          _QuickActionsCard(
            current: current,
            onOpenTransmissions: openTransmissions,
            onOpenSettings: openSettings,
          ),
          const SizedBox(height: 24),
          Text(
            'Módulos do estúdio',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 360,
              mainAxisExtent: 292,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 140,
                        width: double.infinity,
                        child: _asset(module.asset),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(module.icon, size: 24),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            module.title,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 9,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primaryContainer,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text('${module.count}'),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      module.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
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

class _LivePreviewCard extends StatelessWidget {
  final LiveRecord? current;
  final VoidCallback onOpen;
  const _LivePreviewCard({required this.current, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final active = current != null;
    final paused = active && '${current!.data['status']}' == 'paused';
    final title = active ? current!.name : 'Nenhuma live em operação';
    final subtitle = active
        ? (paused
            ? 'A transmissão está pausada.'
            : 'A transmissão está ao vivo.')
        : 'Abra Transmissões para preparar ou iniciar uma live.';

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
                  colors: [
                    Colors.black.withOpacity(0.05),
                    Colors.black.withOpacity(0.84),
                  ],
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: active
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      active ? (paused ? 'LIVE PAUSADA' : 'AO VIVO') : 'PRONTO PARA LIVE',
                      style: TextStyle(
                        color: active ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: onOpen,
                    icon: Icon(active ? Icons.tune : Icons.play_arrow),
                    label: Text(active ? 'Controlar transmissão' : 'Abrir transmissões'),
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
  final int running;
  final int paused;
  final int finished;
  const _SummaryCard({
    required this.counts,
    required this.running,
    required this.paused,
    required this.finished,
  });

  @override
  Widget build(BuildContext context) {
    const labels = ['Cenas', 'Produtos', 'Ofertas', 'Lives'];
    const icons = [
      Icons.layers_outlined,
      Icons.inventory_2_outlined,
      Icons.local_offer_outlined,
      Icons.live_tv_outlined,
    ];
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Resumo rápido', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ...List.generate(
              labels.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(icons[index], size: 22),
                    const SizedBox(width: 10),
                    Expanded(child: Text(labels[index])),
                    Text('${counts[index]}', style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),
            _StatusRow(label: 'Ao vivo', value: running, icon: Icons.live_tv, color: scheme.primary),
            const SizedBox(height: 8),
            _StatusRow(label: 'Pausadas', value: paused, icon: Icons.pause_circle_outline, color: scheme.onSurfaceVariant),
            const SizedBox(height: 8),
            _StatusRow(label: 'Finalizadas', value: finished, icon: Icons.check_circle_outline, color: scheme.onSurfaceVariant),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.link_off_outlined, size: 18, color: scheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Expanded(child: Text('OBS é conectado em Configurações.')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  const _StatusRow({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 19, color: color),
        const SizedBox(width: 8),
        Expanded(child: Text(label)),
        Text('$value', style: Theme.of(context).textTheme.titleSmall),
      ],
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  final LiveRecord? current;
  final VoidCallback onOpenTransmissions;
  final VoidCallback onOpenSettings;
  const _QuickActionsCard({required this.current, required this.onOpenTransmissions, required this.onOpenSettings});

  @override
  Widget build(BuildContext context) {
    final status = current == null ? 'Nenhuma transmissão ativa' : '${current!.data['status']}';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Chip(
              avatar: Icon(current == null ? Icons.schedule : Icons.circle, size: 12),
              label: Text(current == null ? 'PRONTO' : status.toUpperCase()),
            ),
            FilledButton.icon(
              onPressed: onOpenTransmissions,
              icon: const Icon(Icons.live_tv),
              label: const Text('Transmissões'),
            ),
            OutlinedButton.icon(
              onPressed: onOpenSettings,
              icon: const Icon(Icons.settings_outlined),
              label: const Text('Configurar OBS'),
            ),
          ],
        ),
      ),
    );
  }
}
