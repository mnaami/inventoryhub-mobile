import 'package:drift/drift.dart';
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
  final now = DateTime.utc(2026, 6, 26);

  setUp(() async {
    db = newTestDb();
    service = PurchaseOrderService(
      repository: PurchaseOrderRepositoryImpl(PurchaseOrderDao(db),
          PurchaseOrderReceiptDao(db), PurchaseOrderPaymentDao(db),
          DocumentCounterDao(db)),
      ids: const IdGenerator(),
      organizationId: 'org1',
      userId: 'u1',
    );
    await db.into(db.products).insert(ProductsCompanion.insert(
          id: 'p1', organizationId: 'org1', name: 'Widget', unitId: 'pc',
          currentStock: const Value(0), createdAt: now, updatedAt: now,
        ));
  });
  tearDown(() => db.close());

  Future<PurchaseOrder> confirmedOrder() async {
    final o = await service.createDraft(supplierId: 's1', lines: [
      NewLine(productId: 'p1', productName: 'Widget', quantity: 6, unitPrice: 1),
    ]);
    await service.send(o);
    await service.confirm((await service.get(o.id))!);
    return (await service.get(o.id))!;
  }

  test('create draft receipt assigns RCP number and moves no stock; post raises stock',
      () async {
    final o = await confirmedOrder();
    final item = (await service.items(o.id)).single;
    await service.createReceipt(o, lines: [ReceiveLine(item: item, quantity: 4)]);
    final receipt = (await service.receipts(o.id)).single;
    expect(receipt.receiptNumber, 'RCP-0001');
    expect(receipt.status, ReceiptDocStatus.draft);
    var p = await (db.select(db.products)..where((x) => x.id.equals('p1'))).getSingle();
    expect(p.currentStock, 0); // draft moves nothing

    await service.postReceipt(o, receipt);
    p = await (db.select(db.products)..where((x) => x.id.equals('p1'))).getSingle();
    expect(p.currentStock, 4);
    expect((await service.get(o.id))!.receiptStatus, ReceiptStatus.partial);
  });

  test('receiving more than remaining is rejected at create', () async {
    final o = await confirmedOrder();
    final item = (await service.items(o.id)).single; // remaining 6
    await expectLater(
      service.createReceipt(o, lines: [ReceiveLine(item: item, quantity: 7)]),
      throwsA(isA<ValidationException>()),
    );
  });

  test('cannot receive on a draft order', () async {
    final o = await service.createDraft(supplierId: 's1', lines: [
      NewLine(productId: 'p1', productName: 'Widget', quantity: 1, unitPrice: 1),
    ]);
    final item = (await service.items(o.id)).single;
    await expectLater(
      service.createReceipt(o, lines: [ReceiveLine(item: item, quantity: 1)]),
      throwsA(isA<ValidationException>()),
    );
  });

  test('cancelling a draft receipt removes it from the active flow', () async {
    final o = await confirmedOrder();
    final item = (await service.items(o.id)).single;
    await service.createReceipt(o, lines: [ReceiveLine(item: item, quantity: 2)]);
    final receipt = (await service.receipts(o.id)).single;
    await service.cancelReceipt(receipt);
    final after = (await service.receipts(o.id)).single;
    expect(after.status, ReceiptDocStatus.cancelled);
  });
}
