import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventoryhub_mobile/app/currency/currency_controller.dart';
import 'package:inventoryhub_mobile/app/router.dart';
import 'package:inventoryhub_mobile/core/format/money_format.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/core/providers.dart';
import 'package:inventoryhub_mobile/core/seed/seed_service.dart';
import '../helpers/test_db.dart';
import '../helpers/l10n.dart';

void main() {
  testWidgets('Dashboard is the first tab and survives tabbing away and back',
      (tester) async {
    final db = newTestDb();
    final session = await SeedService(db, const IdGenerator()).ensureSeeded();
    final container = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
      sessionProvider.overrideWithValue(session),
      moneyFormatterProvider
          .overrideWithValue((v) => formatMoney(v, Currency.usd)),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: localizedApp(home: const MainScaffold()),
    ));
    await tester.pumpAndSettle();

    // Boots on Home.
    expect(find.text("Today's Sales"), findsOneWidget);

    // Tab away…
    await tester.tap(find.text('Products'));
    await tester.pumpAndSettle();
    expect(find.text('Stock Status Breakdown'), findsOneWidget);

    // …and back (this path re-invalidates homeDashboardProvider).
    await tester.tap(find.text('Dashboard'));
    await tester.pumpAndSettle();
    expect(find.text("Today's Sales"), findsOneWidget);
    await db.close();
  });

  testWidgets('Can swipe between tabs left and right on body', (tester) async {
    final db = newTestDb();
    final session = await SeedService(db, const IdGenerator()).ensureSeeded();
    final container = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
      sessionProvider.overrideWithValue(session),
      moneyFormatterProvider
          .overrideWithValue((v) => formatMoney(v, Currency.usd)),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: localizedApp(home: const MainScaffold()),
    ));
    await tester.pumpAndSettle();

    // Starts on Dashboard tab
    expect(find.text("Today's Sales"), findsOneWidget);

    // Swipe left on body to Products tab
    await tester.fling(find.byKey(const Key('main_page_view')), const Offset(-600, 0), 1000);
    await tester.pumpAndSettle();
    expect(find.text('Stock Status Breakdown'), findsOneWidget);

    // Swipe left again on body to Sales tab
    await tester.fling(find.byKey(const Key('main_page_view')), const Offset(-600, 0), 1000);
    await tester.pumpAndSettle();
    expect(find.text('Payment Status Breakdown'), findsOneWidget);

    // Swipe right back to Products tab
    await tester.fling(find.byKey(const Key('main_page_view')), const Offset(600, 0), 1000);
    await tester.pumpAndSettle();
    expect(find.text('Stock Status Breakdown'), findsOneWidget);

    await db.close();
  });

  testWidgets('Can swipe between tabs left and right directly on bottom bar', (tester) async {
    final db = newTestDb();
    final session = await SeedService(db, const IdGenerator()).ensureSeeded();
    final container = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
      sessionProvider.overrideWithValue(session),
      moneyFormatterProvider
          .overrideWithValue((v) => formatMoney(v, Currency.usd)),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: localizedApp(home: const MainScaffold()),
    ));
    await tester.pumpAndSettle();

    // Starts on Dashboard tab
    expect(find.text("Today's Sales"), findsOneWidget);

    // Swipe left on Bottom Bar to Products tab
    await tester.fling(find.byType(NavigationBar), const Offset(-600, 0), 1000);
    await tester.pumpAndSettle();
    expect(find.text('Stock Status Breakdown'), findsOneWidget);

    // Swipe left again on Bottom Bar to Sales tab
    await tester.fling(find.byType(NavigationBar), const Offset(-600, 0), 1000);
    await tester.pumpAndSettle();
    expect(find.text('Payment Status Breakdown'), findsOneWidget);

    // Swipe right back to Products tab
    await tester.fling(find.byType(NavigationBar), const Offset(600, 0), 1000);
    await tester.pumpAndSettle();
    expect(find.text('Stock Status Breakdown'), findsOneWidget);

    await db.close();
  });
}
