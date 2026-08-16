import 'dart:async';

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
  Timer? _reconnectTimer;
  bool _autoReconnect = true;
  bool _reconnectArmed = false;
  bool _reconnecting = false;

  bool get connected => adapter.connected;
  bool get autoReconnect => _autoReconnect;

  void setAutoReconnect(bool value) {
    _autoReconnect = value;
    if (!value) {
      _reconnectTimer?.cancel();
      _reconnectTimer = null;
      return;
    }
    _scheduleReconnectChecks();
  }

  Future<void> connect({
    required String host,
    required int port,
    required String password,
  }) async {
    this.host = host;
    this.port = port;
    _password = password.isEmpty ? null : password;
    _reconnectArmed = true;
    await adapter.connect(host: host, port: port, password: _password);
    _scheduleReconnectChecks();
  }

  Future<void> disconnect() async {
    _reconnectArmed = false;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    await adapter.disconnect();
    _password = null;
  }

  void _scheduleReconnectChecks() {
    if (!_autoReconnect || !_reconnectArmed || _reconnectTimer != null) return;
    _reconnectTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _attemptReconnect();
    });
  }

  Future<void> _attemptReconnect() async {
    if (!_autoReconnect || !_reconnectArmed || connected || _reconnecting) return;
    _reconnecting = true;
    try {
      await adapter.connect(host: host, port: port, password: _password);
    } catch (_) {
      // Keep the session disconnected and retry on the next interval.
    } finally {
      _reconnecting = false;
    }
  }

  Future<void> startStreaming() => adapter.startStreaming();
  Future<void> stopStreaming() => adapter.stopStreaming();
  Future<String> currentScene() => adapter.getCurrentSceneName();
  Future<void> switchScene(String sceneName) => adapter.switchScene(sceneName);
  Future<Map<String, dynamic>> stats() => adapter.getStats();
}
