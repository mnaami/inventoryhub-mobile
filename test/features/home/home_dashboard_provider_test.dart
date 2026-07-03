import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/db/app_database.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/core/providers.dart';
import 'package:inventoryhub_mobile/core/seed/seed_service.dart';
import 'package:inventoryhub_mobile/features/home/presentation/home_providers.dart';
import 'package:inventoryhub_mobile/features/production/production_order/presentation/production_order_providers.dart';
import 'package:inventoryhub_mobile/features/purchasing/purchase_order/presentation/purchase_order_providers.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/presentation/sale_order_providers.dart';
import '../../helpers/test_db.dart';

void main() {
  test('homeDashboardProvider maps every field from the services', () async {
    final db = newTestDb();
    addTearDown(db.close);
    final session = await SeedService(db, const IdGenerator()).ensureSeeded();
    final container = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
      sessionProvider.overrideWithValue(session),
    ]);
    addTearDown(container.dispose);

    // One confirmed, unpaid, unshipped order dated now → shows up in every
    // sales period and in receivables/open-work counts.
    final nowUtc = DateTime.now().toUtc();
    await db.saleOrderDao.createWithItems(
      SaleOrdersCompanion.insert(
        id: 'so1',
        organizationId: session.organizationId,
        soNumber: 'SO-9001',
        customerId: 'c1',
        orderDate: nowUtc,
        status: const Value('confirmed'),
        paymentStatus: const Value('not_paid'),
        shippingStatus: const Value('not_shipped'),
        totalAmount: const Value(100),
        createdAt: nowUtc,
        updatedAt: nowUtc,
      ),
      const [],
    );

    final data = await container.read(homeDashboardProvider.future);
    final saleKpis =
        await container.read(saleOrderServiceProvider).dashboard();
    final purchaseKpis =
        await container.read(purchaseOrderServiceProvider).dashboard();
    final productionKpis =
        await container.read(productionOrderServiceProvider).dashboard();

    // Sales figures.
    expect(data.today.orderCount, 1);
    expect(data.today.revenue, 100);
    expect(data.thisWeek.orderCount, 1);
    expect(data.thisWeek.revenue, 100);
    expect(data.thisMonth.orderCount, 1);
    expect(data.thisMonth.revenue, 100);
    // Money in/out — mapped 1:1 from the KPIs.
    expect(data.receivables, saleKpis.outstanding);
    expect(data.payables, purchaseKpis.outstanding);
    // Stock snapshot — seeded db has no products.
    expect(data.stockValue, 0);
    expect(data.lowStockCount, 0);
    expect(data.outOfStockCount, 0);
    // Open work.
    expect(data.openSaleOrders, saleKpis.openOrders);
    expect(data.unshippedOrders, saleKpis.unshipped);
    expect(data.openPurchaseOrders, purchaseKpis.openOrders);
    expect(data.unreceivedOrders, purchaseKpis.unreceived);
    expect(data.productionInProgress, productionKpis.inProgress);
    // Trend series — dense, correct lengths, order lands in the last bucket.
    expect(data.trendToday.length, 24);
    expect(data.trend7d.length, 7);
    expect(data.trend30d.length, 30);
    expect(data.trend7d.last.total, 100);
    expect(data.trend30d.last.total, 100);
    expect(data.trendToday.fold<double>(0, (a, p) => a + p.total), 100);
  });
}
