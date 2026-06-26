import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/db/app_database.dart';
import '../../../helpers/test_db.dart';

void main() {
  late AppDatabase db;
  final now = DateTime.utc(2026, 6, 26);

  PurchaseOrdersCompanion order(String id, {String status = 'draft'}) =>
      PurchaseOrdersCompanion.insert(
        id: id,
        organizationId: 'org1',
        orderNumber: 'PO-000$id',
        supplierId: 's1',
        orderDate: now,
        status: Value(status),
        totalAmount: const Value(50),
        createdAt: now,
        updatedAt: now,
      );

  PurchaseOrderItemsCompanion item(String id, String poId, double qty) =>
      PurchaseOrderItemsCompanion.insert(
        id: id,
        organizationId: 'org1',
        purchaseOrderId: poId,
        productId: 'p1',
        productName: 'Widget',
        quantity: qty,
        unitPrice: 25,
        totalPrice: qty * 25,
        createdAt: now,
        updatedAt: now,
      );

  setUp(() => db = newTestDb());
  tearDown(() => db.close());

  test('createWithItems persists order and its items atomically', () async {
    await db.purchaseOrderDao.createWithItems(order('1'), [item('i1', '1', 2)]);
    expect((await db.purchaseOrderDao.byId('1'))!.orderNumber, 'PO-0001');
    expect((await db.purchaseOrderDao.itemsFor('1')).single.quantity, 2);
  });

  test('replaceItems swaps lines and updates total', () async {
    await db.purchaseOrderDao.createWithItems(order('1'), [item('i1', '1', 2)]);
    await db.purchaseOrderDao
        .replaceItems('1', [item('i2', '1', 4)], totalAmount: 100, now: now);
    final items = await db.purchaseOrderDao.itemsFor('1');
    expect(items.single.id, 'i2');
    expect((await db.purchaseOrderDao.byId('1'))!.totalAmount, 100);
  });

  test('paged filters by status', () async {
    await db.purchaseOrderDao.createWithItems(order('1'), const []);
    await db.purchaseOrderDao
        .createWithItems(order('2', status: 'confirmed'), const []);
    final confirmed = await db.purchaseOrderDao
        .paged('org1', status: 'confirmed', limit: 20, offset: 0);
    expect(confirmed.single.id, '2');
  });

  test('countLiveForSupplier ignores cancelled and inactive orders', () async {
    await db.purchaseOrderDao
        .createWithItems(order('1', status: 'confirmed'), const []);
    await db.purchaseOrderDao
        .createWithItems(order('2', status: 'cancelled'), const []);
    expect(await db.purchaseOrderDao.countLiveForSupplier('org1', 's1'), 1);
  });
}
