import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/db/app_database.dart';
import '../../../helpers/test_db.dart';

void main() {
  late AppDatabase db;
  final now = DateTime.utc(2026, 6, 26);

  Future<void> seedOrder({double total = 100}) =>
      db.into(db.saleOrders).insert(SaleOrdersCompanion.insert(
            id: 'so1',
            organizationId: 'org1',
            soNumber: 'SO-0001',
            customerId: 'c1',
            orderDate: now,
            totalAmount: Value(total),
            createdAt: now,
            updatedAt: now,
          ));

  SaleOrderPaymentsCompanion pay(String id, double amount,
          {String status = 'completed'}) =>
      SaleOrderPaymentsCompanion.insert(
        id: id,
        organizationId: 'org1',
        saleOrderId: 'so1',
        paymentNumber: 'PAY-000$id',
        amount: amount,
        method: 'cash',
        status: Value(status),
        paymentDate: now,
        createdAt: now,
        updatedAt: now,
      );

  Future<String> status() async =>
      (await db.saleOrderDao.byId('so1'))!.paymentStatus;

  setUp(() async {
    db = newTestDb();
    await seedOrder();
  });
  tearDown(() => db.close());

  test('partial then full payments drive status not_paid -> partial -> paid',
      () async {
    expect(await status(), 'not_paid');
    await db.saleOrderPaymentDao.recordPayment(pay('1', 40));
    expect(await status(), 'partial');
    await db.saleOrderPaymentDao.recordPayment(pay('2', 60));
    expect(await status(), 'paid');
  });

  test('non-completed payments do not count toward paid', () async {
    await db.saleOrderPaymentDao.recordPayment(pay('1', 100, status: 'pending'));
    expect(await status(), 'not_paid');
    expect(await db.saleOrderPaymentDao.completedTotal('so1'), 0);
  });

  test('deleting a payment recomputes status', () async {
    await db.saleOrderPaymentDao.recordPayment(pay('1', 100));
    expect(await status(), 'paid');
    await db.saleOrderPaymentDao.deletePayment('1', now);
    expect(await status(), 'not_paid');
    expect(await db.saleOrderPaymentDao.paymentsFor('so1'), isEmpty);
  });

  test('editing a payment amount recomputes status', () async {
    await db.saleOrderPaymentDao.recordPayment(pay('1', 100));
    expect(await status(), 'paid');
    await db.saleOrderPaymentDao.editPayment('1',
        amount: 30, method: 'cash', status: 'completed', paymentDate: now, now: now);
    expect(await status(), 'partial');
  });

  test('pagedPayments returns active payments across orders, newest first', () async {
    // A second order so the ledger spans more than one order.
    await db.into(db.saleOrders).insert(SaleOrdersCompanion.insert(
          id: 'so2',
          organizationId: 'org1',
          soNumber: 'SO-0002',
          customerId: 'c2',
          orderDate: now,
          totalAmount: const Value(200),
          createdAt: now,
          updatedAt: now,
        ));
    // paymentDate ordering: p_old (older) then p_new (newer).
    await db.saleOrderPaymentDao.recordPayment(
        pay('1', 40).copyWith(paymentDate: Value(DateTime.utc(2026, 6, 1))));
    await db.saleOrderPaymentDao.recordPayment(SaleOrderPaymentsCompanion.insert(
      id: '2',
      organizationId: 'org1',
      saleOrderId: 'so2',
      paymentNumber: 'PAY-0002',
      amount: 60,
      method: 'cash',
      status: const Value('completed'),
      paymentDate: DateTime.utc(2026, 6, 5),
      createdAt: now,
      updatedAt: now,
    ));

    final rows = await db.saleOrderPaymentDao
        .pagedPayments('org1', limit: 20, offset: 0);

    expect(rows.length, 2);
    // Newest paymentDate first.
    expect(rows.first.payment.id, '2');
    expect(rows.first.soNumber, 'SO-0002');
    expect(rows.first.customerId, 'c2');
    expect(rows.last.payment.id, '1');
    expect(rows.last.soNumber, 'SO-0001');
  });

  test('pagedPayments excludes soft-deleted payments', () async {
    await db.saleOrderPaymentDao.recordPayment(pay('1', 40));
    await db.saleOrderPaymentDao.recordPayment(pay('2', 60));
    await db.saleOrderPaymentDao.deletePayment('1', now);

    final rows = await db.saleOrderPaymentDao
        .pagedPayments('org1', limit: 20, offset: 0);

    expect(rows.map((r) => r.payment.id), ['2']);
  });

  test('pagedPayments filters by method, status, search, and date range', () async {
    await db.saleOrderPaymentDao.recordPayment(SaleOrderPaymentsCompanion.insert(
      id: '1', organizationId: 'org1', saleOrderId: 'so1',
      paymentNumber: 'PAY-0001', amount: 10, method: 'cash',
      status: const Value('completed'),
      paymentDate: DateTime.utc(2026, 6, 2), createdAt: now, updatedAt: now,
    ));
    await db.saleOrderPaymentDao.recordPayment(SaleOrderPaymentsCompanion.insert(
      id: '2', organizationId: 'org1', saleOrderId: 'so1',
      paymentNumber: 'PAY-0002', amount: 20, method: 'bank_transfer',
      status: const Value('pending'),
      paymentDate: DateTime.utc(2026, 6, 4), createdAt: now, updatedAt: now,
    ));

    expect(
        (await db.saleOrderPaymentDao.pagedPayments('org1',
                method: 'cash', limit: 20, offset: 0))
            .map((r) => r.payment.id),
        ['1']);
    expect(
        (await db.saleOrderPaymentDao.pagedPayments('org1',
                status: 'pending', limit: 20, offset: 0))
            .map((r) => r.payment.id),
        ['2']);
    expect(
        (await db.saleOrderPaymentDao.pagedPayments('org1',
                search: 'SO-0001', limit: 20, offset: 0))
            .length,
        2);
    expect(
        (await db.saleOrderPaymentDao.pagedPayments('org1',
                search: 'SO-9999', limit: 20, offset: 0))
            .length,
        0);
    // to is EXCLUSIVE: window [6-01, 6-04) excludes the 6-04 payment.
    expect(
        (await db.saleOrderPaymentDao.pagedPayments('org1',
                from: DateTime.utc(2026, 6, 1),
                to: DateTime.utc(2026, 6, 4),
                limit: 20, offset: 0))
            .map((r) => r.payment.id),
        ['1']);
  });

  test('pagedPayments applies limit and offset', () async {
    for (var i = 1; i <= 3; i++) {
      await db.saleOrderPaymentDao.recordPayment(
          pay('$i', 10).copyWith(paymentDate: Value(DateTime.utc(2026, 6, i))));
    }
    final page0 = await db.saleOrderPaymentDao
        .pagedPayments('org1', limit: 2, offset: 0);
    final page1 = await db.saleOrderPaymentDao
        .pagedPayments('org1', limit: 2, offset: 2);
    expect(page0.length, 2);
    expect(page1.length, 1);
    // Newest first: 6-03, 6-02 on page 0; 6-01 on page 1.
    expect(page0.first.payment.paymentDate.toUtc(), DateTime.utc(2026, 6, 3));
    expect(page1.single.payment.paymentDate.toUtc(), DateTime.utc(2026, 6, 1));
  });
}
