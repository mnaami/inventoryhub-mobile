import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inventoryhub_mobile/app/app.dart';
import 'package:inventoryhub_mobile/app/theme/theme_controller.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/core/providers.dart';
import 'package:inventoryhub_mobile/core/seed/seed_service.dart';
import 'package:inventoryhub_mobile/l10n/app_localizations.dart';
import '../../helpers/test_db.dart';

Future<void> _boot(WidgetTester tester, {required String currency}) async {
  SharedPreferences.setMockInitialValues({
    'onboarding.seen': true,
    'app.currency': currency,
    'auth.loggedIn': true,
  });
  final prefs = await SharedPreferences.getInstance();
  final db = newTestDb();
  final session = await SeedService(db, const IdGenerator()).ensureSeeded();
  addTearDown(db.close);
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
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

Future<void> _openSettings(WidgetTester tester) async {
  final l10n = await AppLocalizations.delegate.load(const Locale('en'));
  await tester.tap(find.text(l10n.navMore));
  await tester.pumpAndSettle();
  await tester.tap(find.text(l10n.navSettings));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('switching currency in Settings persists the new code',
      (tester) async {
    await _boot(tester, currency: 'usd');
    await _openSettings(tester);

    expect(find.text('CURRENCY'), findsOneWidget); // SectionHeader uppercases
    await tester.tap(find.text('Algerian Dinar (دج)'));
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('app.currency'), 'dzd');
  });
}
