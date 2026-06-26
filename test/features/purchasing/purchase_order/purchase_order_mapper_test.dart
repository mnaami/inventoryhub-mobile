import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/db/app_database.dart';
import 'package:inventoryhub_mobile/features/purchasing/purchase_order/data/purchase_order_mappers.dart';
import 'package:inventoryhub_mobile/features/purchasing/purchase_order/domain/purchase_order_enums.dart';
import '../../../helpers/test_db.dart';

void main() {
  test('order round-trips through insert + read with enum decoding', () async {
    final db = newTestDb();
    final now = DateTime.utc(2026, 6, 26);
    await db.into(db.purchaseOrders).insert(PurchaseOrdersCompanion.insert(
          id: 'po1',
          organizationId: 'org1',
          orderNumber: 'PO-0001',
          supplierId: 's1',
          orderDate: now,
          createdAt: now,
          updatedAt: now,
        ));
    final order = toPurchaseOrder(await db.select(db.purchaseOrders).getSingle());
    expect(order.orderNumber, 'PO-0001');
    expect(order.status, PurchaseOrderStatus.draft);
    expect(order.paymentStatus, PaymentStatus.notPaid);
    expect(order.receiptStatus, ReceiptStatus.notReceived);
    await db.close();
  });

  test('enum wire values are stable', () {
    expect(PaymentMethod.creditCard.wire, 'credit_card');
    expect(ReceiptStatus.fullyReceived.wire, 'fully_received');
    expect(ReceiptDocStatus.posted.wire, 'posted');
    expect(PurchaseOrderStatus.fromWire('received'), PurchaseOrderStatus.received);
  });
}
