import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/theme_controller.dart'; // sharedPrefsProvider
import '../data/static_credentials_auth_service.dart';
import '../domain/auth_service.dart';
import '../domain/auth_state.dart';

final authServiceProvider = Provider<AuthService>(
  (_) => const StaticCredentialsAuthService(),
);

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);

class AuthController extends Notifier<AuthState> {
  static const _key = 'auth.loggedIn';

  @override
  AuthState build() {
    final prefs = ref.watch(sharedPrefsProvider);
    return (prefs.getBool(_key) ?? false)
        ? AuthState.loggedIn
        : AuthState.loggedOut;
  }

  Future<bool> signIn(String username, String password) async {
    final ok = await ref.read(authServiceProvider).signIn(username, password);
    if (!ok) return false;
    await ref.read(sharedPrefsProvider).setBool(_key, true);
    state = AuthState.loggedIn;
    return true;
  }

  Future<void> logout() async {
    await ref.read(sharedPrefsProvider).setBool(_key, false);
    state = AuthState.loggedOut;
  }
}
