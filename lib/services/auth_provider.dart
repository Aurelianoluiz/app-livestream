abstract interface class AuthProvider {
  Future<void> initialize();
  Future<bool> isAuthenticated();
  Future<String?> currentUser();
  Future<bool> login(String username, String password);
  Future<void> logout();
}
