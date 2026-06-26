import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/core/result/app_exception.dart';
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
}
