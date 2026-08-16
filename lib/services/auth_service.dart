import 'auth_provider.dart';
import 'local_auth_provider.dart';
import 'remote_auth_provider.dart';

class AuthService {
  static const defaultUsername = LocalAuthProvider.username;
  static const defaultPassword = LocalAuthProvider.password;

  static Future<void>? _initializing;
  static AuthProvider? _provider;

  /// Production uses a configured backend. When no backend URL is supplied,
  /// V1's local provider remains available for development/homologation.
  static AuthProvider _buildProvider() {
    final baseUrl = const String.fromEnvironment('ASR_AUTH_API_BASE_URL');
    if (baseUrl.trim().isNotEmpty) {
      return RemoteAuthProvider(baseUrl: baseUrl);
    }
    return LocalAuthProvider();
  }

  static AuthProvider get _activeProvider => _provider ??= _buildProvider();

  static Future<void> initialize() {
    _initializing ??= _activeProvider.initialize();
    return _initializing!;
  }

  static Future<void> initializeForTest(String path) {
    _initializing = LocalAuthProvider.initializeForTest(path);
    _provider = LocalAuthProvider();
    return _initializing!;
  }

  static Future<void> resetTestInitialization() async {
    _initializing = null;
    _provider = null;
    await LocalAuthProvider.resetTestInitialization();
  }

  Future<bool> isAuthenticated() async {
    await initialize();
    return _activeProvider.isAuthenticated();
  }

  Future<String?> currentUser() async {
    await initialize();
    return _activeProvider.currentUser();
  }

  Future<bool> login(String username, String password) async {
    await initialize();
    return _activeProvider.login(username, password);
  }

  Future<void> logout() async {
    await initialize();
    await _activeProvider.logout();
  }
}
