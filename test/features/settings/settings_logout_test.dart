import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inventoryhub_mobile/app/theme/theme_controller.dart';
import 'package:inventoryhub_mobile/features/auth/domain/auth_state.dart';
import 'package:inventoryhub_mobile/features/auth/presentation/auth_controller.dart';
import 'package:inventoryhub_mobile/features/settings/presentation/settings_screen.dart';

Future<ProviderContainer> _pump(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({'auth.loggedIn': true});
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
  );
  addTearDown(container.dispose);
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: container,
    child: const MaterialApp(home: SettingsScreen()),
  ));
  return container;
}

void main() {
  testWidgets('logout tile confirms then logs out', (tester) async {
    final c = await _pump(tester);
    expect(c.read(authControllerProvider), AuthState.loggedIn);

    await tester.tap(find.byKey(const Key('settings_logout')));
    await tester.pumpAndSettle();
    // Confirm dialog appears; tap its confirm action.
    await tester.tap(find.byKey(const Key('settings_logout_confirm')));
    await tester.pumpAndSettle();

    expect(c.read(authControllerProvider), AuthState.loggedOut);
  });
}
