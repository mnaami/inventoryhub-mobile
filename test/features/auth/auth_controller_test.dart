import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inventoryhub_mobile/app/theme/theme_controller.dart';
import 'package:inventoryhub_mobile/features/auth/domain/auth_state.dart';
import 'package:inventoryhub_mobile/features/auth/presentation/auth_controller.dart';

Future<ProviderContainer> _container(Map<String, Object> seedPrefs) async {
  SharedPreferences.setMockInitialValues(seedPrefs);
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('starts loggedOut when no flag persisted', () async {
    final c = await _container({});
    expect(c.read(authControllerProvider), AuthState.loggedOut);
  });

  test('restores loggedIn when flag persisted', () async {
    final c = await _container({'auth.loggedIn': true});
    expect(c.read(authControllerProvider), AuthState.loggedIn);
  });

  test('signIn with correct creds returns true, flips state, persists', () async {
    final c = await _container({});
    final ok = await c.read(authControllerProvider.notifier).signIn('admin', 'admin');
    expect(ok, isTrue);
    expect(c.read(authControllerProvider), AuthState.loggedIn);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('auth.loggedIn'), isTrue);
  });

  test('signIn with wrong creds returns false, stays loggedOut', () async {
    final c = await _container({});
    final ok = await c.read(authControllerProvider.notifier).signIn('admin', 'nope');
    expect(ok, isFalse);
    expect(c.read(authControllerProvider), AuthState.loggedOut);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('auth.loggedIn'), anyOf(isNull, isFalse));
  });

  test('logout clears flag and sets loggedOut', () async {
    final c = await _container({'auth.loggedIn': true});
    await c.read(authControllerProvider.notifier).logout();
    expect(c.read(authControllerProvider), AuthState.loggedOut);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('auth.loggedIn'), anyOf(isNull, isFalse));
  });
}
