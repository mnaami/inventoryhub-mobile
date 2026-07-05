import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/db/app_database.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/core/result/app_exception.dart';
import 'package:inventoryhub_mobile/core/seed/seed_service.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/data/document_counter_dao.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/data/sale_order_dao.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/data/sale_order_payment_dao.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/data/sale_order_repository_impl.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/data/sale_order_shipping_dao.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/domain/sale_order_enums.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/domain/sale_order_usecases.dart';
import '../../../helpers/test_db.dart';

void main() {
  late dynamic db;
  late SaleOrderService service;

  setUp(() {
    db = newTestDb();
    service = SaleOrderService(
      repository: SaleOrderRepositoryImpl(SaleOrderDao(db),
          SaleOrderPaymentDao(db), SaleOrderShippingDao(db),
          DocumentCounterDao(db)),
      ids: const IdGenerator(),
      organizationId: 'org1',
      userId: 'u1',
    );
  });
  tearDown(() => db.close());

  Future<dynamic> confirmedOrder() async {
    final o = await service.createDraft(customerId: 'c1', lines: [
      NewLine(productId: 'p1', productName: 'Widget', quantity: 1, unitPrice: 100),
    ]);
    await service.confirm(o);
    return (await service.get(o.id))!;
  }

  test('payments cannot be added to a draft', () async {
    final o = await service.createDraft(customerId: 'c1', lines: [
      NewLine(productId: 'p1', productName: 'Widget', quantity: 1, unitPrice: 100),
    ]);
    await expectLater(
      service.addPayment(o, amount: 10, method: PaymentMethod.cash),
      throwsA(isA<ValidationException>()),
    );
  });

  test('partial then full payment drives status to paid', () async {
    final o = await confirmedOrder();
    await service.addPayment(o, amount: 40, method: PaymentMethod.cash);
    expect((await service.get(o.id))!.paymentStatus, PaymentStatus.partial);
    await service.addPayment(await service.get(o.id) as dynamic,
        amount: 60, method: PaymentMethod.bankTransfer);
    expect((await service.get(o.id))!.paymentStatus, PaymentStatus.paid);
    expect((await service.payments(o.id)).length, 2);
  });

  test('overpayment is rejected', () async {
    final o = await confirmedOrder();
    await service.addPayment(o, amount: 80, method: PaymentMethod.cash);
    await expectLater(
      service.addPayment(await service.get(o.id) as dynamic,
          amount: 30, method: PaymentMethod.cash),
      throwsA(isA<ValidationException>()),
    );
  });

  test('deleting a payment recomputes status', () async {
    final o = await confirmedOrder();
    await service.addPayment(o, amount: 100, method: PaymentMethod.cash);
    final p = (await service.payments(o.id)).single;
    await service.deletePayment(p);
    expect((await service.get(o.id))!.paymentStatus, PaymentStatus.notPaid);
  });

  test('listPayments returns page 0 newest-first and honors page offset',
      () async {
    final db = newTestDb();
    addTearDown(db.close);
    final session = await SeedService(db, const IdGenerator()).ensureSeeded();
    final service = SaleOrderService(
      repository: SaleOrderRepositoryImpl(
        SaleOrderDao(db),
        SaleOrderPaymentDao(db),
        SaleOrderShippingDao(db),
        DocumentCounterDao(db),
      ),
      ids: const IdGenerator(),
      organizationId: session.organizationId,
      userId: session.userId,
    );
    final now = DateTime.utc(2026, 6, 1);
    await db.into(db.saleOrders).insert(SaleOrdersCompanion.insert(
          id: 'so1', organizationId: session.organizationId,
          soNumber: 'SO-0001', customerId: 'c1', orderDate: now,
          totalAmount: const Value(1000), createdAt: now, updatedAt: now,
        ));
    for (var i = 1; i <= 25; i++) {
      await db.saleOrderPaymentDao.recordPayment(
          SaleOrderPaymentsCompanion.insert(
        id: 'p$i', organizationId: session.organizationId, saleOrderId: 'so1',
        paymentNumber: 'PAY-${i.toString().padLeft(4, '0')}', amount: 1,
        method: 'cash', status: const Value('completed'),
        paymentDate: DateTime.utc(2026, 6, i), createdAt: now, updatedAt: now,
      ));
    }

    final page0 = await service.listPayments(page: 0);
    final page1 = await service.listPayments(page: 1);
    expect(page0.length, 20); // pageSize
    expect(page1.length, 5);
    // Newest paymentDate first: p25 (6-25) leads page 0.
    expect(page0.first.paymentNumber, 'PAY-0025');
  });
}
