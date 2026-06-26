import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/data/document_counter_dao.dart';
import 'package:inventoryhub_mobile/features/purchasing/purchase_order/data/purchase_order_dao.dart';
import 'package:inventoryhub_mobile/features/purchasing/purchase_order/data/purchase_order_payment_dao.dart';
import 'package:inventoryhub_mobile/features/purchasing/purchase_order/data/purchase_order_receipt_dao.dart';
import 'package:inventoryhub_mobile/features/purchasing/purchase_order/data/purchase_order_repository_impl.dart';
import 'package:inventoryhub_mobile/features/purchasing/purchase_order/domain/purchase_order.dart';
import 'package:inventoryhub_mobile/features/purchasing/purchase_order/domain/purchase_order_enums.dart';
import '../../../helpers/test_db.dart';

void main() {
  test('createOrder then getOrder/itemsFor/listOrders round-trips', () async {
    final db = newTestDb();
    final repo = PurchaseOrderRepositoryImpl(PurchaseOrderDao(db),
        PurchaseOrderReceiptDao(db), PurchaseOrderPaymentDao(db),
        DocumentCounterDao(db));
    final now = DateTime.utc(2026, 6, 26);
    final order = PurchaseOrder(
      id: 'po1', organizationId: 'org1', orderNumber: 'PO-0001', supplierId: 's1',
      orderDate: now, status: PurchaseOrderStatus.draft,
      paymentStatus: PaymentStatus.notPaid,
      receiptStatus: ReceiptStatus.notReceived, totalAmount: 25,
      isActive: true, createdAt: now, updatedAt: now,
    );
    final item = PurchaseOrderItem(
      id: 'i1', organizationId: 'org1', purchaseOrderId: 'po1', productId: 'p1',
      productName: 'Widget', quantity: 1, unitPrice: 25, totalPrice: 25,
      receivedQuantity: 0, createdAt: now, updatedAt: now,
    );
    await repo.createOrder(order, [item]);

    expect((await repo.getOrder('po1'))!.status, PurchaseOrderStatus.draft);
    expect((await repo.itemsFor('po1')).single.productName, 'Widget');
    expect((await repo.listOrders('org1', limit: 20, offset: 0)).length, 1);
    expect(await repo.nextNumber('org1', 'purchase_order', 'PO'), 'PO-0001');
    await db.close();
  });
}
