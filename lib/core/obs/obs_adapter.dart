import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// OBS WebSocket v5 adapter using the official protocol messages.
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
    await disconnect();

    final channel = WebSocketChannel.connect(Uri.parse('ws://$host:$port'));
    await channel.ready;
    _channel = channel;
    _helloCompleter = Completer<Map<String, dynamic>>();
    _identifiedCompleter = Completer<void>();

    _subscription = channel.stream.listen(
      (dynamic raw) {
        final message = jsonDecode(raw as String) as Map<String, dynamic>;
        final op = message['op'] as int?;
        final data = (message['d'] as Map?)?.cast<String, dynamic>() ?? {};

        if (op == 0) {
          if (!(_helloCompleter?.isCompleted ?? true)) {
            _helloCompleter!.complete(data);
          }
          return;
        }

        if (op == 2) {
          if (!(_identifiedCompleter?.isCompleted ?? true)) {
            _identifiedCompleter!.complete();
          }
          connected = true;
          return;
        }

        if (op == 7) {
          final requestId = int.tryParse('${data['requestId']}');
          final pending = requestId == null ? null : _pending.remove(requestId);
          if (pending != null && !pending.isCompleted) {
            pending.complete(data);
          }
        }
      },
      onError: (Object error, StackTrace stack) {
        if (!(_helloCompleter?.isCompleted ?? true)) {
          _helloCompleter!.completeError(error, stack);
        }
        if (!(_identifiedCompleter?.isCompleted ?? true)) {
          _identifiedCompleter!.completeError(error, stack);
        }
      },
      onDone: () {
        connected = false;
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

  Future<Map<String, dynamic>> call(
    String requestType, {
    Map<String, dynamic>? requestData,
  }) async {
    if (!connected || _channel == null) {
      throw StateError('OBS WebSocket is not connected.');
    }

    final id = ++_requestId;
    final completer = Completer<Map<String, dynamic>>();
    _pending[id] = completer;
    _channel!.sink.add(jsonEncode({
      'op': 6,
      'd': {
        'requestType': requestType,
        'requestId': '$id',
        if (requestData != null) 'requestData': requestData,
      },
    }));

    return completer.future.timeout(const Duration(seconds: 10));
  }

  Future<void> disconnect() async {
    connected = false;
    for (final pending in _pending.values) {
      if (!pending.isCompleted) {
        pending.completeError(StateError('OBS connection closed.'));
      }
    }
    _pending.clear();
    await _subscription?.cancel();
    _subscription = null;
    await _channel?.sink.close();
    _channel = null;
    _helloCompleter = null;
    _identifiedCompleter = null;
  }
}
