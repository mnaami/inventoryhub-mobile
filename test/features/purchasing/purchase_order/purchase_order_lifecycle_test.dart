import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/db/app_database.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/core/result/app_exception.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/data/document_counter_dao.dart';
import 'package:inventoryhub_mobile/features/purchasing/purchase_order/data/purchase_order_dao.dart';
import 'package:inventoryhub_mobile/features/purchasing/purchase_order/data/purchase_order_payment_dao.dart';
import 'package:inventoryhub_mobile/features/purchasing/purchase_order/data/purchase_order_receipt_dao.dart';
import 'package:inventoryhub_mobile/features/purchasing/purchase_order/data/purchase_order_repository_impl.dart';
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

  NewLine line(double qty, double price) =>
      NewLine(productId: 'p1', productName: 'Widget', quantity: qty, unitPrice: price);

  test('createDraft assigns PO number, computes total, starts as draft', () async {
    final o = await service.createDraft(supplierId: 's1', lines: [line(2, 25)]);
    expect(o.orderNumber, 'PO-0001');
    expect(o.totalAmount, 50);
    expect(o.status, PurchaseOrderStatus.draft);
    expect((await service.items(o.id)).single.totalPrice, 50);
  });

  test('createDraft rejects empty lines', () async {
    await expectLater(service.createDraft(supplierId: 's1', lines: const []),
        throwsA(isA<ValidationException>()));
  });

  test('send then confirm: draft -> sent -> confirmed; illegal jumps rejected',
      () async {
    final o = await service.createDraft(supplierId: 's1', lines: [line(1, 10)]);
    await expectLater(service.confirm(o), throwsA(isA<ValidationException>())); // not sent yet
    await service.send(o);
    expect((await service.get(o.id))!.status, PurchaseOrderStatus.sent);
    await service.confirm((await service.get(o.id))!);
    expect((await service.get(o.id))!.status, PurchaseOrderStatus.confirmed);
  });

  test('editDraft rejected once sent', () async {
    final o = await service.createDraft(supplierId: 's1', lines: [line(1, 10)]);
    await service.send(o);
    await expectLater(service.editDraft((await service.get(o.id))!, [line(2, 10)]),
        throwsA(isA<ValidationException>()));
  });

  test('cancel from confirmed sets cancelled', () async {
    final o = await service.createDraft(supplierId: 's1', lines: [line(1, 10)]);
    await service.send(o);
    await service.confirm((await service.get(o.id))!);
    await service.cancel((await service.get(o.id))!);
    expect((await service.get(o.id))!.status, PurchaseOrderStatus.cancelled);
  });
}
