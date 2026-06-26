import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/data/document_counter_dao.dart';
import 'package:inventoryhub_mobile/features/purchasing/purchase_order/data/purchase_order_dao.dart';
import 'package:inventoryhub_mobile/features/purchasing/purchase_order/data/purchase_order_payment_dao.dart';
import 'package:inventoryhub_mobile/features/purchasing/purchase_order/data/purchase_order_receipt_dao.dart';
import 'package:inventoryhub_mobile/features/purchasing/purchase_order/data/purchase_order_repository_impl.dart';
import 'package:inventoryhub_mobile/features/purchasing/purchase_order/domain/purchase_order_enums.dart';
import 'package:inventoryhub_mobile/features/purchasing/purchase_order/domain/purchase_order_usecases.dart';
import '../../../helpers/test_db.dart';

void main() {
  test('dashboard reports open orders, unreceived, and outstanding', () async {
    final db = newTestDb();
    final service = PurchaseOrderService(
      repository: PurchaseOrderRepositoryImpl(PurchaseOrderDao(db),
          PurchaseOrderReceiptDao(db), PurchaseOrderPaymentDao(db),
          DocumentCounterDao(db)),
      ids: const IdGenerator(),
      organizationId: 'org1',
      userId: 'u1',
    );
    final o = await service.createDraft(supplierId: 's1', lines: [
      const NewLine(
          productId: 'p1', productName: 'Widget', quantity: 1, unitPrice: 100),
    ]);
    await service.send(o);
    await service.confirm((await service.get(o.id))!);
    final confirmed = (await service.get(o.id))!;
    await service.addPayment(confirmed, amount: 40, method: PaymentMethod.cash);
    final p = (await service.payments(o.id)).single;
    await service.postPayment(confirmed, p);

    final kpis = await service.dashboard();
    expect(kpis.openOrders, 1); // confirmed counts as open
    expect(kpis.unreceived, 1);
    expect(kpis.outstanding, 60); // 100 total - 40 posted
    await db.close();
  });
}
