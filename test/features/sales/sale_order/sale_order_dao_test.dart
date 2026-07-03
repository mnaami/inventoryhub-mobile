import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/db/app_database.dart';
import '../../../helpers/test_db.dart';

void main() {
  late AppDatabase db;
  final now = DateTime.utc(2026, 6, 26);

  SaleOrdersCompanion order(
    String id, {
    String status = 'draft',
    String soNumber = '',
    String paymentStatus = 'not_paid',
    String shippingStatus = 'not_shipped',
    DateTime? orderDate,
    DateTime? createdAt,
  }) =>
      SaleOrdersCompanion.insert(
        id: id,
        organizationId: 'org1',
        soNumber: soNumber.isEmpty ? 'SO-000$id' : soNumber,
        customerId: 'c1',
        orderDate: orderDate ?? now,
        status: Value(status),
        paymentStatus: Value(paymentStatus),
        shippingStatus: Value(shippingStatus),
        totalAmount: const Value(50),
        createdAt: createdAt ?? now,
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

  test('paged filters by search on so_number', () async {
    await db.saleOrderDao.createWithItems(order('1', soNumber: 'SO-1001'), const []);
    await db.saleOrderDao.createWithItems(order('2', soNumber: 'SO-2002'), const []);
    final hits =
        await db.saleOrderDao.paged('org1', search: '2002', limit: 20, offset: 0);
    expect(hits.single.id, '2');
  });

  test('paged filters by payment and shipping status', () async {
    await db.saleOrderDao.createWithItems(
        order('1', paymentStatus: 'paid', shippingStatus: 'fully_shipped'), const []);
    await db.saleOrderDao.createWithItems(
        order('2', paymentStatus: 'partial', shippingStatus: 'not_shipped'), const []);
    final paid =
        await db.saleOrderDao.paged('org1', paymentStatus: 'paid', limit: 20, offset: 0);
    expect(paid.single.id, '1');
    final notShipped = await db.saleOrderDao
        .paged('org1', shippingStatus: 'not_shipped', limit: 20, offset: 0);
    expect(notShipped.single.id, '2');
  });

  test('paged filters by created_at range', () async {
    await db.saleOrderDao.createWithItems(
        order('1', createdAt: DateTime.utc(2026, 1, 1)), const []);
    await db.saleOrderDao.createWithItems(
        order('2', createdAt: DateTime.utc(2026, 6, 1)), const []);
    final recent = await db.saleOrderDao.paged('org1',
        from: DateTime.utc(2026, 5, 1), to: DateTime.utc(2026, 7, 1),
        limit: 20, offset: 0);
    expect(recent.single.id, '2');
  });

  test('paged honours limit and offset', () async {
    for (var i = 0; i < 5; i++) {
      await db.saleOrderDao.createWithItems(order('$i'), const []);
    }
    final firstTwo = await db.saleOrderDao.paged('org1', limit: 2, offset: 0);
    final nextTwo = await db.saleOrderDao.paged('org1', limit: 2, offset: 2);
    expect(firstTwo.length, 2);
    expect(nextTwo.length, 2);
    expect(firstTwo.map((r) => r.id).toSet().intersection(
        nextTwo.map((r) => r.id).toSet()), isEmpty);
  });

  test('salesInRange applies the same filters as totalAmountByDateRange',
      () async {
    // In range, draft — included (drafts count toward revenue KPIs).
    await db.saleOrderDao.createWithItems(
        order('1', orderDate: DateTime.utc(2026, 6, 20, 10)), const []);
    // In range but cancelled — excluded.
    await db.saleOrderDao.createWithItems(
        order('2', status: 'cancelled', orderDate: DateTime.utc(2026, 6, 20)),
        const []);
    // Before `from` — excluded.
    await db.saleOrderDao.createWithItems(
        order('3', orderDate: DateTime.utc(2026, 6, 19, 23)), const []);
    // Exactly `to` — excluded (exclusive upper bound).
    await db.saleOrderDao.createWithItems(
        order('4', orderDate: DateTime.utc(2026, 6, 21)), const []);
    // In range but soft-deleted — excluded.
    await db.saleOrderDao.createWithItems(
        order('5', orderDate: DateTime.utc(2026, 6, 20, 12)), const []);
    await db.saleOrderDao.softDelete('5', now);

    final rows = await db.saleOrderDao.salesInRange(
        'org1', DateTime.utc(2026, 6, 20), DateTime.utc(2026, 6, 21));

    expect(rows.length, 1);
    expect(rows.single.totalAmount, 50); // order() helper's fixed total
    expect(rows.single.orderDate.toUtc(), DateTime.utc(2026, 6, 20, 10));
  });

  test('salesInRange includes the from instant (inclusive lower bound)',
      () async {
    await db.saleOrderDao.createWithItems(
        order('1', orderDate: DateTime.utc(2026, 6, 20)), const []);
    final rows = await db.saleOrderDao.salesInRange(
        'org1', DateTime.utc(2026, 6, 20), DateTime.utc(2026, 6, 21));
    expect(rows.length, 1);
  });
}
