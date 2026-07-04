// test/features/sales/customer/customer_business_snapshot_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/features/sales/customer/domain/customer_business_snapshot.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/domain/sale_order.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/domain/sale_order_enums.dart';

SaleOrder _order(
  String id, {
  required DateTime orderDate,
  double total = 100,
  OrderStatus status = OrderStatus.confirmed,
}) =>
    SaleOrder(
      id: id,
      organizationId: 'org1',
      soNumber: 'SO-$id',
      customerId: 'c1',
      orderDate: orderDate,
      status: status,
      paymentStatus: PaymentStatus.notPaid,
      shippingStatus: ShippingStatus.notShipped,
      totalAmount: total,
      isActive: true,
      createdAt: orderDate,
      updatedAt: orderDate,
    );

void main() {
  group('customerLifetimeValue', () {
    test('sums non-cancelled orders, includes drafts', () {
      final orders = [
        _order('1', orderDate: DateTime(2026, 1, 1), total: 100),
        _order('2',
            orderDate: DateTime(2026, 2, 1),
            total: 50,
            status: OrderStatus.draft),
        _order('3',
            orderDate: DateTime(2026, 3, 1),
            total: 999,
            status: OrderStatus.cancelled),
      ];
      expect(customerLifetimeValue(orders), 150);
    });

    test('empty order list is zero', () {
      expect(customerLifetimeValue(const []), 0);
    });
  });

  group('customerMonthlyOrderBuckets', () {
    test('6 dense buckets oldest-first, current month included even if empty',
        () {
      final now = DateTime(2026, 7, 3, 15);
      final orders = [
        _order('1', orderDate: DateTime(2026, 5, 10)),
        _order('2', orderDate: DateTime(2026, 5, 20)),
        _order('3', orderDate: DateTime(2026, 6, 1)),
      ];
      final buckets = customerMonthlyOrderBuckets(orders, now: now);

      expect(buckets.length, 6);
      expect(buckets.map((b) => (b.month.year, b.month.month)), [
        (2026, 2),
        (2026, 3),
        (2026, 4),
        (2026, 5),
        (2026, 6),
        (2026, 7),
      ]);
      expect(buckets.map((b) => b.orderCount), [0, 0, 0, 2, 1, 0]);
    });

    test('cancelled orders excluded, drafts included', () {
      final now = DateTime(2026, 7, 3);
      final orders = [
        _order('1',
            orderDate: DateTime(2026, 7, 1), status: OrderStatus.cancelled),
        _order('2',
            orderDate: DateTime(2026, 7, 2), status: OrderStatus.draft),
      ];
      final buckets = customerMonthlyOrderBuckets(orders, now: now);
      expect(buckets.last.orderCount, 1);
    });

    test('order outside the 6-month window is not counted', () {
      final now = DateTime(2026, 7, 3);
      final orders = [_order('1', orderDate: DateTime(2025, 12, 1))];
      final buckets = customerMonthlyOrderBuckets(orders, now: now);
      expect(buckets.fold<int>(0, (a, b) => a + b.orderCount), 0);
    });
  });
}
