import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../common/entity_list_page.dart';
import '../../providers/transmissions_provider.dart';
import '../../providers/demo_list_provider.dart';
import '../../services/obs_service.dart';

class TransmissionsPage extends ConsumerStatefulWidget {
  const TransmissionsPage({super.key});

  @override
  ConsumerState<TransmissionsPage> createState() => _TransmissionsPageState();
}

class _TransmissionsPageState extends ConsumerState<TransmissionsPage> {
  Timer? _ticker;
  Duration _elapsed = Duration.zero;
  final obs = ObsService.instance;
  String obsState = 'OBS NÃO CONECTADO';
  bool obsBusy = false;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _refreshElapsed());
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _refreshElapsed() {
    if (!mounted) return;
    final current = ref.read(transmissionsProvider)
        .where((r) => r.data['status'] == 'running' || r.data['status'] == 'paused')
        .firstOrNull;
    if (current == null) {
      if (_elapsed != Duration.zero) setState(() => _elapsed = Duration.zero);
      return;
    }

    final startedRaw = current.data['startedAt'];
    if (startedRaw is! String) return;
    final startedAt = DateTime.tryParse(startedRaw);
    if (startedAt == null) return;

    final next = DateTime.now().difference(startedAt);
    if (next != _elapsed) setState(() => _elapsed = next);
  }

  String _fmt(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inHours)}:${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
  }

  Future<void> _syncObsState() async {
    if (!obs.connected) {
      if (mounted) setState(() => obsState = 'OBS NÃO CONECTADO');
      return;
    }
    try {
      final scene = await obs.currentScene();
      if (mounted) setState(() => obsState = scene.isEmpty ? 'OBS CONECTADO' : 'OBS CONECTADO • Cena: $scene');
    } catch (_) {
      if (mounted) setState(() => obsState = 'OBS CONECTADO');
    }
  }

  Future<void> _startObs(LiveRecord record) async {
    if (!obs.connected) return;
    setState(() => obsBusy = true);
    try {
      await obs.startStreaming();
      await _setStatus(record, 'running', syncObs: false);
      if (mounted) setState(() => obsState = 'OBS CONECTADO • TRANSMISSÃO INICIADA');
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Falha ao iniciar no OBS: $error')));
    } finally {
      if (mounted) setState(() => obsBusy = false);
    }
  }

  Future<void> _stopObs(LiveRecord record) async {
    if (!obs.connected) {
      await _setStatus(record, 'finished');
      return;
    }
    setState(() => obsBusy = true);
    try {
      await obs.stopStreaming();
      await _setStatus(record, 'finished', syncObs: false);
      if (mounted) setState(() => obsState = 'OBS CONECTADO • TRANSMISSÃO FINALIZADA');
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Falha ao finalizar no OBS: $error')));
    } finally {
      if (mounted) setState(() => obsBusy = false);
    }
  }

  Future<void> _switchScene(LiveRecord record) async {
    if (!obs.connected) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Conecte o OBS em Configurações primeiro.')));
      return;
    }
    final scene = '${record.data['scene'] ?? ''}'.trim();
    if (scene.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Esta transmissão não possui uma cena configurada.')));
      return;
    }
    setState(() => obsBusy = true);
    try {
      await obs.switchScene(scene);
      if (mounted) setState(() => obsState = 'OBS CONECTADO • Cena: $scene');
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Falha ao trocar cena no OBS: $error')));
    } finally {
      if (mounted) setState(() => obsBusy = false);
    }
  }

  Future<void> _setStatus(LiveRecord record, String status, {bool syncObs = true}) async {
    final items = ref.read(transmissionsProvider);
    final index = items.indexWhere((r) => r.id == record.id);
    if (index < 0) return;

    final now = DateTime.now();
    final data = Map<String, dynamic>.from(record.data)
      ..['status'] = status
      ..['lastAction'] = now.toIso8601String();

    if (status == 'running') {
      data['startedAt'] ??= now.toIso8601String();
      data.remove('finishedAt');
      data.remove('duration');
    }

    if (status == 'finished') {
      data['finishedAt'] = now.toIso8601String();
      data['duration'] = _fmt(_elapsed);
    }

    await ref.read(transmissionsProvider.notifier).replaceAt(
          index,
          record.copyWith(data: data, active: status != 'finished'),
        );
    if (syncObs) await _syncObsState();
    _refreshElapsed();
  }

  Color _statusColor(BuildContext context, String status) {
    final scheme = Theme.of(context).colorScheme;
    switch (status) {
      case 'running':
        return scheme.primary;
      case 'paused':
        return scheme.tertiary;
      case 'finished':
        return scheme.outline;
      default:
        return scheme.secondary;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'running':
        return 'AO VIVO';
      case 'paused':
        return 'PAUSADA';
      case 'finished':
        return 'FINALIZADA';
      default:
        return 'AGENDADA';
    }
  }

  Widget _summaryTile(BuildContext context, String label, String value, IconData icon) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 150,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface.withOpacity(0.78),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(icon, color: scheme.primary, size: 19),
          const SizedBox(width: 9),
          Expanded(child: Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant))),
          Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _currentCard(BuildContext context, LiveRecord current) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final running = current.data['status'] == 'running';
    final paused = current.data['status'] == 'paused';
    final statusColor = _statusColor(context, '${current.data['status'] ?? ''}');

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [
            statusColor.withOpacity(0.20),
            scheme.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: statusColor.withOpacity(0.42)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 820;
          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(999)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(running ? Icons.circle : Icons.pause_circle_filled, size: 11, color: Colors.white),
                        const SizedBox(width: 7),
                        Text(_statusLabel('${current.data['status'] ?? ''}'), style: theme.textTheme.labelMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 0.8)),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text('LIVE CONTROL', style: theme.textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                ],
              ),
              const SizedBox(height: 16),
              Text(current.name, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, height: 1.05)),
              const SizedBox(height: 7),
              Text(
                running ? 'Transmissão ativa. Use os controles abaixo para operar a live.' : 'A transmissão está pausada. Retome quando estiver pronto.',
                style: theme.textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant, height: 1.45),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _summaryTile(context, 'Tempo', _fmt(_elapsed), Icons.timer_outlined),
                  _summaryTile(context, 'Cena', '${current.data['scene'] ?? 'Não definida'}', Icons.layers_outlined),
                  _summaryTile(context, 'OBS', obs.connected ? 'Conectado' : 'Offline', Icons.settings_input_antenna_rounded),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(avatar: Icon(obs.connected ? Icons.circle : Icons.error_outline, size: 11, color: obs.connected ? scheme.primary : scheme.error), label: Text(obsState)),
                  if ('${current.data['product'] ?? ''}'.trim().isNotEmpty) Chip(label: Text('Produto: ${current.data['product']}')),
                  if ('${current.data['offer'] ?? ''}'.trim().isNotEmpty) Chip(label: Text('Oferta: ${current.data['offer']}')),
                ],
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: obsBusy || running ? null : () => obs.connected ? _startObs(current) : _setStatus(current, 'running'),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text(obs.connected ? 'Iniciar no OBS' : 'Iniciar'),
                  ),
                  OutlinedButton.icon(
                    onPressed: obsBusy || !running ? null : () => _setStatus(current, 'paused'),
                    icon: const Icon(Icons.pause_rounded),
                    label: const Text('Pausar'),
                  ),
                  OutlinedButton.icon(
                    onPressed: obsBusy ? null : () => _stopObs(current),
                    icon: const Icon(Icons.stop_rounded),
                    label: Text(obs.connected ? 'Finalizar no OBS' : 'Finalizar'),
                  ),
                  OutlinedButton.icon(
                    onPressed: obsBusy ? null : () => _switchScene(current),
                    icon: const Icon(Icons.layers_outlined),
                    label: const Text('Aplicar cena'),
                  ),
                ],
              ),
            ],
          );

          final side = Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: scheme.surface.withOpacity(0.84),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CRONÔMETRO', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 1.3, color: scheme.onSurfaceVariant)),
                    const SizedBox(height: 9),
                    FittedBox(
                      alignment: Alignment.centerLeft,
                      child: Text(_fmt(_elapsed), style: theme.textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                    ),
                    const SizedBox(height: 8),
                    Text(obs.connected ? 'Operação conectada ao OBS Studio.' : 'Conecte o OBS em Configurações para operar a transmissão.', style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant, height: 1.45)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.10), borderRadius: BorderRadius.circular(16), border: Border.all(color: statusColor.withOpacity(0.22))),
                child: Row(
                  children: [
                    Icon(paused ? Icons.pause_circle_filled : Icons.radio_button_checked, color: statusColor),
                    const SizedBox(width: 10),
                    Expanded(child: Text(paused ? 'Live pausada' : 'Live em execução', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900))),
                  ],
                ),
              ),
            ],
          );

          return compact
              ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [content, const SizedBox(height: 18), side])
              : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: content), const SizedBox(width: 20), SizedBox(width: 330, child: side)]);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final transmissions = ref.watch(transmissionsProvider);
    final current = transmissions
        .where((r) => r.data['status'] == 'running' || r.data['status'] == 'paused')
        .firstOrNull;

    final runningCount = transmissions.where((r) => r.data['status'] == 'running').length;
    final pausedCount = transmissions.where((r) => r.data['status'] == 'paused').length;
    final finishedCount = transmissions.where((r) => r.data['status'] == 'finished').length;
    final scheduledCount = transmissions.length - runningCount - pausedCount - finishedCount;

    if (obs.connected && obsState == 'OBS NÃO CONECTADO') {
      _syncObsState();
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 76,
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(color: scheme.primary, borderRadius: BorderRadius.circular(11)),
              child: const Icon(Icons.live_tv_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TRANSMISSÕES', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 1)),
                Text('Controle operacional das lives', style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
              ],
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 36),
        children: [
          if (current != null) ...[
            _currentCard(context, current),
            const SizedBox(height: 24),
          ],
          Row(
            children: [
              Expanded(child: Text('Visão geral', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900))),
              Text('${transmissions.length} transmissões', style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _summaryTile(context, 'Ao vivo', '$runningCount', Icons.circle),
              _summaryTile(context, 'Pausadas', '$pausedCount', Icons.pause_circle_outline),
              _summaryTile(context, 'Finalizadas', '$finishedCount', Icons.check_circle_outline),
              _summaryTile(context, 'Agendadas', '$scheduledCount', Icons.schedule_outlined),
            ],
          ),
          const SizedBox(height: 26),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: EntityListPage(
              title: 'Agenda de transmissões',
              singular: 'Transmissão',
              provider: transmissionsProvider,
            ),
          ),
        ],
      ),
    );
  }
}
