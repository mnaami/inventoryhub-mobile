import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventoryhub_mobile/app/router.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/core/providers.dart';
import 'package:inventoryhub_mobile/core/seed/seed_service.dart';
import '../helpers/test_db.dart';
import '../helpers/l10n.dart';

void main() {
  testWidgets('bottom nav shows the four sections and opens Sales',
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
      child: localizedApp(home: const MainScaffold()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Products'), findsWidgets);
    expect(find.text('Sales'), findsWidgets);
    expect(find.text('Purchasing'), findsWidgets);
    expect(find.text('More'), findsWidgets);

    await tester.tap(find.text('Sales'));
    await tester.pumpAndSettle();
    expect(find.text('Payment Status Breakdown'), findsOneWidget); // dashboard widget unique to Sales
    await db.close();
  });
}
