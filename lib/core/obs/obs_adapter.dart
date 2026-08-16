import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Real OBS WebSocket v5 adapter.
///
/// The adapter never fakes a connection: [connected] becomes true only after
/// receiving OBS's Identified message (op 2).
class ObsAdapter {
  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  final Map<int, Completer<Map<String, dynamic>>> _pending = {};
  Completer<Map<String, dynamic>>? _helloCompleter;
  Completer<void>? _identifiedCompleter;
  int _requestId = 0;

  bool connected = false;

  Future<void> connect({
    String host = 'localhost',
    int port = 4455,
    String? password,
  }) async {
    final normalizedHost = host.trim();
    if (normalizedHost.isEmpty) {
      throw ArgumentError('OBS host cannot be empty.');
    }
    if (port < 1 || port > 65535) {
      throw ArgumentError.value(port, 'port', 'must be between 1 and 65535');
    }

    await disconnect();

    final uri = Uri(
      scheme: 'ws',
      host: normalizedHost,
      port: port,
    );
    final channel = WebSocketChannel.connect(uri);
    await channel.ready;
    _channel = channel;
    _helloCompleter = Completer<Map<String, dynamic>>();
    _identifiedCompleter = Completer<void>();

    _subscription = channel.stream.listen(
      (dynamic raw) => _handleMessage(raw),
      onError: (Object error, StackTrace stack) {
        connected = false;
        if (!(_helloCompleter?.isCompleted ?? true)) {
          _helloCompleter!.completeError(error, stack);
        }
        if (!(_identifiedCompleter?.isCompleted ?? true)) {
          _identifiedCompleter!.completeError(error, stack);
        }
        _failPending(error);
      },
      onDone: () {
        connected = false;
        _failPending(StateError('OBS WebSocket connection closed.'));
      },
    );

    try {
      final hello = await _helloCompleter!.future.timeout(
        const Duration(seconds: 5),
      );
      final identify = <String, dynamic>{'rpcVersion': 1};
      final authentication = hello['authentication'] as Map?;

      if (authentication != null && password != null && password.isNotEmpty) {
        final salt = '${authentication['salt']}';
        final challenge = '${authentication['challenge']}';
        final secret = base64.encode(
          sha256.convert(utf8.encode(password + salt)).bytes,
        );
        identify['authentication'] = base64.encode(
          sha256.convert(utf8.encode(secret + challenge)).bytes,
        );
      }

      channel.sink.add(jsonEncode({'op': 1, 'd': identify}));
      await _identifiedCompleter!.future.timeout(const Duration(seconds: 5));
    } catch (_) {
      await disconnect();
      rethrow;
    }
  }

  void _handleMessage(dynamic raw) {
    if (raw is! String) return;

    final Map<String, dynamic> message;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return;
      message = decoded.cast<String, dynamic>();
    } on FormatException {
      // Ignore malformed frames rather than breaking the WebSocket listener.
      return;
    }

    final op = message['op'] as int?;
    final data = (message['d'] as Map?)?.cast<String, dynamic>() ?? {};

    if (op == 0) {
      if (!(_helloCompleter?.isCompleted ?? true)) {
        _helloCompleter!.complete(data);
      }
      return;
    }

    if (op == 2) {
      connected = true;
      if (!(_identifiedCompleter?.isCompleted ?? true)) {
        _identifiedCompleter!.complete();
      }
      return;
    }

    if (op == 7) {
      final requestId = int.tryParse('${data['requestId']}');
      if (requestId == null) return;
      final pending = _pending.remove(requestId);
      if (pending != null && !pending.isCompleted) {
        final status = (data['requestStatus'] as Map?)?.cast<String, dynamic>();
        if (status?['result'] == false) {
          pending.completeError(
            StateError('${status?['code']}: ${status?['comment'] ?? 'OBS request failed'}'),
          );
        } else {
          pending.complete(data);
        }
      }
    }
  }

  Future<Map<String, dynamic>> call(
    String requestType, {
    Map<String, dynamic>? requestData,
  }) async {
    if (!connected || _channel == null) {
      throw StateError('OBS WebSocket is not connected.');
    }
    if (requestType.trim().isEmpty) {
      throw ArgumentError('OBS request type cannot be empty.');
    }

    final id = ++_requestId;
    final completer = Completer<Map<String, dynamic>>();
    _pending[id] = completer;

    try {
      _channel!.sink.add(jsonEncode({
        'op': 6,
        'd': {
          'requestType': requestType,
          'requestId': '$id',
          if (requestData != null) 'requestData': requestData,
        },
      }));
    } catch (error, stack) {
      _pending.remove(id);
      if (!completer.isCompleted) {
        completer.completeError(error, stack);
      }
      rethrow;
    }

    try {
      return await completer.future.timeout(const Duration(seconds: 10));
    } on TimeoutException {
      _pending.remove(id);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getStats() => call('GetStats');

  Future<String> getCurrentSceneName() async {
    final response = await call('GetCurrentProgramScene');
    return '${(response['responseData'] as Map?)?['currentProgramSceneName'] ?? ''}';
  }

  Future<void> switchScene(String sceneName) async {
    final normalizedScene = sceneName.trim();
    if (normalizedScene.isEmpty) {
      throw ArgumentError('OBS scene name cannot be empty.');
    }
    await call('SetCurrentProgramScene', requestData: {
      'sceneName': normalizedScene,
    });
  }

  Future<void> startStreaming() async {
    await call('StartStream');
  }

  Future<void> stopStreaming() async {
    await call('StopStream');
  }

  Future<void> disconnect() async {
    connected = false;
    _failPending(StateError('OBS connection closed.'));
    await _subscription?.cancel();
    _subscription = null;
    try {
      await _channel?.sink.close();
    } catch (_) {
      // The channel may already be closed by the peer.
    }
    _channel = null;
    _helloCompleter = null;
    _identifiedCompleter = null;
    _requestId = 0;
  }

  void _failPending(Object error) {
    for (final pending in _pending.values) {
      if (!pending.isCompleted) pending.completeError(error);
    }
    _pending.clear();
  }
}
