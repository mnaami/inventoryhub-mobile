import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/db/app_database.dart';
import '../../../helpers/test_db.dart';

void main() {
  late AppDatabase db;
  final now = DateTime.utc(2026, 6, 26);

  SaleOrdersCompanion order(String id, {String status = 'draft'}) =>
      SaleOrdersCompanion.insert(
        id: id,
        organizationId: 'org1',
        soNumber: 'SO-000$id',
        customerId: 'c1',
        orderDate: now,
        status: Value(status),
        totalAmount: const Value(50),
        createdAt: now,
        updatedAt: now,
      );

  SaleOrderItemsCompanion item(String id, String orderId, double qty) =>
      SaleOrderItemsCompanion.insert(
        id: id,
        organizationId: 'org1',
        saleOrderId: orderId,
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
    await db.saleOrderDao
        .createWithItems(order('1'), [item('i1', '1', 2)]);
    expect((await db.saleOrderDao.byId('1'))!.soNumber, 'SO-0001');
    expect((await db.saleOrderDao.itemsFor('1')).single.quantity, 2);
  });

  test('replaceItems swaps lines and updates total', () async {
    await db.saleOrderDao.createWithItems(order('1'), [item('i1', '1', 2)]);
    await db.saleOrderDao.replaceItems('1', [item('i2', '1', 4)],
        totalAmount: 100, now: now);
    final items = await db.saleOrderDao.itemsFor('1');
    expect(items.single.id, 'i2');
    expect((await db.saleOrderDao.byId('1'))!.totalAmount, 100);
  });

  test('paged filters by status', () async {
    await db.saleOrderDao.createWithItems(order('1'), const []);
    await db.saleOrderDao.createWithItems(order('2', status: 'confirmed'), const []);
    final confirmed = await db.saleOrderDao
        .paged('org1', status: 'confirmed', limit: 20, offset: 0);
    expect(confirmed.single.id, '2');
  });

  test('countLiveForCustomer ignores cancelled and inactive orders', () async {
    await db.saleOrderDao.createWithItems(order('1', status: 'confirmed'), const []);
    await db.saleOrderDao.createWithItems(order('2', status: 'cancelled'), const []);
    expect(await db.saleOrderDao.countLiveForCustomer('org1', 'c1'), 1);
  });
}
