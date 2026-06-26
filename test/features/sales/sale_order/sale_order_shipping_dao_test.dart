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
}
