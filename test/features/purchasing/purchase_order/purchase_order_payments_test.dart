import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/db/app_database.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/core/result/app_exception.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/data/document_counter_dao.dart';
import 'package:inventoryhub_mobile/features/purchasing/purchase_order/data/purchase_order_dao.dart';
import 'package:inventoryhub_mobile/features/purchasing/purchase_order/data/purchase_order_payment_dao.dart';
import 'package:inventoryhub_mobile/features/purchasing/purchase_order/data/purchase_order_receipt_dao.dart';
import 'package:inventoryhub_mobile/features/purchasing/purchase_order/data/purchase_order_repository_impl.dart';
import 'package:inventoryhub_mobile/features/purchasing/purchase_order/domain/purchase_order.dart';
import 'package:inventoryhub_mobile/features/purchasing/purchase_order/domain/purchase_order_enums.dart';
import 'package:inventoryhub_mobile/features/purchasing/purchase_order/domain/purchase_order_usecases.dart';
import '../../../helpers/test_db.dart';

void main() {
  late AppDatabase db;
  late PurchaseOrderService service;

  setUp(() {
    db = newTestDb();
    service = PurchaseOrderService(
      repository: PurchaseOrderRepositoryImpl(PurchaseOrderDao(db),
          PurchaseOrderReceiptDao(db), PurchaseOrderPaymentDao(db),
          DocumentCounterDao(db)),
      ids: const IdGenerator(),
      organizationId: 'org1',
      userId: 'u1',
    );
  });
  tearDown(() => db.close());

  Future<PurchaseOrder> confirmedOrder() async {
    final o = await service.createDraft(supplierId: 's1', lines: [
      NewLine(productId: 'p1', productName: 'Widget', quantity: 1, unitPrice: 100),
    ]);
    await service.send(o);
    await service.confirm((await service.get(o.id))!);
    return (await service.get(o.id))!;
  }

  test('payments cannot be added to a draft order', () async {
    final o = await service.createDraft(supplierId: 's1', lines: [
      NewLine(productId: 'p1', productName: 'Widget', quantity: 1, unitPrice: 100),
    ]);
    await expectLater(
      service.addPayment(o, amount: 10, method: PaymentMethod.cash),
      throwsA(isA<ValidationException>()),
    );
  });

  test('draft payment does not count; posting drives partial then paid', () async {
    final o = await confirmedOrder();
    await service.addPayment(o, amount: 40, method: PaymentMethod.cash);
    expect((await service.get(o.id))!.paymentStatus, PaymentStatus.notPaid);
    final p1 = (await service.payments(o.id)).single;
    await service.postPayment(o, p1);
    expect((await service.get(o.id))!.paymentStatus, PaymentStatus.partial);
    await service.addPayment(o, amount: 60, method: PaymentMethod.bankTransfer);
    final p2 = (await service.payments(o.id)).firstWhere((p) => p.id != p1.id);
    await service.postPayment((await service.get(o.id))!, p2);
    expect((await service.get(o.id))!.paymentStatus, PaymentStatus.paid);
  });

  test('overpayment is rejected at post', () async {
    final o = await confirmedOrder();
    await service.addPayment(o, amount: 80, method: PaymentMethod.cash);
    final p1 = (await service.payments(o.id)).single;
    await service.postPayment(o, p1);
    await service.addPayment((await service.get(o.id))!, amount: 30, method: PaymentMethod.cash);
    final p2 = (await service.payments(o.id)).firstWhere((p) => p.id != p1.id);
    await expectLater(
      service.postPayment((await service.get(o.id))!, p2),
      throwsA(isA<ValidationException>()),
    );
  });

  test('cancelling a draft payment removes it', () async {
    final o = await confirmedOrder();
    await service.addPayment(o, amount: 50, method: PaymentMethod.cash);
    final p = (await service.payments(o.id)).single;
    await service.cancelPayment(p);
    expect(await service.payments(o.id), isEmpty);
  });
}
