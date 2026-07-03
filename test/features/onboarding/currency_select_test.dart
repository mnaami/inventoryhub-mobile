import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inventoryhub_mobile/app/app.dart';
import 'package:inventoryhub_mobile/app/theme/theme_controller.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/core/providers.dart';
import 'package:inventoryhub_mobile/core/seed/seed_service.dart';
import '../../helpers/test_db.dart';

/// Boots the app past onboarding but before a currency has been chosen, so the
/// first-launch currency gate is on screen.
Future<void> _bootAtGate(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({'onboarding.seen': true});
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
  testWidgets('gate shows both currency options', (tester) async {
    await _bootAtGate(tester);
    expect(find.text('Choose your currency'), findsOneWidget);
    expect(find.text('US Dollar (\$)'), findsOneWidget);
    expect(find.byKey(const Key('currency_choice_usd')), findsOneWidget);
    expect(find.byKey(const Key('currency_choice_dzd')), findsOneWidget);
  });

  testWidgets('selecting a currency persists the code and leaves the gate',
      (tester) async {
    await _bootAtGate(tester);
    await tester.tap(find.byKey(const Key('currency_choice_usd')));
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('app.currency'), 'usd');
    expect(find.text('Choose your currency'), findsNothing);
  });
}
