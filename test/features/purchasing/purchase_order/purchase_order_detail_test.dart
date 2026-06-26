import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/core/providers.dart';
import 'package:inventoryhub_mobile/core/seed/seed_service.dart';
import 'package:inventoryhub_mobile/features/purchasing/purchase_order/presentation/purchase_order_detail_screen.dart';
import 'package:inventoryhub_mobile/features/purchasing/purchase_order/presentation/purchase_order_providers.dart';
import 'package:inventoryhub_mobile/features/purchasing/purchase_order/domain/purchase_order_usecases.dart';
import '../../../helpers/test_db.dart';

void main() {
  testWidgets('a draft order shows Send but not Confirm', (tester) async {
    final db = newTestDb();
    final session = await SeedService(db, const IdGenerator()).ensureSeeded();
    final container = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
      sessionProvider.overrideWithValue(session),
    ]);
    addTearDown(container.dispose);

    final order = await container.read(purchaseOrderServiceProvider).createDraft(
      supplierId: 's1',
      lines: [const NewLine(
          productId: 'p1', productName: 'Widget', quantity: 1, unitPrice: 10)],
    );

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(home: PurchaseOrderDetailScreen(orderId: order.id)),
    ));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, 'Send'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Confirm'), findsNothing);
    expect(find.text('Cancel order'), findsOneWidget);
    await db.close();
  });
}
