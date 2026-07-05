import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/db/app_database.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/data/document_counter_dao.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/data/sale_order_dao.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/data/sale_order_payment_dao.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/data/sale_order_repository_impl.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/data/sale_order_shipping_dao.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/domain/sale_order.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/domain/sale_order_enums.dart';
import '../../../helpers/test_db.dart';

void main() {
  test('createOrder then getOrder/itemsFor/listOrders round-trips', () async {
    final db = newTestDb();
    final repo = SaleOrderRepositoryImpl(SaleOrderDao(db),
        SaleOrderPaymentDao(db), SaleOrderShippingDao(db),
        DocumentCounterDao(db));
    final now = DateTime.utc(2026, 6, 26);
    final order = SaleOrder(
      id: 'so1', organizationId: 'org1', soNumber: 'SO-0001', customerId: 'c1',
      orderDate: now, status: OrderStatus.draft,
      paymentStatus: PaymentStatus.notPaid,
      shippingStatus: ShippingStatus.notShipped, totalAmount: 25,
      isActive: true, createdAt: now, updatedAt: now,
    );
    final item = SaleOrderItem(
      id: 'i1', organizationId: 'org1', saleOrderId: 'so1', productId: 'p1',
      productName: 'Widget', quantity: 1, unitPrice: 25, totalPrice: 25,
      shippedQuantity: 0, createdAt: now, updatedAt: now,
    );
    await repo.createOrder(order, [item]);

    expect((await repo.getOrder('so1'))!.status, OrderStatus.draft);
    expect((await repo.itemsFor('so1')).single.productName, 'Widget');
    expect((await repo.listOrders('org1', limit: 20, offset: 0)).length, 1);
    expect(await repo.nextNumber('org1', 'sale_order', 'SO'), 'SO-0001');
    await db.close();
  });

  test('pagedPayments maps DAO rows to SalePaymentListItem with order context',
      () async {
    final db = newTestDb();
    addTearDown(db.close);
    final repo = SaleOrderRepositoryImpl(
      SaleOrderDao(db),
      SaleOrderPaymentDao(db),
      SaleOrderShippingDao(db),
      DocumentCounterDao(db),
    );
    final now = DateTime.utc(2026, 6, 2);
    await db.into(db.saleOrders).insert(SaleOrdersCompanion.insert(
          id: 'so1', organizationId: 'org1', soNumber: 'SO-0001',
          customerId: 'c1', orderDate: now, totalAmount: const Value(100),
          createdAt: now, updatedAt: now,
        ));
    await db.saleOrderPaymentDao.recordPayment(SaleOrderPaymentsCompanion.insert(
      id: 'p1', organizationId: 'org1', saleOrderId: 'so1',
      paymentNumber: 'PAY-0001', amount: 42, method: 'cash',
      status: const Value('completed'), paymentDate: now,
      createdAt: now, updatedAt: now,
    ));

    final items = await repo.pagedPayments('org1', limit: 20, offset: 0);

    expect(items.length, 1);
    expect(items.single, isA<SalePaymentListItem>());
    expect(items.single.soNumber, 'SO-0001');
    expect(items.single.customerId, 'c1');
    expect(items.single.method, PaymentMethod.cash);
  });
}
