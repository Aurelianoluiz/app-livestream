import 'package:flutter/material.dart';
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
  bool darkMode = false;
  bool autoReconnect = true;
  bool loaded = false;
  bool busy = false;
  String obsMessage = 'OBS NÃO CONECTADO';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await storage.init();
    final settings = await storage.loadSettings();
    if (!mounted) return;
    setState(() {
      hostController.text = (settings['obsHost'] as String?) ?? 'localhost';
      portController.text = '${settings['obsPort'] ?? 4455}';
      darkMode = settings['darkMode'] as bool? ?? false;
      autoReconnect = settings['autoReconnect'] as bool? ?? true;
      loaded = true;
    });
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha ao exportar backup: $error')),
        );
      }
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
              decoration: const InputDecoration(
                labelText: 'Cole aqui o JSON do backup',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Validar e importar'),
            ),
          ],
        ),
      );

      if (confirmed != true || controller.text.trim().isEmpty) return;

      await backup.importJson(controller.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup validado e restaurado com sucesso.')),
        );
      }
    } on FormatException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup rejeitado: ${error.message}')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha ao importar backup: $error')),
        );
      }
    } finally {
      controller.dispose();
    }
  }

  Future<void> _connectObs() async {
    final host = hostController.text.trim().isEmpty ? 'localhost' : hostController.text.trim();
    final port = int.tryParse(portController.text) ?? 4455;
    setState(() {
      busy = true;
      obsMessage = 'CONECTANDO...';
    });
    try {
      obs.setAutoReconnect(autoReconnect);
      await obs.connect(host: host, port: port, password: passwordController.text);
      final scene = await obs.currentScene();
      if (mounted) {
        setState(() => obsMessage = scene.isEmpty ? 'OBS CONECTADO' : 'OBS CONECTADO • Cena: $scene');
      }
    } catch (error) {
      if (mounted) {
        setState(() => obsMessage = 'FALHA NA CONEXÃO');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível conectar ao OBS: $error')),
        );
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha ao iniciar transmissão: $error')),
        );
      }
    }
  }

  Future<void> _stopStream() async {
    try {
      await obs.stopStreaming();
      if (mounted) setState(() => obsMessage = 'OBS CONECTADO • TRANSMISSÃO FINALIZADA');
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha ao finalizar transmissão: $error')),
        );
      }
    }
  }

  @override
  void dispose() {
    hostController.dispose();
    portController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: !loaded
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              children: [
                Text('Aparência', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      SwitchListTile.adaptive(
                        title: const Text('Modo escuro'),
                        subtitle: const Text('Preferência salva para futuras versões do tema'),
                        value: darkMode,
                        onChanged: (value) => setState(() => darkMode = value),
                      ),
                      const Divider(height: 1),
                      const ListTile(
                        leading: Icon(Icons.palette_outlined),
                        title: Text('Identidade visual'),
                        subtitle: Text('LIVE STUDIO ASR'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text('Backup e restauração', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Backup versionado ASR_BACKUP_V1'),
                        const SizedBox(height: 6),
                        const Text('Exporta os dados e configurações para JSON. A restauração valida o arquivo antes de substituir os dados atuais.'),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            FilledButton.icon(
                              onPressed: _exportBackup,
                              icon: const Icon(Icons.upload_file),
                              label: const Text('Exportar backup'),
                            ),
                            OutlinedButton.icon(
                              onPressed: _importBackup,
                              icon: const Icon(Icons.restore),
                              label: const Text('Importar backup'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text('OBS Studio', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(obs.connected ? Icons.link : Icons.link_off_outlined),
                          title: Text(obsMessage),
                          subtitle: const Text('Integração OBS WebSocket v5 com sessão compartilhada'),
                        ),
                        const SizedBox(height: 8),
                        TextField(controller: hostController, decoration: const InputDecoration(labelText: 'Host', border: OutlineInputBorder())),
                        const SizedBox(height: 12),
                        TextField(controller: portController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Porta', border: OutlineInputBorder())),
                        const SizedBox(height: 12),
                        TextField(controller: passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Senha do OBS', border: OutlineInputBorder(), helperText: 'Usada somente durante a conexão e não salva em texto puro.')),
                        const SizedBox(height: 12),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Reconectar automaticamente'),
                          subtitle: const Text('Tenta reconectar após uma perda de conexão durante esta sessão.'),
                          value: autoReconnect,
                          onChanged: (value) {
                            setState(() => autoReconnect = value);
                            obs.setAutoReconnect(value);
                          },
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            FilledButton.icon(onPressed: busy || obs.connected ? null : _connectObs, icon: const Icon(Icons.link), label: Text(busy ? 'Conectando...' : 'Conectar ao OBS')),
                            OutlinedButton.icon(onPressed: obs.connected ? _disconnectObs : null, icon: const Icon(Icons.link_off), label: const Text('Desconectar')),
                            OutlinedButton.icon(onPressed: obs.connected ? _startStream : null, icon: const Icon(Icons.play_arrow), label: const Text('Iniciar Live')),
                            OutlinedButton.icon(onPressed: obs.connected ? _stopStream : null, icon: const Icon(Icons.stop), label: const Text('Parar Live')),
                            FilledButton.icon(onPressed: _save, icon: const Icon(Icons.save_outlined), label: const Text('Salvar configuração')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Column(
                    children: [
                      const ListTile(leading: Icon(Icons.live_tv_outlined), title: Text('LIVE STUDIO ASR'), subtitle: Text('Web + Android • Riverpod • Hive • OBS WebSocket v5')),
                      ListTile(leading: const Icon(Icons.logout), title: const Text('Sair da conta'), subtitle: const Text('Encerrar a sessão deste dispositivo'), onTap: widget.onLogout),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
