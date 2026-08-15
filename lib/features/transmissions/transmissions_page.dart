import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../common/entity_list_page.dart';
import '../../providers/transmissions_provider.dart';
import '../../providers/demo_list_provider.dart';

class TransmissionsPage extends ConsumerStatefulWidget {
  const TransmissionsPage({super.key});

  @override
  ConsumerState<TransmissionsPage> createState() => _TransmissionsPageState();
}

class _TransmissionsPageState extends ConsumerState<TransmissionsPage> {
  Timer? _ticker;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final running = ref.read(transmissionsProvider).where((r) => r.data['status'] == 'running').isNotEmpty;
      if (running) setState(() => _elapsed += const Duration(seconds: 1));
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String _fmt(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final h = two(d.inHours);
    final m = two(d.inMinutes.remainder(60));
    final s = two(d.inSeconds.remainder(60));
    return '$h:$m:$s';
  }

  Color _statusColor(String status, ThemeData theme) {
    switch (status) {
      case 'running': return theme.colorScheme.primary;
      case 'paused': return Colors.orange;
      case 'finished': return theme.colorScheme.outline;
      default: return theme.colorScheme.secondary;
    }
  }

  Future<void> _setStatus(LiveRecord record, String status) async {
    final items = ref.read(transmissionsProvider);
    final index = items.indexWhere((r) => r.id == record.id);
    if (index < 0) return;
    final data = Map<String, dynamic>.from(record.data)
      ..['status'] = status
      ..['lastAction'] = DateTime.now().toIso8601String();
    if (status == 'running' && record.data['startedAt'] == null) {
      data['startedAt'] = DateTime.now().toIso8601String();
    }
    if (status == 'finished') {
      data['finishedAt'] = DateTime.now().toIso8601String();
      data['duration'] = _fmt(_elapsed);
    }
    await ref.read(transmissionsProvider.notifier).replaceAt(index, record.copyWith(data: data, active: status != 'finished'));
  }

  @override
  Widget build(BuildContext context) {
    final transmissions = ref.watch(transmissionsProvider);
    final current = transmissions.where((r) => r.data['status'] == 'running' || r.data['status'] == 'paused').firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transmissões'),
        actions: [
          if (current != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(child: Chip(
                avatar: const Icon(Icons.circle, size: 11),
                label: Text(current.data['status'] == 'running' ? 'AO VIVO' : 'PAUSADA'),
              )),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        children: [
          if (current != null)
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Icon(Icons.live_tv, size: 28),
                    const SizedBox(width: 12),
                    Expanded(child: Text(current.name, style: Theme.of(context).textTheme.titleLarge)),
                  ]),
                  const SizedBox(height: 14),
                  Text(_fmt(_elapsed), style: Theme.of(context).textTheme.displaySmall?.copyWith(fontFeatures: const [])),
                  const SizedBox(height: 6),
                  Text('Cena: ${current.data['scene'] ?? 'Não definida'}'),
                  Text('Produto: ${current.data['product'] ?? 'Não definido'}'),
                  Text('Oferta: ${current.data['offer'] ?? 'Nenhuma'}'),
                  Text('OBS: ${current.data['obs'] ?? 'Não conectado'}'),
                  const SizedBox(height: 12),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    FilledButton.icon(onPressed: () => _setStatus(current, 'running'), icon: const Icon(Icons.play_arrow), label: const Text('Iniciar')),
                    OutlinedButton.icon(onPressed: () => _setStatus(current, 'paused'), icon: const Icon(Icons.pause), label: const Text('Pausar')),
                    OutlinedButton.icon(onPressed: () => _setStatus(current, 'finished'), icon: const Icon(Icons.stop), label: const Text('Finalizar')),
                  ]),
                ]),
              ),
            ),
          const SizedBox(height: 10),
          EntityListPage(title: 'Transmissões', singular: 'Transmissão', provider: transmissionsProvider),
        ],
      ),
    );
  }
}
