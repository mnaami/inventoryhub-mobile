import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/db/app_database.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/core/providers.dart';
import 'package:inventoryhub_mobile/core/seed/seed_service.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/domain/sale_order_enums.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/presentation/sale_shipment_providers.dart';
import '../../../helpers/test_db.dart';

void main() {
  test('shipment list loads and a status filter change reloads filtered',
      () async {
    final db = newTestDb();
    addTearDown(db.close);
    final session = await SeedService(db, const IdGenerator()).ensureSeeded();
    final c = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
      sessionProvider.overrideWithValue(session),
    ]);
    addTearDown(c.dispose);

    final now = DateTime.utc(2026, 6, 1);
    await db.into(db.saleOrders).insert(SaleOrdersCompanion.insert(
          id: 'so1', organizationId: session.organizationId,
          soNumber: 'SO-0001', customerId: 'c1', orderDate: now,
          createdAt: now, updatedAt: now,
        ));
    await db.into(db.saleOrderShippings).insert(SaleOrderShippingsCompanion.insert(
          id: 's1', organizationId: session.organizationId, saleOrderId: 'so1',
          soShippingNumber: 'SHP-0001', shippingDate: now,
          status: const Value('shipped'), createdAt: now, updatedAt: now,
        ));
    await db.into(db.saleOrderShippings).insert(SaleOrderShippingsCompanion.insert(
          id: 's2', organizationId: session.organizationId, saleOrderId: 'so1',
          soShippingNumber: 'SHP-0002', shippingDate: now,
          status: const Value('delivered'), createdAt: now, updatedAt: now,
        ));

    c.read(saleShipmentListProvider); // trigger initial load
    await Future<void>.delayed(Duration.zero);
    expect(c.read(saleShipmentListProvider).items.length, 2);

    c.read(saleShipmentCriteriaProvider.notifier)
        .setStatus(ShipmentStatus.shipped);
    await Future<void>.delayed(Duration.zero);
    final s = c.read(saleShipmentListProvider);
    expect(s.error, isNull);
    expect(s.items.single.soShippingNumber, 'SHP-0001');
  });
}
