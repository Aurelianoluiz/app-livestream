import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final hostController = TextEditingController(text: 'localhost');
  final portController = TextEditingController(text: '4455');
  final passwordController = TextEditingController();
  bool darkMode = false;
  bool autoReconnect = true;

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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: [
          Text('Aparência', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile.adaptive(
                  title: const Text('Modo escuro'),
                  subtitle: const Text('Preparação da preferência visual para a próxima etapa'),
                  value: darkMode,
                  onChanged: (value) => setState(() => darkMode = value),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.palette_outlined),
                  title: const Text('Identidade visual'),
                  subtitle: const Text('LIVE STUDIO ASR'),
                ),
              ],
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
                  const ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.link_off_outlined),
                    title: Text('OBS NÃO CONECTADO'),
                    subtitle: Text('Integração OBS WebSocket preparada para conexão real'),
                  ),
                  const SizedBox(height: 8),
                  TextField(controller: hostController, decoration: const InputDecoration(labelText: 'Host', border: OutlineInputBorder())),
                  const SizedBox(height: 12),
                  TextField(controller: portController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Porta', border: OutlineInputBorder())),
                  const SizedBox(height: 12),
                  TextField(controller: passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Senha', border: OutlineInputBorder())),
                  const SizedBox(height: 12),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Reconectar automaticamente'),
                    value: autoReconnect,
                    onChanged: (value) => setState(() => autoReconnect = value),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Configuração salva localmente para a próxima conexão do OBS.'))),
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Salvar configuração'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Sobre', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Card(
            child: ListTile(
              leading: Icon(Icons.live_tv_outlined),
              title: Text('LIVE STUDIO ASR'),
              subtitle: Text('Web + Android • Riverpod • Hive • OBS WebSocket'),
            ),
          ),
        ],
      ),
    );
  }
}
