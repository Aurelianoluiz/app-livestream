import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/transmissions_provider.dart';

class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  String _status(List items, String status) =>
      items.where((item) => item.data['status'] == status).length.toString();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transmissions = ref.watch(transmissionsProvider);
    final finished = transmissions.where((item) => item.data['status'] == 'finished').length;
    final active = transmissions.where((item) => item.data['status'] == 'running' || item.data['status'] == 'paused').length;
    final total = transmissions.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Relatórios')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Resumo operacional', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          const Text('Indicadores baseados no histórico de transmissões armazenado localmente.'),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 900 ? 4 : constraints.maxWidth >= 600 ? 2 : 1;
              final cards = [
                _MetricCard(label: 'Total', value: '$total', icon: Icons.live_tv_outlined),
                _MetricCard(label: 'Ao vivo/pausadas', value: '$active', icon: Icons.radio_button_checked),
                _MetricCard(label: 'Finalizadas', value: '$finished', icon: Icons.stop_circle_outlined),
                _MetricCard(label: 'Agendadas', value: _status(transmissions, 'scheduled'), icon: Icons.schedule),
              ];
              return GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.6,
                children: cards,
              );
            },
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Histórico recente', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                if (transmissions.isEmpty)
                  const Text('Nenhuma transmissão registrada.')
                else
                  ...transmissions.reversed.take(20).map(
                    (item) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.history),
                      title: Text(item.name),
                      subtitle: Text(
                        'Status: ${item.data['status'] ?? 'scheduled'} • '
                        'Início: ${item.data['startedAt'] ?? '—'} • '
                        'Fim: ${item.data['finishedAt'] ?? '—'}',
                      ),
                      trailing: Text(item.data['duration']?.toString() ?? '—'),
                    ),
                  ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          Icon(icon, size: 30, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label),
              const SizedBox(height: 4),
              Text(value, style: Theme.of(context).textTheme.headlineMedium),
            ]),
          ),
        ]),
      ),
    );
  }
}
