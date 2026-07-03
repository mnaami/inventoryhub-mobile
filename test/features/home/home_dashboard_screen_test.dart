import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/app/currency/currency_controller.dart';
import 'package:inventoryhub_mobile/core/format/money_format.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/core/providers.dart';
import 'package:inventoryhub_mobile/core/seed/seed_service.dart';
import 'package:inventoryhub_mobile/features/home/presentation/home_dashboard_screen.dart';
import 'package:inventoryhub_mobile/features/home/presentation/widgets/sales_trend_chart.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/presentation/sale_order_list_screen.dart';
import '../../helpers/l10n.dart';
import '../../helpers/test_db.dart';

void main() {
  Future<void> pumpHome(WidgetTester tester) async {
    // Tall viewport so the whole (lazy) ListView builds.
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final db = newTestDb();
    addTearDown(db.close);
    final session = await SeedService(db, const IdGenerator()).ensureSeeded();
    final container = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
      sessionProvider.overrideWithValue(session),
      moneyFormatterProvider
          .overrideWithValue((v) => formatMoney(v, Currency.usd)),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: localizedApp(home: const HomeDashboardScreen()),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('shows all four KPI sections and the trend chart',
      (tester) async {
    await pumpHome(tester);
    expect(find.text('Dashboard'), findsOneWidget); // app bar
    expect(find.text("Today's Sales"), findsOneWidget); // stats, default page
    expect(find.byType(SalesTrendChart), findsOneWidget);
    expect(find.text('No sales in this period yet'), findsOneWidget);
    expect(find.text('Money In & Out'), findsOneWidget);
    expect(find.text('Customers Owe You'), findsOneWidget);
    expect(find.text('You Owe Suppliers'), findsOneWidget);
    expect(find.text('Stock Snapshot'), findsOneWidget);
    expect(find.text('Total Stock Value'), findsOneWidget);
    expect(find.text('Open Work'), findsOneWidget);
    expect(find.text('In Production'), findsOneWidget);
  });

  testWidgets('tapping receivables opens the sale order list',
      (tester) async {
    await pumpHome(tester);
    await tester.tap(find.text('Customers Owe You'));
    await tester.pumpAndSettle();
    expect(find.byType(SaleOrderListScreen), findsOneWidget);
  });
}
