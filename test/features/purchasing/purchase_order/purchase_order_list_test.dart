import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/core/providers.dart';
import 'package:inventoryhub_mobile/core/seed/seed_service.dart';
import 'package:inventoryhub_mobile/features/purchasing/purchase_order/presentation/purchase_order_list_screen.dart';
import '../../../helpers/test_db.dart';

void main() {
  testWidgets('shows the empty state with no orders', (tester) async {
    final db = newTestDb();
    final session = await SeedService(db, const IdGenerator()).ensureSeeded();
    final container = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
      sessionProvider.overrideWithValue(session),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: PurchaseOrderListScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('No purchase orders yet. Tap + to create one.'),
        findsOneWidget);
    expect(find.text('Status'), findsOneWidget);
    expect(find.text('Date'), findsOneWidget);
    expect(find.text('Payment'), findsOneWidget);
    expect(find.text('Receipt'), findsOneWidget);
    await db.close();
  });
}
