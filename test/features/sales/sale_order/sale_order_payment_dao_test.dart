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
}
