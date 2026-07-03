import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inventoryhub_mobile/app/theme/theme_controller.dart';
import 'package:inventoryhub_mobile/features/auth/domain/auth_state.dart';
import 'package:inventoryhub_mobile/features/auth/presentation/auth_controller.dart';
import 'package:inventoryhub_mobile/features/auth/presentation/login_screen.dart';
import '../../helpers/l10n.dart';

Future<ProviderContainer> _pump(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: container,
    child: localizedApp(home: const LoginScreen()),
  ));
  return container;
}

void main() {
  testWidgets('shows the demo hint', (tester) async {
    await _pump(tester);
    expect(find.textContaining('admin / admin'), findsOneWidget);
  });

  testWidgets('wrong credentials show an error and stay loggedOut',
      (tester) async {
    final c = await _pump(tester);
    await tester.enterText(find.byKey(const Key('login_username')), 'admin');
    await tester.enterText(find.byKey(const Key('login_password')), 'wrong');
    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pumpAndSettle();
    expect(find.text('Invalid username or password'), findsOneWidget);
    expect(c.read(authControllerProvider), AuthState.loggedOut);
  });

  testWidgets('correct credentials flip auth state to loggedIn',
      (tester) async {
    final c = await _pump(tester);
    await tester.enterText(find.byKey(const Key('login_username')), 'admin');
    await tester.enterText(find.byKey(const Key('login_password')), 'admin');
    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pumpAndSettle();
    expect(c.read(authControllerProvider), AuthState.loggedIn);
  });
}
