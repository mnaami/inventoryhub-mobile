import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/db/app_database.dart';
import '../../../helpers/test_db.dart';

void main() {
  late AppDatabase db;
  final now = DateTime.utc(2026, 6, 26);

  Future<void> seedOrder({double total = 100}) =>
      db.into(db.purchaseOrders).insert(PurchaseOrdersCompanion.insert(
            id: 'po1',
            organizationId: 'org1',
            orderNumber: 'PO-0001',
            supplierId: 's1',
            orderDate: now,
            totalAmount: Value(total),
            createdAt: now,
            updatedAt: now,
          ));

  PurchaseOrderPaymentsCompanion pay(String id, double amount,
          {String status = 'draft'}) =>
      PurchaseOrderPaymentsCompanion.insert(
        id: id,
        organizationId: 'org1',
        purchaseOrderId: 'po1',
        paymentNumber: 'PPAY-000$id',
        amount: amount,
        method: 'cash',
        status: Value(status),
        paymentDate: now,
        createdAt: now,
        updatedAt: now,
      );

  Future<String> status() async =>
      (await db.purchaseOrderDao.byId('po1'))!.paymentStatus;

  setUp(() async {
    db = newTestDb();
    await seedOrder();
  });
  tearDown(() => db.close());

  test('draft payments do not count; posting drives partial -> paid', () async {
    await db.purchaseOrderPaymentDao.createDraft(pay('1', 40));
    expect(await status(), 'not_paid'); // draft doesn't count
    expect(await db.purchaseOrderPaymentDao.postedTotal('po1'), 0);
    await db.purchaseOrderPaymentDao.post('1', now);
    expect(await status(), 'partial');
    await db.purchaseOrderPaymentDao.createDraft(pay('2', 60));
    await db.purchaseOrderPaymentDao.post('2', now);
    expect(await status(), 'paid');
  });

  test('cancelling a posted-then... only drafts cancellable; cancel recomputes',
      () async {
    await db.purchaseOrderPaymentDao.createDraft(pay('1', 100));
    await db.purchaseOrderPaymentDao.post('1', now);
    expect(await status(), 'paid');
    // posting reflected; now a fresh draft that is cancelled does not change it
    await db.purchaseOrderPaymentDao.createDraft(pay('2', 20));
    await db.purchaseOrderPaymentDao.cancelDraft('2', now);
    expect(await status(), 'paid'); // draft cancel doesn't affect posted sum
    expect(await db.purchaseOrderPaymentDao.paymentsFor('po1'),
        hasLength(1)); // cancelled excluded
  });

  test('editing a draft does not change status', () async {
    await db.purchaseOrderPaymentDao.createDraft(pay('1', 100));
    await db.purchaseOrderPaymentDao.editDraft('1',
        amount: 30, method: 'cash', paymentDate: now, now: now);
    expect(await status(), 'not_paid'); // still draft
    await db.purchaseOrderPaymentDao.post('1', now);
    expect(await status(), 'partial'); // 30 of 100
  });
}
