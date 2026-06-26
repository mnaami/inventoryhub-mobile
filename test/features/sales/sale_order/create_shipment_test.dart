import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventoryhub_mobile/core/db/app_database.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/core/providers.dart';
import 'package:inventoryhub_mobile/core/seed/seed_service.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/domain/sale_order_usecases.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/presentation/create_shipment_screen.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/presentation/sale_order_providers.dart';
import '../../../helpers/test_db.dart';

void main() {
  testWidgets('shipping more than the remaining qty shows an error',
      (tester) async {
    final db = newTestDb();
    final session = await SeedService(db, const IdGenerator()).ensureSeeded();
    final now = DateTime.utc(2026, 6, 26);
    await db.into(db.products).insert(ProductsCompanion.insert(
          id: 'p1', organizationId: session.organizationId, name: 'Widget',
          unitId: session.defaultUnitId, currentStock: const Value(10),
          createdAt: now, updatedAt: now,
        ));
    final container = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
      sessionProvider.overrideWithValue(session),
    ]);
    addTearDown(container.dispose);

    final service = container.read(saleOrderServiceProvider);
    final order = await service.createDraft(customerId: 'c1', lines: [
      const NewLine(
          productId: 'p1', productName: 'Widget', quantity: 3, unitPrice: 1),
    ]);
    await service.confirm(order);
    final processing = (await service.get(order.id))!;

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(home: CreateShipmentScreen(order: processing)),
    ));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, '5'); // > 3 ordered
    await tester.tap(find.widgetWithText(FilledButton, 'Ship'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Cannot ship'), findsOneWidget);
    await db.close();
  });
}
