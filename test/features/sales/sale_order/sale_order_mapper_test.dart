import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/db/app_database.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/domain/sale_order.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/domain/sale_order_enums.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/data/sale_order_mappers.dart';
import '../../../helpers/test_db.dart';

void main() {
  test('order round-trips through insert + read with enum decoding', () async {
    final db = newTestDb();
    final now = DateTime.utc(2026, 6, 26);
    await db.into(db.saleOrders).insert(SaleOrdersCompanion.insert(
          id: 'so1',
          organizationId: 'org1',
          soNumber: 'SO-0001',
          customerId: 'c1',
          orderDate: now,
          createdAt: now,
          updatedAt: now,
        ));
    final row = await db.select(db.saleOrders).getSingle();
    final order = toSaleOrder(row);
    expect(order.soNumber, 'SO-0001');
    expect(order.status, OrderStatus.draft);
    expect(order.paymentStatus, PaymentStatus.notPaid);
    expect(order.shippingStatus, ShippingStatus.notShipped);
    await db.close();
  });

  test('enum wire values are stable', () {
    expect(PaymentMethod.creditCard.wire, 'credit_card');
    expect(ShipmentStatus.inTransit.wire, 'in_transit');
    expect(OrderStatus.fromWire('delivered'), OrderStatus.delivered);
  });

  test('toSalePaymentListItem carries payment fields plus order context', () {
    final row = SaleOrderPaymentRow(
      id: 'p1',
      organizationId: 'org1',
      saleOrderId: 'so1',
      paymentNumber: 'PAY-0001',
      amount: 42.5,
      method: 'bank_transfer',
      status: 'completed',
      paymentDate: DateTime.utc(2026, 6, 2),
      isActive: true,
      isSample: false,
      createdAt: DateTime.utc(2026, 6, 2),
      updatedAt: DateTime.utc(2026, 6, 2),
    );

    final item =
        toSalePaymentListItem(row, soNumber: 'SO-0001', customerId: 'c1');

    expect(item.id, 'p1');
    expect(item.amount, 42.5);
    expect(item.method, PaymentMethod.bankTransfer);
    expect(item.status, PaymentRecordStatus.completed);
    expect(item.soNumber, 'SO-0001');
    expect(item.customerId, 'c1');
  });
}
