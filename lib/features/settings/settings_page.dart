import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/brand.dart';
import '../../core/theme_controller.dart';
import '../../services/backup_service.dart';
import '../../services/obs_service.dart';
import '../../services/storage_service.dart';

class SettingsPage extends StatefulWidget {
  final Future<void> Function() onLogout;
  const SettingsPage({super.key, required this.onLogout});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final hostController = TextEditingController(text: 'localhost');
  final portController = TextEditingController(text: '4455');
  final passwordController = TextEditingController();
  final storage = StorageService();
  final backup = BackupService();
  final obs = ObsService.instance;
  Timer? _monitorTimer;
  bool darkMode = true;
  bool autoReconnect = true;
  bool loaded = false;
  bool busy = false;
  String obsMessage = 'OBS NÃO CONECTADO';

  @override
  void initState() {
    super.initState();
    _load();
    _monitorTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _load() async {
    await storage.init();
    final settings = await storage.loadSettings();
    if (!mounted) return;
    final persistedDark = settings['darkMode'] as bool? ?? true;
    setState(() {
      hostController.text = (settings['obsHost'] as String?) ?? 'localhost';
      portController.text = '${settings['obsPort'] ?? 4455}';
      darkMode = persistedDark;
      autoReconnect = settings['autoReconnect'] as bool? ?? true;
      loaded = true;
    });
    AppThemeController.setDarkMode(persistedDark);
    obs.setAutoReconnect(autoReconnect);
  }

  Future<void> _save() async {
    obs.setAutoReconnect(autoReconnect);
    await storage.saveSettings({
      'obsHost': hostController.text.trim().isEmpty ? 'localhost' : hostController.text.trim(),
      'obsPort': int.tryParse(portController.text) ?? 4455,
      'obsPasswordConfigured': passwordController.text.isNotEmpty,
      'darkMode': darkMode,
      'autoReconnect': autoReconnect,
    });
    AppThemeController.setDarkMode(darkMode);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configurações salvas no Hive.')),
      );
    }
  }

  Future<void> _exportBackup() async {
    try {
      final json = await backup.exportJson();
      await Clipboard.setData(ClipboardData(text: json));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup exportado e copiado para a área de transferência.')),
        );
      }
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Falha ao exportar backup: $error')));
    }
  }

  Future<void> _importBackup() async {
    final controller = TextEditingController();
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Importar backup'),
          content: SizedBox(
            width: 620,
            child: TextField(
              controller: controller,
              maxLines: 12,
              decoration: const InputDecoration(labelText: 'Cole aqui o JSON do backup', border: OutlineInputBorder()),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancelar')),
            FilledButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('Validar e importar')),
          ],
        ),
      );
      if (confirmed != true || controller.text.trim().isEmpty) return;
      await backup.importJson(controller.text);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Backup validado e restaurado com sucesso.')));
    } on FormatException catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Backup rejeitado: ${error.message}')));
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Falha ao importar backup: $error')));
    } finally {
      controller.dispose();
    }
  }

  Future<void> _connectObs() async {
    final host = hostController.text.trim().isEmpty ? 'localhost' : hostController.text.trim();
    final port = int.tryParse(portController.text) ?? 4455;
    setState(() { busy = true; obsMessage = 'CONECTANDO...'; });
    try {
      obs.setAutoReconnect(autoReconnect);
      await obs.connect(host: host, port: port, password: passwordController.text);
      final scene = await obs.currentScene();
      if (mounted) setState(() => obsMessage = scene.isEmpty ? 'OBS CONECTADO' : 'OBS CONECTADO • Cena: $scene');
    } catch (error) {
      if (mounted) {
        setState(() => obsMessage = 'FALHA NA CONEXÃO');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Não foi possível conectar ao OBS: $error')));
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _disconnectObs() async {
    await obs.disconnect();
    if (mounted) setState(() => obsMessage = 'OBS NÃO CONECTADO');
  }

  Future<void> _startStream() async {
    try {
      await obs.startStreaming();
      if (mounted) setState(() => obsMessage = 'OBS CONECTADO • TRANSMISSÃO INICIADA');
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Falha ao iniciar transmissão: $error')));
    }
  }

  Future<void> _stopStream() async {
    try {
      await obs.stopStreaming();
      if (mounted) setState(() => obsMessage = 'OBS CONECTADO • TRANSMISSÃO FINALIZADA');
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Falha ao finalizar transmissão: $error')));
    }
  }

  String _time(DateTime? value) {
    if (value == null) return '—';
    final local = value.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(local.day)}/${two(local.month)} ${two(local.hour)}:${two(local.minute)}:${two(local.second)}';
  }

  String _statusLabel() {
    if (obs.reconnecting) return 'RECONEXÃO EM ANDAMENTO';
    if (obs.connected) return 'CONECTADO';
    if (obs.lastDisconnectedAt != null && autoReconnect) return 'DESCONECTADO • AGUARDANDO RECONEXÃO';
    return 'DESCONECTADO';
  }

  Widget _sectionTitle(BuildContext context, String title, String subtitle, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Brand.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Brand.primary.withOpacity(0.28)),
            ),
            child: const Icon(Icons.tune_rounded, color: Brand.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metric(BuildContext context, String label, String value, IconData icon) {
    return Container(
      constraints: const BoxConstraints(minWidth: 150),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Brand.border.withOpacity(0.75)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Brand.primary, size: 20),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 2),
              Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusHero(BuildContext context) {
    final connected = obs.connected;
    final reconnecting = obs.reconnecting;
    final color = connected ? Brand.primary : (reconnecting ? Colors.amber : Theme.of(context).colorScheme.error);
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surfaceContainerHighest,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withOpacity(0.38)),
        boxShadow: [BoxShadow(color: color.withOpacity(0.10), blurRadius: 24, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(color: color.withOpacity(0.14), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.35))),
                child: Icon(connected ? Icons.wifi_rounded : Icons.wifi_off_rounded, color: color, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('OBS STUDIO', style: Theme.of(context).textTheme.labelLarge?.copyWith(letterSpacing: 1.2, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(obsMessage, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text('${_statusLabel()} • WebSocket v5', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(999), border: Border.all(color: color.withOpacity(0.25))),
                child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.circle, size: 8, color: color), const SizedBox(width: 8), Text(connected ? 'ONLINE' : reconnecting ? 'RECONNECT' : 'OFFLINE', style: TextStyle(color: color, fontWeight: FontWeight.w800))]),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(spacing: 10, runSpacing: 10, children: [
            _metric(context, 'Latência', obs.lastRequestLatencyMs == null ? '—' : '${obs.lastRequestLatencyMs} ms', Icons.speed_rounded),
            _metric(context, 'Reconexões', '${obs.reconnectAttempts}', Icons.autorenew_rounded),
            _metric(context, 'Última conexão', _time(obs.lastConnectedAt), Icons.login_rounded),
            _metric(context, 'Última mensagem', _time(obs.lastMessageAt), Icons.message_rounded),
          ]),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _monitorTimer?.cancel();
    hostController.dispose();
    portController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Chip(label: Text(Brand.name), avatar: const Icon(Icons.live_tv_rounded, size: 18)),
          ),
        ],
      ),
      body: !loaded
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 900;
                final sideWidth = wide ? 360.0 : double.infinity;
                final mainWidth = wide ? constraints.maxWidth - sideWidth - 18 : double.infinity;

                final appearanceCard = Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Modo escuro premium'),
                          subtitle: const Text('Grafite, preto e laranja para operação de estúdio.'),
                          value: darkMode,
                          onChanged: (value) {
                            setState(() => darkMode = value);
                            AppThemeController.setDarkMode(value);
                          },
                        ),
                        const Divider(height: 22),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(backgroundColor: Brand.primary.withOpacity(0.14), child: const Icon(Icons.palette_outlined, color: Brand.primary)),
                          title: const Text('Identidade LIVE STUDIO ASR'),
                          subtitle: const Text('Preto • grafite • laranja • estados de transmissão'),
                        ),
                      ],
                    ),
                  ),
                );

                final backupCard = Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: const [Icon(Icons.backup_rounded, color: Brand.primary), SizedBox(width: 10), Text('BACKUP / RESTAURAÇÃO', style: TextStyle(fontWeight: FontWeight.w800))]),
                        const SizedBox(height: 10),
                        const Text('ASR_BACKUP_V1 • exportação e restauração com validação antes da substituição dos dados.'),
                        const SizedBox(height: 14),
                        Wrap(spacing: 8, runSpacing: 8, children: [
                          FilledButton.icon(onPressed: _exportBackup, icon: const Icon(Icons.upload_file_rounded), label: const Text('Exportar backup')),
                          OutlinedButton.icon(onPressed: _importBackup, icon: const Icon(Icons.restore_rounded), label: const Text('Importar backup')),
                        ]),
                      ],
                    ),
                  ),
                );

                final obsCard = Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: const [Icon(Icons.router_rounded, color: Brand.primary), SizedBox(width: 10), Text('CONEXÃO / CONTROLE OBS', style: TextStyle(fontWeight: FontWeight.w800))]),
                        const SizedBox(height: 16),
                        Row(children: [
                          Expanded(child: TextField(controller: hostController, decoration: const InputDecoration(labelText: 'Host', prefixIcon: Icon(Icons.dns_outlined)))),
                          const SizedBox(width: 12),
                          SizedBox(width: 130, child: TextField(controller: portController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Porta'))),
                        ]),
                        const SizedBox(height: 12),
                        TextField(controller: passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Senha do OBS', prefixIcon: Icon(Icons.lock_outline), helperText: 'Mantida somente em memória durante a sessão.')),
                        const SizedBox(height: 10),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Reconectar automaticamente'),
                          subtitle: const Text('Reabre a sessão após perda de conexão.'),
                          value: autoReconnect,
                          onChanged: (value) { setState(() => autoReconnect = value); obs.setAutoReconnect(value); },
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(16)),
                          child: Wrap(spacing: 14, runSpacing: 10, children: [
                            Text('Última desconexão: ${_time(obs.lastDisconnectedAt)}'),
                            Text('Última tentativa: ${_time(obs.lastReconnectAt)}'),
                            if (obs.lastError != null && obs.lastError!.isNotEmpty) Text('Último erro: ${obs.lastError}', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                          ]),
                        ),
                        const SizedBox(height: 14),
                        Wrap(spacing: 8, runSpacing: 8, children: [
                          FilledButton.icon(onPressed: busy || obs.connected ? null : _connectObs, icon: const Icon(Icons.link_rounded), label: Text(busy ? 'Conectando...' : 'Conectar')),
                          OutlinedButton.icon(onPressed: obs.connected ? _disconnectObs : null, icon: const Icon(Icons.link_off_rounded), label: const Text('Desconectar')),
                          OutlinedButton.icon(onPressed: obs.connected ? _startStream : null, icon: const Icon(Icons.play_arrow_rounded), label: const Text('Iniciar Live')),
                          OutlinedButton.icon(onPressed: obs.connected ? _stopStream : null, icon: const Icon(Icons.stop_rounded), label: const Text('Parar Live')),
                          FilledButton.icon(onPressed: _save, icon: const Icon(Icons.save_rounded), label: const Text('Salvar')),
                        ]),
                      ],
                    ),
                  ),
                );

                final main = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _statusHero(context),
                  const SizedBox(height: 18),
                  _sectionTitle(context, 'Controle do estúdio', 'Conexão, performance e comandos do OBS em um único lugar.', Icons.settings_input_component_rounded),
                  obsCard,
                ]);

                final side = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _sectionTitle(context, 'Preferências', 'Aparência e identidade visual.', Icons.palette_outlined),
                  appearanceCard,
                  const SizedBox(height: 18),
                  backupCard,
                  const SizedBox(height: 18),
                  Card(child: Column(children: [
                    const ListTile(leading: Icon(Icons.live_tv_outlined), title: Text('LIVE STUDIO ASR'), subtitle: Text('Web + Android • Riverpod • Hive • OBS WebSocket v5')),
                    ListTile(leading: const Icon(Icons.logout), title: const Text('Sair da conta'), subtitle: const Text('Encerrar a sessão deste dispositivo'), onTap: widget.onLogout),
                  ])),
                ]);

                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 36),
                  children: wide
                      ? [Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: mainWidth, child: main), const SizedBox(width: 18), SizedBox(width: sideWidth, child: side)])]
                      : [main, const SizedBox(height: 20), side],
                );
              },
            ),
    );
  }
}
