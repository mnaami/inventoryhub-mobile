import '../domain/auth_service.dart';

/// Simulated auth for the no-backend build. Credentials are constants here and
/// are never persisted.
class StaticCredentialsAuthService implements AuthService {
  const StaticCredentialsAuthService();

  static const _username = 'admin';
  static const _password = 'admin';

  @override
  Future<bool> signIn(String username, String password) async {
    return username == _username && password == _password;
  }
}
