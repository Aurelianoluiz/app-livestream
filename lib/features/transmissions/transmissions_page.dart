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

  Widget _currentCard(BuildContext context, LiveRecord current) {
    final running = current.data['status'] == 'running';

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.live_tv, size: 28),
                const SizedBox(width: 12),
                Expanded(child: Text(current.name, style: Theme.of(context).textTheme.titleLarge)),
                Chip(
                  avatar: Icon(running ? Icons.circle : Icons.pause_circle, size: 12),
                  label: Text(running ? 'AO VIVO' : 'PAUSADA'),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(_fmt(_elapsed), style: Theme.of(context).textTheme.displaySmall?.copyWith(fontFeatures: const [])),
            const SizedBox(height: 6),
            Text('Cena: ${current.data['scene'] ?? 'Não definida'}'),
            Text('Produto: ${current.data['product'] ?? 'Não definido'}'),
            Text('Oferta: ${current.data['offer'] ?? 'Nenhuma'}'),
            Text('OBS: $obsState'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: obsBusy || running ? null : () => obs.connected ? _startObs(current) : _setStatus(current, 'running'),
                  icon: const Icon(Icons.play_arrow),
                  label: Text(obs.connected ? 'Iniciar no OBS' : 'Iniciar'),
                ),
                OutlinedButton.icon(
                  onPressed: obsBusy || !running ? null : () => _setStatus(current, 'paused'),
                  icon: const Icon(Icons.pause),
                  label: const Text('Pausar'),
                ),
                OutlinedButton.icon(
                  onPressed: obsBusy ? null : () => _stopObs(current),
                  icon: const Icon(Icons.stop),
                  label: Text(obs.connected ? 'Finalizar no OBS' : 'Finalizar'),
                ),
                OutlinedButton.icon(
                  onPressed: obsBusy ? null : () => _switchScene(current),
                  icon: const Icon(Icons.layers_outlined),
                  label: const Text('Aplicar cena no OBS'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transmissions = ref.watch(transmissionsProvider);
    final current = transmissions
        .where((r) => r.data['status'] == 'running' || r.data['status'] == 'paused')
        .firstOrNull;

    if (obs.connected && obsState == 'OBS NÃO CONECTADO') {
      _syncObsState();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Transmissões')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          children: [
            if (current != null) ...[
              _currentCard(context, current),
              const SizedBox(height: 12),
            ],
            Expanded(
              child: EntityListPage(
                title: 'Transmissões',
                singular: 'Transmissão',
                provider: transmissionsProvider,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
