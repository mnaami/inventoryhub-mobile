import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inventoryhub_mobile/app/app.dart';
import 'package:inventoryhub_mobile/app/theme/theme_controller.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/core/providers.dart';
import 'package:inventoryhub_mobile/core/seed/seed_service.dart';
import '../helpers/test_db.dart';

void main() {
  testWidgets('app boots to the Dashboard tab with the bottom nav',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'onboarding.seen': true,
      'app.currency': 'usd',
      'auth.loggedIn': true,
    });
    final prefs = await SharedPreferences.getInstance();
    final db = newTestDb();
    final session = await SeedService(db, const IdGenerator()).ensureSeeded();

    await tester.pumpWidget(ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        sessionProvider.overrideWithValue(session),
        sharedPrefsProvider.overrideWithValue(prefs),
      ],
      child: const InventoryHubApp(),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsWidgets); // app bar + nav label
    expect(find.text("Today's Sales"), findsOneWidget); // home stats section
    expect(find.text('Products'), findsOneWidget); // nav label
    expect(find.text('Sales'), findsOneWidget); // nav label
    expect(find.text('Production'), findsOneWidget); // nav label
    expect(find.text('More'), findsOneWidget); // nav label
    expect(find.text('Purchasing'), findsNothing); // demoted to More screen
    await db.close();
  });
}
