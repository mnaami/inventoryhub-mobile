import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/data/document_counter_dao.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/data/sale_order_dao.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/data/sale_order_payment_dao.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/data/sale_order_repository_impl.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/data/sale_order_shipping_dao.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/domain/sale_order_enums.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/domain/sale_order_usecases.dart';
import '../../../helpers/test_db.dart';

void main() {
  test('dashboard reports open orders, unshipped, and outstanding', () async {
    final db = newTestDb();
    final service = SaleOrderService(
      repository: SaleOrderRepositoryImpl(SaleOrderDao(db),
          SaleOrderPaymentDao(db), SaleOrderShippingDao(db),
          DocumentCounterDao(db)),
      ids: const IdGenerator(),
      organizationId: 'org1',
      userId: 'u1',
    );
    final o = await service.createDraft(customerId: 'c1', lines: [
      const NewLine(
          productId: 'p1', productName: 'Widget', quantity: 1, unitPrice: 100),
    ]);
    await service.confirm(o);
    await service.addPayment(
        (await service.get(o.id))!, amount: 40, method: PaymentMethod.cash);

    final kpis = await service.dashboard();
    expect(kpis.openOrders, 1); // confirmed counts as open
    expect(kpis.unshipped, 1);
    expect(kpis.outstanding, 60); // 100 total - 40 paid
    await db.close();
  });
}
