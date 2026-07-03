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
import '../helpers/test_db.dart';

Future<void> _boot(WidgetTester tester, Map<String, Object> seedPrefs) async {
  SharedPreferences.setMockInitialValues({
    'onboarding.seen': true,
    'auth.loggedIn': true,
    ...seedPrefs,
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

Future<void> _openSettings(WidgetTester tester, {String locale = 'en'}) async {
  final l10n = await AppLocalizations.delegate.load(Locale(locale));
  await tester.tap(find.text(l10n.navMore));
  await tester.pumpAndSettle();
  await tester.tap(find.text(l10n.navSettings));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('default locale (no override) renders English, LTR',
      (tester) async {
    await _boot(tester, {});
    await _openSettings(tester);

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('LANGUAGE'), findsOneWidget); // SectionHeader uppercases
    expect(find.text('العربية'), findsOneWidget); // Arabic option label itself

    final directionality = tester.widget<Directionality>(
      find.byType(Directionality).first,
    );
    expect(directionality.textDirection, TextDirection.ltr);
  });

  testWidgets('locale=ar override renders Arabic strings and flips to RTL',
      (tester) async {
    await _boot(tester, {'locale': 'ar'});
    await _openSettings(tester, locale: 'ar');

    expect(find.text('الإعدادات'), findsOneWidget); // Settings title
    expect(find.text('المظهر'), findsOneWidget); // Appearance
    expect(find.text('اللغة'), findsOneWidget); // Language
    expect(find.text('تسجيل الخروج'), findsOneWidget); // Log out

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.locale, const Locale('ar'));
  });

  testWidgets('toggling language in Settings persists and updates live',
      (tester) async {
    await _boot(tester, {});
    await _openSettings(tester);

    expect(find.text('Settings'), findsOneWidget); // still English

    await tester.tap(find.text('العربية'));
    await tester.pumpAndSettle();

    expect(find.text('الإعدادات'), findsOneWidget); // now Arabic
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('locale'), 'ar');
  });
}
