import '../core/obs/obs_adapter.dart';

/// Shared OBS session for all live-control screens.
/// The OBS password is kept only in memory for the active session.
class ObsService {
  ObsService._();

  static final ObsService instance = ObsService._();

  final ObsAdapter adapter = ObsAdapter();
  String host = 'localhost';
  int port = 4455;
  String? _password;

  bool get connected => adapter.connected;

  Future<void> connect({
    required String host,
    required int port,
    required String password,
  }) async {
    this.host = host;
    this.port = port;
    _password = password.isEmpty ? null : password;
    await adapter.connect(host: host, port: port, password: _password);
  }

  Future<void> disconnect() async {
    await adapter.disconnect();
    _password = null;
  }

  Future<void> startStreaming() => adapter.startStreaming();
  Future<void> stopStreaming() => adapter.stopStreaming();
  Future<String> currentScene() => adapter.getCurrentSceneName();
  Future<void> switchScene(String sceneName) => adapter.switchScene(sceneName);
  Future<Map<String, dynamic>> stats() => adapter.getStats();
}
