import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/transmissions_provider.dart';

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  String _filter = 'all';

  int _countByStatus(List items, String status) =>
      items.where((item) => item.data['status'] == status).length;

  Duration _parseDuration(dynamic value) {
    if (value is! String) return Duration.zero;
    final parts = value.split(':');
    if (parts.length != 3) return Duration.zero;
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    final s = int.tryParse(parts[2]) ?? 0;
    return Duration(hours: h, minutes: m, seconds: s);
  }

  String _formatDuration(Duration duration) {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(duration.inHours)}:${two(duration.inMinutes.remainder(60))}:${two(duration.inSeconds.remainder(60))}';
  }

  List _filtered(List items) {
    if (_filter == 'all') return items;
    return items.where((item) => item.data['status'] == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(transmissionsProvider);
    final transmissions = _filtered(all);
    final finished = _countByStatus(transmissions, 'finished');
    final active = transmissions
        .where((item) => item.data['status'] == 'running' || item.data['status'] == 'paused')
        .length;
    final scheduled = _countByStatus(transmissions, 'scheduled');
    final totalDuration = transmissions.fold<Duration>(
      Duration.zero,
      (sum, item) => sum + _parseDuration(item.data['duration']),
    );
    final completedWithDuration = transmissions
        .map((item) => _parseDuration(item.data['duration']))
        .where((value) => value > Duration.zero)
        .toList();
    final averageDuration = completedWithDuration.isEmpty
        ? Duration.zero
        : Duration(milliseconds: totalDuration.inMilliseconds ~/ completedWithDuration.length);
    final totalAll = all.length;
    final completionRate = totalAll == 0 ? 0 : ((_countByStatus(all, 'finished') / totalAll) * 100).round();
    final latest = all.isEmpty ? null : all.last;

    return Scaffold(
      appBar: AppBar(title: const Text('Relatórios')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Resumo operacional', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 6),
                  const Text('Indicadores baseados no histórico de transmissões armazenado localmente.'),
                ]),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 190,
                child: DropdownButtonFormField<String>(
                  value: _filter,
                  decoration: const InputDecoration(labelText: 'Filtrar status'),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('Todos')),
                    DropdownMenuItem(value: 'scheduled', child: Text('Agendadas')),
                    DropdownMenuItem(value: 'running', child: Text('Ao vivo')),
                    DropdownMenuItem(value: 'paused', child: Text('Pausadas')),
                    DropdownMenuItem(value: 'finished', child: Text('Finalizadas')),
                  ],
                  onChanged: (value) => setState(() => _filter = value ?? 'all'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 1100 ? 4 : constraints.maxWidth >= 650 ? 2 : 1;
              final cards = [
                _MetricCard(label: 'Total filtrado', value: '${transmissions.length}', icon: Icons.live_tv_outlined),
                _MetricCard(label: 'Ativas/pausadas', value: '$active', icon: Icons.radio_button_checked),
                _MetricCard(label: 'Finalizadas', value: '$finished', icon: Icons.stop_circle_outlined),
                _MetricCard(label: 'Agendadas', value: '$scheduled', icon: Icons.schedule),
                _MetricCard(label: 'Tempo total', value: _formatDuration(totalDuration), icon: Icons.timer_outlined),
                _MetricCard(label: 'Tempo médio', value: _formatDuration(averageDuration), icon: Icons.timelapse),
                _MetricCard(label: 'Taxa de conclusão', value: '$completionRate%', icon: Icons.check_circle_outline),
                _MetricCard(label: 'Última live', value: latest?.name ?? '—', icon: Icons.history),
              ];
              return GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: constraints.maxWidth >= 650 ? 2.4 : 3.2,
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
                  const Text('Nenhuma transmissão encontrada para o filtro selecionado.')
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
              Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.headlineMedium),
            ]),
          ),
        ]),
      ),
    );
  }
}
