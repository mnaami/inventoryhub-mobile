import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inventoryhub_mobile/app/app.dart';
import 'package:inventoryhub_mobile/app/theme/theme_controller.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/core/providers.dart';
import 'package:inventoryhub_mobile/core/seed/seed_service.dart';
import 'package:inventoryhub_mobile/features/auth/presentation/auth_controller.dart';
import '../helpers/test_db.dart';

Future<void> _boot(WidgetTester tester, Map<String, Object> seedPrefs) async {
  SharedPreferences.setMockInitialValues(seedPrefs);
  final prefs = await SharedPreferences.getInstance();
  final db = newTestDb();
  final session = await SeedService(db, const IdGenerator()).ensureSeeded();
  addTearDown(db.close);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
      sessionProvider.overrideWithValue(session),
      sharedPrefsProvider.overrideWithValue(prefs),
    ],
    child: const InventoryHubApp(),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('fresh install lands on onboarding', (tester) async {
    await _boot(tester, {});
    expect(find.text('Know your stock'), findsOneWidget);
  });

  testWidgets('seen but logged out lands on login', (tester) async {
    await _boot(tester, {'onboarding.seen': true});
    expect(find.text('Demo: admin / admin'), findsOneWidget);
  });

  testWidgets('logged in lands on the app shell', (tester) async {
    await _boot(tester, {'onboarding.seen': true, 'auth.loggedIn': true});
    expect(find.text('Products'), findsOneWidget); // bottom nav label
  });

  testWidgets('logging in redirects from login to the app shell',
      (tester) async {
    await _boot(tester, {'onboarding.seen': true});
    await tester.enterText(find.byKey(const Key('login_username')), 'admin');
    await tester.enterText(find.byKey(const Key('login_password')), 'admin');
    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pumpAndSettle();
    expect(find.text('Products'), findsOneWidget);
  });

  testWidgets('logout redirects from the app shell back to login',
      (tester) async {
    await _boot(tester, {'onboarding.seen': true, 'auth.loggedIn': true});
    final context = tester.element(find.text('Products'));
    final container = ProviderScope.containerOf(context);
    await container.read(authControllerProvider.notifier).logout();
    await tester.pumpAndSettle();
    expect(find.text('Demo: admin / admin'), findsOneWidget);
  });
}
