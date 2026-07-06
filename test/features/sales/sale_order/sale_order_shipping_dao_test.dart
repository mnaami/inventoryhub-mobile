import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/result/app_exception.dart';
import 'package:inventoryhub_mobile/core/db/app_database.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/data/sale_order_shipping_dao.dart';
import '../../../helpers/test_db.dart';

void main() {
  late AppDatabase db;
  final now = DateTime.utc(2026, 6, 26);

  setUp(() async {
    db = newTestDb();
    // product p1 with 5 in stock
    await db.into(db.products).insert(ProductsCompanion.insert(
          id: 'p1', organizationId: 'org1', name: 'Widget', unitId: 'pc',
          currentStock: const Value(5), createdAt: now, updatedAt: now,
        ));
    // order so1 with item i1 ordered qty 10
    await db.into(db.saleOrders).insert(SaleOrdersCompanion.insert(
          id: 'so1', organizationId: 'org1', soNumber: 'SO-0001',
          customerId: 'c1', orderDate: now, status: const Value('processing'),
          createdAt: now, updatedAt: now,
        ));
    await db.into(db.saleOrderItems).insert(SaleOrderItemsCompanion.insert(
          id: 'i1', organizationId: 'org1', saleOrderId: 'so1', productId: 'p1',
          productName: 'Widget', quantity: 10, unitPrice: 1, totalPrice: 10,
          createdAt: now, updatedAt: now,
        ));
  });
  tearDown(() => db.close());

  SaleOrderShippingsCompanion shipping(String id) =>
      SaleOrderShippingsCompanion.insert(
        id: id, organizationId: 'org1', saleOrderId: 'so1',
        soShippingNumber: 'SHP-000$id', shippingDate: now,
        createdAt: now, updatedAt: now,
      );

  test('shipping decrements stock via ledger, bumps shipped_qty, partial status',
      () async {
    await db.saleOrderShippingDao.createShipment(
      shipping: shipping('1'),
      lines: [ShipmentLine(
          saleOrderItemId: 'i1', productId: 'p1', movementId: 'm1', quantity: 4)],
      orgId: 'org1', createdBy: 'u1', now: now,
    );

    final product =
        await (db.select(db.products)..where((p) => p.id.equals('p1'))).getSingle();
    expect(product.currentStock, 1); // 5 - 4

    final movement = await db.select(db.stockMovements).getSingle();
    expect(movement.quantity, -4);
    expect(movement.referenceType, 'sale_order_shipping');
    expect(movement.referenceId, '1');

    final item =
        await (db.select(db.saleOrderItems)..where((i) => i.id.equals('i1'))).getSingle();
    expect(item.shippedQuantity, 4);

    final order =
        await (db.select(db.saleOrders)..where((o) => o.id.equals('so1'))).getSingle();
    expect(order.shippingStatus, 'partially_shipped');
    expect(order.status, 'processing');
  });

  test('fully shipping advances shipping_status and order to shipped', () async {
    await db.saleOrderShippingDao.createShipment(
      shipping: shipping('1'),
      lines: [ShipmentLine(
          saleOrderItemId: 'i1', productId: 'p1', movementId: 'm1', quantity: 5)],
      orgId: 'org1', createdBy: 'u1', now: now,
    );
    // restock so the remaining 5 can ship
    await db.stockMovementDao.record(
      StockMovementsCompanion.insert(
          id: 'restock', organizationId: 'org1', productId: 'p1',
          movementType: 'in', quantity: 5, createdBy: 'u1', createdAt: now),
      productId: 'p1', delta: 5,
    );
    await db.saleOrderShippingDao.createShipment(
      shipping: shipping('2'),
      lines: [ShipmentLine(
          saleOrderItemId: 'i1', productId: 'p1', movementId: 'm2', quantity: 5)],
      orgId: 'org1', createdBy: 'u1', now: now,
    );
    final order =
        await (db.select(db.saleOrders)..where((o) => o.id.equals('so1'))).getSingle();
    expect(order.shippingStatus, 'fully_shipped');
    expect(order.status, 'shipped');
  });

  test('oversell rolls back the entire shipment', () async {
    await expectLater(
      db.saleOrderShippingDao.createShipment(
        shipping: shipping('1'),
        lines: [ShipmentLine(
            saleOrderItemId: 'i1', productId: 'p1', movementId: 'm1', quantity: 6)],
        orgId: 'org1', createdBy: 'u1', now: now,
      ),
      throwsA(isA<ConflictException>()),
    );
    final product =
        await (db.select(db.products)..where((p) => p.id.equals('p1'))).getSingle();
    expect(product.currentStock, 5); // unchanged
    expect(await db.select(db.stockMovements).get(), isEmpty);
    expect(await db.select(db.saleOrderShippings).get(), isEmpty);
    final item =
        await (db.select(db.saleOrderItems)..where((i) => i.id.equals('i1'))).getSingle();
    expect(item.shippedQuantity, 0);
  });

  test(
      'two lines for same product aggregated — blocks oversell across duplicate lines',
      () async {
    // Add a second sale_order_item for the same product p1 on order so1.
    await db.into(db.saleOrderItems).insert(SaleOrderItemsCompanion.insert(
          id: 'i2',
          organizationId: 'org1',
          saleOrderId: 'so1',
          productId: 'p1',
          productName: 'Widget',
          quantity: 4,
          unitPrice: 1,
          totalPrice: 4,
          createdAt: now,
          updatedAt: now,
        ));

    // Two ShipmentLines for the same product: 3 + 3 = 6, but stock is only 5.
    final future = db.saleOrderShippingDao.createShipment(
      shipping: shipping('1'),
      lines: [
        ShipmentLine(
            saleOrderItemId: 'i1',
            productId: 'p1',
            movementId: 'm1',
            quantity: 3),
        ShipmentLine(
            saleOrderItemId: 'i2',
            productId: 'p1',
            movementId: 'm2',
            quantity: 3),
      ],
      orgId: 'org1',
      createdBy: 'u1',
      now: now,
    );

    await expectLater(future, throwsA(isA<ConflictException>()));

    // Nothing must have been written.
    final product = await (db.select(db.products)
          ..where((p) => p.id.equals('p1')))
        .getSingle();
    expect(product.currentStock, 5); // unchanged

    expect(await db.select(db.stockMovements).get(), isEmpty);
    expect(await db.select(db.saleOrderShippings).get(), isEmpty);
    expect(await db.select(db.saleOrderShippingItems).get(), isEmpty);

    final item1 = await (db.select(db.saleOrderItems)
          ..where((i) => i.id.equals('i1')))
        .getSingle();
    expect(item1.shippedQuantity, 0);

    final item2 = await (db.select(db.saleOrderItems)
          ..where((i) => i.id.equals('i2')))
        .getSingle();
    expect(item2.shippedQuantity, 0);
  });

  test('saleOrderIdFor resolves the parent SO of a shipment', () async {
    await db.saleOrderShippingDao.createShipment(
      shipping: shipping('1'),
      lines: [ShipmentLine(
          saleOrderItemId: 'i1', productId: 'p1', movementId: 'm1', quantity: 4)],
      orgId: 'org1', createdBy: 'u1', now: now,
    );
    expect(await db.saleOrderShippingDao.saleOrderIdFor('1'), 'so1');
    expect(await db.saleOrderShippingDao.saleOrderIdFor('missing'), null);
  });

  test('marking a shipment delivered advances the order to delivered', () async {
    await db.saleOrderShippingDao.createShipment(
      shipping: shipping('1'),
      lines: [ShipmentLine(
          saleOrderItemId: 'i1', productId: 'p1', movementId: 'm1', quantity: 5)],
      orgId: 'org1', createdBy: 'u1', now: now,
    );
    await db.saleOrderShippingDao.setStatus('1', 'delivered', now);
    final order =
        await (db.select(db.saleOrders)..where((o) => o.id.equals('so1'))).getSingle();
    expect(order.status, 'delivered');
  });

  test('pagedShipments returns shipments across orders, newest first, with order context',
      () async {
    // second, live order
    await db.into(db.saleOrders).insert(SaleOrdersCompanion.insert(
          id: 'so2', organizationId: 'org1', soNumber: 'SO-0002',
          customerId: 'c2', orderDate: now, status: const Value('processing'),
          createdAt: now, updatedAt: now,
        ));
    await db.into(db.saleOrderShippings).insert(SaleOrderShippingsCompanion.insert(
          id: 's_old', organizationId: 'org1', saleOrderId: 'so1',
          soShippingNumber: 'SHP-0001', shippingDate: DateTime.utc(2026, 6, 1),
          status: const Value('shipped'), createdAt: now, updatedAt: now,
        ));
    await db.into(db.saleOrderShippings).insert(SaleOrderShippingsCompanion.insert(
          id: 's_new', organizationId: 'org1', saleOrderId: 'so2',
          soShippingNumber: 'SHP-0002', shippingDate: DateTime.utc(2026, 6, 5),
          status: const Value('delivered'), createdAt: now, updatedAt: now,
        ));

    final rows = await db.saleOrderShippingDao
        .pagedShipments('org1', limit: 20, offset: 0);

    expect(rows.length, 2);
    expect(rows.first.shipment.id, 's_new'); // newest shippingDate first
    expect(rows.first.soNumber, 'SO-0002');
    expect(rows.first.customerId, 'c2');
    expect(rows.last.shipment.id, 's_old');
    expect(rows.last.soNumber, 'SO-0001');
  });

  test('pagedShipments excludes shipments of soft-deleted orders', () async {
    await db.into(db.saleOrderShippings).insert(SaleOrderShippingsCompanion.insert(
          id: 's1', organizationId: 'org1', saleOrderId: 'so1',
          soShippingNumber: 'SHP-0001', shippingDate: now,
          createdAt: now, updatedAt: now,
        ));
    // soft-delete the order
    await db.saleOrderDao.softDelete('so1', now);

    final rows = await db.saleOrderShippingDao
        .pagedShipments('org1', limit: 20, offset: 0);

    expect(rows, isEmpty);
  });

  test('pagedShipments filters by status, search, and date range', () async {
    await db.into(db.saleOrderShippings).insert(SaleOrderShippingsCompanion.insert(
          id: 's1', organizationId: 'org1', saleOrderId: 'so1',
          soShippingNumber: 'SHP-0001', shippingDate: DateTime.utc(2026, 6, 2),
          status: const Value('shipped'), createdAt: now, updatedAt: now,
        ));
    await db.into(db.saleOrderShippings).insert(SaleOrderShippingsCompanion.insert(
          id: 's2', organizationId: 'org1', saleOrderId: 'so1',
          soShippingNumber: 'SHP-0002', shippingDate: DateTime.utc(2026, 6, 4),
          status: const Value('delivered'), createdAt: now, updatedAt: now,
        ));

    expect(
        (await db.saleOrderShippingDao.pagedShipments('org1',
                status: 'shipped', limit: 20, offset: 0))
            .map((r) => r.shipment.id),
        ['s1']);
    expect(
        (await db.saleOrderShippingDao.pagedShipments('org1',
                search: 'SO-0001', limit: 20, offset: 0))
            .length,
        2);
    expect(
        (await db.saleOrderShippingDao.pagedShipments('org1',
                search: 'SO-9999', limit: 20, offset: 0))
            .length,
        0);
    // to is EXCLUSIVE: window [6-01, 6-04) excludes the 6-04 shipment.
    expect(
        (await db.saleOrderShippingDao.pagedShipments('org1',
                from: DateTime.utc(2026, 6, 1),
                to: DateTime.utc(2026, 6, 4),
                limit: 20, offset: 0))
            .map((r) => r.shipment.id),
        ['s1']);
  });

  test('pagedShipments applies limit and offset', () async {
    for (var i = 1; i <= 3; i++) {
      await db.into(db.saleOrderShippings).insert(SaleOrderShippingsCompanion.insert(
            id: 's$i', organizationId: 'org1', saleOrderId: 'so1',
            soShippingNumber: 'SHP-000$i', shippingDate: DateTime.utc(2026, 6, i),
            createdAt: now, updatedAt: now,
          ));
    }
    final page0 = await db.saleOrderShippingDao
        .pagedShipments('org1', limit: 2, offset: 0);
    final page1 = await db.saleOrderShippingDao
        .pagedShipments('org1', limit: 2, offset: 2);
    expect(page0.length, 2);
    expect(page1.length, 1);
    expect(page0.first.shipment.shippingDate.toUtc(), DateTime.utc(2026, 6, 3));
    expect(page1.single.shipment.shippingDate.toUtc(), DateTime.utc(2026, 6, 1));
  });
}
