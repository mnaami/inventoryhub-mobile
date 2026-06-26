import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/result/app_exception.dart';
import 'package:inventoryhub_mobile/core/db/app_database.dart';
import '../../../helpers/test_db.dart';

void main() {
  late AppDatabase db;
  final now = DateTime.utc(2026, 6, 26);

  setUp(() async {
    db = newTestDb();
    await db.into(db.products).insert(ProductsCompanion.insert(
          id: 'p1', organizationId: 'org1', name: 'Widget', unitId: 'pc',
          currentStock: const Value(0), createdAt: now, updatedAt: now,
        ));
    await db.into(db.purchaseOrders).insert(PurchaseOrdersCompanion.insert(
          id: 'po1', organizationId: 'org1', orderNumber: 'PO-0001',
          supplierId: 's1', orderDate: now, status: const Value('confirmed'),
          createdAt: now, updatedAt: now,
        ));
    await db.into(db.purchaseOrderItems).insert(PurchaseOrderItemsCompanion.insert(
          id: 'i1', organizationId: 'org1', purchaseOrderId: 'po1', productId: 'p1',
          productName: 'Widget', quantity: 10, unitPrice: 1, totalPrice: 10,
          createdAt: now, updatedAt: now,
        ));
  });
  tearDown(() => db.close());

  PurchaseOrderReceiptsCompanion receipt(String id) =>
      PurchaseOrderReceiptsCompanion.insert(
        id: id, organizationId: 'org1', purchaseOrderId: 'po1',
        receiptNumber: 'RCP-000$id', receiptDate: now,
        createdAt: now, updatedAt: now,
      );

  PurchaseOrderReceiptItemsCompanion rItem(String id, String receiptId, double qty) =>
      PurchaseOrderReceiptItemsCompanion.insert(
        id: id, organizationId: 'org1', receiptId: receiptId,
        purchaseOrderItemId: 'i1', productId: 'p1', quantity: qty, createdAt: now,
      );

  test('creating a draft receipt does not move stock', () async {
    await db.purchaseOrderReceiptDao.createReceipt(
        receipt: receipt('1'), items: [rItem('ri1', '1', 4)]);
    final p = await (db.select(db.products)..where((x) => x.id.equals('p1'))).getSingle();
    expect(p.currentStock, 0);
    expect(await db.select(db.stockMovements).get(), isEmpty);
    final rcp = await (db.select(db.purchaseOrderReceipts)..where((x) => x.id.equals('1'))).getSingle();
    expect(rcp.status, 'draft');
  });

  test('posting raises stock via ledger, bumps received_qty, partial status', () async {
    await db.purchaseOrderReceiptDao.createReceipt(
        receipt: receipt('1'), items: [rItem('ri1', '1', 4)]);
    await db.purchaseOrderReceiptDao.post(
      receiptId: '1', movementIdByReceiptItem: {'ri1': 'm1'},
      createdBy: 'u1', now: now,
    );
    final p = await (db.select(db.products)..where((x) => x.id.equals('p1'))).getSingle();
    expect(p.currentStock, 4);
    final mv = await db.select(db.stockMovements).getSingle();
    expect(mv.quantity, 4);
    expect(mv.referenceType, 'purchase_order_receipt');
    expect(mv.referenceId, '1');
    final item = await (db.select(db.purchaseOrderItems)..where((x) => x.id.equals('i1'))).getSingle();
    expect(item.receivedQuantity, 4);
    final order = await (db.select(db.purchaseOrders)..where((x) => x.id.equals('po1'))).getSingle();
    expect(order.receiptStatus, 'partial');
    expect(order.status, 'confirmed');
    final rcp = await (db.select(db.purchaseOrderReceipts)..where((x) => x.id.equals('1'))).getSingle();
    expect(rcp.status, 'posted');
  });

  test('fully receiving advances receipt_status and order to received', () async {
    await db.purchaseOrderReceiptDao.createReceipt(
        receipt: receipt('1'), items: [rItem('ri1', '1', 10)]);
    await db.purchaseOrderReceiptDao.post(
      receiptId: '1', movementIdByReceiptItem: {'ri1': 'm1'}, createdBy: 'u1', now: now);
    final order = await (db.select(db.purchaseOrders)..where((x) => x.id.equals('po1'))).getSingle();
    expect(order.receiptStatus, 'fully_received');
    expect(order.status, 'received');
  });

  test('over-receipt rolls back the entire post', () async {
    await db.purchaseOrderReceiptDao.createReceipt(
        receipt: receipt('1'), items: [rItem('ri1', '1', 11)]); // > 10 ordered
    await expectLater(
      db.purchaseOrderReceiptDao.post(
          receiptId: '1', movementIdByReceiptItem: {'ri1': 'm1'},
          createdBy: 'u1', now: now),
      throwsA(isA<ConflictException>()),
    );
    final p = await (db.select(db.products)..where((x) => x.id.equals('p1'))).getSingle();
    expect(p.currentStock, 0);
    expect(await db.select(db.stockMovements).get(), isEmpty);
    final item = await (db.select(db.purchaseOrderItems)..where((x) => x.id.equals('i1'))).getSingle();
    expect(item.receivedQuantity, 0);
    final rcp = await (db.select(db.purchaseOrderReceipts)..where((x) => x.id.equals('1'))).getSingle();
    expect(rcp.status, 'draft'); // unchanged
  });

  test('over-receipt is detected across duplicate lines for the same PO item', () async {
    await db.purchaseOrderReceiptDao.createReceipt(
        receipt: receipt('1'),
        items: [rItem('ri1', '1', 6), rItem('ri2', '1', 6)]); // 12 > 10
    await expectLater(
      db.purchaseOrderReceiptDao.post(
          receiptId: '1',
          movementIdByReceiptItem: {'ri1': 'm1', 'ri2': 'm2'},
          createdBy: 'u1', now: now),
      throwsA(isA<ConflictException>()),
    );
    final p = await (db.select(db.products)..where((x) => x.id.equals('p1'))).getSingle();
    expect(p.currentStock, 0);
  });
}
