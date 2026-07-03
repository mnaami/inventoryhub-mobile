import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/app/currency/currency_controller.dart';
import 'package:inventoryhub_mobile/core/format/money_format.dart';
import 'package:inventoryhub_mobile/features/home/presentation/widgets/sales_trend_chart.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/domain/sale_order_usecases.dart';
import '../../helpers/l10n.dart';

void main() {
  final emptyDay = [
    for (var h = 0; h < 24; h++)
      SalesTrendPoint(bucketStart: DateTime(2026, 7, 3, h), total: 0),
  ];
  final week = [
    for (var i = 0; i < 7; i++)
      SalesTrendPoint(
        bucketStart: DateTime(2026, 6, 27 + i),
        total: i == 6 ? 100 : 0,
      ),
  ];
  final month = [
    for (var i = 0; i < 30; i++)
      SalesTrendPoint(bucketStart: DateTime(2026, 6, 4 + i), total: 0),
  ];

  Future<void> pumpChart(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          moneyFormatterProvider.overrideWithValue(
            (v) => formatMoney(v, Currency.usd),
          ),
        ],
        child: localizedApp(
          home: Scaffold(
            body: SalesTrendChart(
              trendToday: emptyDay,
              trend7d: week,
              trend30d: month,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the empty state on an all-zero page', (tester) async {
    await pumpChart(tester);
    // Default page is Today, which is all zeros.
    expect(find.text('Sales Trend — Today'), findsOneWidget);
    expect(find.text('No sales in this period yet'), findsOneWidget);
    expect(find.byType(BarChart), findsNothing);
  });

  testWidgets('swiping to the 7-day page renders a bar chart', (tester) async {
    await pumpChart(tester);
    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();
    expect(find.text('Sales Trend — 7 Days'), findsOneWidget);
    expect(find.byType(BarChart), findsOneWidget);
  });
}
