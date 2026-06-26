import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventoryhub_mobile/app/router.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/core/providers.dart';
import 'package:inventoryhub_mobile/core/seed/seed_service.dart';
import '../helpers/test_db.dart';

void main() {
  testWidgets('bottom nav shows the four sections and opens Purchasing',
      (tester) async {
    final db = newTestDb();
    final session = await SeedService(db, const IdGenerator()).ensureSeeded();
    final container = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
      sessionProvider.overrideWithValue(session),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: MainScaffold()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Products'), findsWidgets);
    expect(find.text('Sales'), findsWidgets);
    expect(find.text('Purchasing'), findsWidgets);
    expect(find.text('More'), findsWidgets);

    await tester.tap(find.text('Purchasing'));
    await tester.pumpAndSettle();
    // 'Unreceived' is unique to the Purchasing dashboard. (Do NOT assert
    // 'Open orders' — both the Sales and Purchasing dashboards render it, and
    // IndexedStack builds all tab children eagerly, so it appears twice.)
    expect(find.text('Unreceived'), findsOneWidget);
    expect(find.text('Outstanding payable'), findsOneWidget);
    await db.close();
  });
}
