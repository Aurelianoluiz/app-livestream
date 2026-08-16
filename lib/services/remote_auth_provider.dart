import 'dart:convert';

import 'package:http/http.dart' as http;

import 'auth_provider.dart';

/// REST authentication client for the production backend.
///
/// The backend is supplied at runtime with:
/// `--dart-define=ASR_AUTH_API_BASE_URL=https://api.example.com`
///
/// Expected contract:
/// POST /v1/auth/login  -> {"user": {"email": "..."}}
/// GET  /v1/auth/me    -> {"user": {"email": "..."}}
/// POST /v1/auth/logout -> 2xx
///
/// Authentication state is kept in the backend session/cookie. No password or
/// long-lived access token is persisted by this client.
class RemoteAuthProvider implements AuthProvider {
  RemoteAuthProvider({String? baseUrl, http.Client? client})
      : _baseUrl = (baseUrl ??
                const String.fromEnvironment('ASR_AUTH_API_BASE_URL'))
            .trim()
            .replaceFirst(RegExp(r'/+$'), ''),
        _client = client ?? http.Client();

  final String _baseUrl;
  final http.Client _client;

  Uri _uri(String path) {
    if (_baseUrl.isEmpty) {
      throw StateError('ASR_AUTH_API_BASE_URL is not configured.');
    }
    return Uri.parse('$_baseUrl$path');
  }

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> isAuthenticated() async {
    final response = await _client.get(_uri('/v1/auth/me'));
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  @override
  Future<String?> currentUser() async {
    final response = await _client.get(_uri('/v1/auth/me'));
    if (response.statusCode < 200 || response.statusCode >= 300) return null;
    final decoded = jsonDecode(response.body);
    if (decoded is! Map) return null;
    final user = decoded['user'];
    if (user is! Map) return null;
    final email = user['email'];
    return email is String && email.trim().isNotEmpty ? email.trim() : null;
  }

  @override
  Future<bool> login(String username, String password) async {
    final response = await _client.post(
      _uri('/v1/auth/login'),
      headers: const {'content-type': 'application/json'},
      body: jsonEncode({
        'email': username.trim().toLowerCase(),
        'password': password,
      }),
    );
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  @override
  Future<void> logout() async {
    await _client.post(_uri('/v1/auth/logout'));
  }
}
