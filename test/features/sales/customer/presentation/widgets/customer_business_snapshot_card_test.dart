// test/features/sales/customer/presentation/widgets/customer_business_snapshot_card_test.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventoryhub_mobile/app/currency/currency_controller.dart';
import 'package:inventoryhub_mobile/core/format/money_format.dart';
import 'package:inventoryhub_mobile/features/sales/customer/presentation/widgets/customer_business_snapshot_card.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/domain/sale_order.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/domain/sale_order_enums.dart';

SaleOrder _order(String id, {required DateTime orderDate, double total = 100}) =>
    SaleOrder(
      id: id,
      organizationId: 'org1',
      soNumber: 'SO-$id',
      customerId: 'c1',
      orderDate: orderDate,
      status: OrderStatus.confirmed,
      paymentStatus: PaymentStatus.notPaid,
      shippingStatus: ShippingStatus.notShipped,
      totalAmount: total,
      isActive: true,
      createdAt: orderDate,
      updatedAt: orderDate,
    );

Future<void> _pump(WidgetTester tester, List<SaleOrder> orders) async {
  final container = ProviderContainer(overrides: [
    moneyFormatterProvider
        .overrideWithValue((v) => formatMoney(v, Currency.usd)),
  ]);
  addTearDown(container.dispose);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      home: Scaffold(
        body: CustomerBusinessSnapshotCard(orders: orders),
      ),
    ),
  ));
}

void main() {
  testWidgets('shows lifetime value and the trend chart when orders exist',
      (tester) async {
    await _pump(tester, [
      _order('1', orderDate: DateTime.now(), total: 100),
      _order('2', orderDate: DateTime.now(), total: 50),
    ]);
    expect(find.textContaining('150'), findsOneWidget);
    expect(find.byType(BarChart), findsOneWidget);
  });

  testWidgets('shows empty state and zero lifetime value with no orders',
      (tester) async {
    await _pump(tester, []);
    expect(find.textContaining('\$0'), findsOneWidget);
    expect(find.text('No orders yet'), findsOneWidget);
    expect(find.byType(BarChart), findsNothing);
  });
}
