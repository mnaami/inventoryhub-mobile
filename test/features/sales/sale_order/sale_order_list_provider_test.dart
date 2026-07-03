import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/db/app_database.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/core/providers.dart';
import 'package:inventoryhub_mobile/core/seed/seed_service.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/presentation/sale_order_providers.dart';
import '../../../helpers/test_db.dart';

void main() {
  test('list provider loads results and a criteria change reloads with the filter applied',
      () async {
    final db = newTestDb();
    addTearDown(db.close);
    final session = await SeedService(db, const IdGenerator()).ensureSeeded();
    final c = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
      sessionProvider.overrideWithValue(session),
    ]);
    addTearDown(c.dispose);

    final now = DateTime.utc(2026, 6, 26);
    SaleOrdersCompanion ord(String id, String soNumber) =>
        SaleOrdersCompanion.insert(
          id: id,
          organizationId: session.organizationId,
          soNumber: soNumber,
          customerId: 'c1',
          orderDate: now,
          totalAmount: const Value(10),
          createdAt: now,
          updatedAt: now,
        );
    await db.saleOrderDao.createWithItems(ord('1', 'SO-0001'), const []);
    await db.saleOrderDao.createWithItems(ord('2', 'SO-0002'), const []);

    c.read(saleOrderListProvider); // triggers initial load
    await Future<void>.delayed(Duration.zero);
    expect(c.read(saleOrderListProvider).items.length, 2);

    // Changing criteria must reload from page 0 and re-apply the new filter.
    c.read(saleOrderCriteriaProvider.notifier).setSearch('SO-0002');
    await Future<void>.delayed(Duration.zero);
    final s = c.read(saleOrderListProvider);
    expect(s.error, isNull);
    expect(s.items.single.soNumber, 'SO-0002');
  });

  test('date range applies to as inclusive end-of-day', () async {
    final db = newTestDb();
    addTearDown(db.close);
    final session = await SeedService(db, const IdGenerator()).ensureSeeded();

    SaleOrdersCompanion ord(String id, String soNumber, DateTime day) =>
        SaleOrdersCompanion.insert(
          id: id,
          organizationId: session.organizationId,
          soNumber: soNumber,
          customerId: 'c1',
          orderDate: day,
          totalAmount: const Value(10),
          createdAt: day,
          updatedAt: day,
        );
    await db.saleOrderDao.createWithItems(
        ord('1', 'SO-0001', DateTime.utc(2026, 6, 1)), const []);
    await db.saleOrderDao.createWithItems(
        ord('2', 'SO-0002', DateTime.utc(2026, 6, 2)), const []);
    await db.saleOrderDao.createWithItems(
        ord('3', 'SO-0003', DateTime.utc(2026, 6, 3)), const []);

    final rows = await db.saleOrderDao.paged(
      session.organizationId,
      from: DateTime.utc(2026, 6, 2),
      to: DateTime.utc(2026, 6, 2),
      limit: 20,
      offset: 0,
    );

    expect(rows.length, 1);
    expect(rows.single.soNumber, 'SO-0002');
  });
}
