import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/core/providers.dart';
import 'package:inventoryhub_mobile/core/seed/seed_service.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/presentation/sale_order_detail_screen.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/presentation/sale_order_providers.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/domain/sale_order_usecases.dart';
import 'package:inventoryhub_mobile/features/sales/customer/presentation/customer_providers.dart';
import '../../../helpers/test_db.dart';

void main() {
  testWidgets('shows the customer name on the order detail screen',
      (tester) async {
    final db = newTestDb();
    final session = await SeedService(db, const IdGenerator()).ensureSeeded();
    final container = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
      sessionProvider.overrideWithValue(session),
    ]);
    addTearDown(container.dispose);

    final customer = await container
        .read(customerServiceProvider)
        .create(name: 'Acme Hardware');
    final order = await container.read(saleOrderServiceProvider).createDraft(
      customerId: customer.id,
      lines: [const NewLine(
          productId: 'p1', productName: 'Widget', quantity: 1, unitPrice: 10)],
    );

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(home: SaleOrderDetailScreen(orderId: order.id)),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Acme Hardware'), findsOneWidget);
    await db.close();
  });

  testWidgets('a draft order shows Confirm but not Process', (tester) async {
    final db = newTestDb();
    final session = await SeedService(db, const IdGenerator()).ensureSeeded();
    final container = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
      sessionProvider.overrideWithValue(session),
    ]);
    addTearDown(container.dispose);

    final order = await container.read(saleOrderServiceProvider).createDraft(
      customerId: 'c1',
      lines: [const NewLine(
          productId: 'p1', productName: 'Widget', quantity: 1, unitPrice: 10)],
    );

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(home: SaleOrderDetailScreen(orderId: order.id)),
    ));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, 'Confirm Order'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Start Processing'), findsNothing);
    expect(find.text('Cancel Order'), findsOneWidget);
    await db.close();
  });
}
