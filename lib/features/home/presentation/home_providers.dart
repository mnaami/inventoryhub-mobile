import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../inventory/product/presentation/product_providers.dart';
import '../../production/production_order/domain/production_order_usecases.dart'
    show ProductionKpis;
import '../../production/production_order/presentation/production_order_providers.dart';
import '../../purchasing/purchase_order/domain/purchase_order_usecases.dart'
    show PurchaseKpis;
import '../../purchasing/purchase_order/presentation/purchase_order_providers.dart';
import '../../sales/sale_order/domain/sale_order_usecases.dart'
    show SaleKpis, SalesTrendPoint;
import '../../sales/sale_order/presentation/sale_order_providers.dart';
import '../domain/home_dashboard_data.dart';

/// One-shot aggregate for the home business-pulse screen. Watches the four
/// domain services so a db/session swap rebuilds it; staleness from data
/// edits on other tabs is handled by the tab-switch invalidation in
/// MainScaffold plus pull-to-refresh.
final homeDashboardProvider = FutureProvider<HomeDashboardData>((ref) async {
  final sales = ref.watch(saleOrderServiceProvider);
  final purchases = ref.watch(purchaseOrderServiceProvider);
  final products = ref.watch(productServiceProvider);
  final production = ref.watch(productionOrderServiceProvider);

  // Local calendar boundaries, exclusive upper bounds — the convention every
  // existing KPI uses. Constructor arithmetic normalizes across month ends
  // and DST.
  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
  final tomorrowStart = DateTime(now.year, now.month, now.day + 1);
  final weekStart = // Monday of the current week
      DateTime(now.year, now.month, now.day - (now.weekday - 1));
  final monthStart = DateTime(now.year, now.month, 1);
  final nextMonthStart = DateTime(now.year, now.month + 1, 1);

  Future<PeriodSales> period(DateTime from, DateTime to) async =>
      PeriodSales(
        orderCount: await sales.countByDateRange(from, to),
        revenue: await sales.totalAmountByDateRange(from, to),
      );

  final results = await Future.wait<Object>([
    period(todayStart, tomorrowStart), // 0
    period(weekStart, tomorrowStart), // 1
    period(monthStart, nextMonthStart), // 2
    sales.dashboard(), // 3
    purchases.dashboard(), // 4
    production.dashboard(), // 5
    products.totalStockValue(), // 6
    products.lowStock(), // 7
    products.outOfStock(), // 8
    sales.hourlySalesTotals(now: now), // 9
    sales.dailySalesTotals(days: 7, now: now), // 10
    sales.dailySalesTotals(days: 30, now: now), // 11
  ]);

  final saleKpis = results[3] as SaleKpis;
  final purchaseKpis = results[4] as PurchaseKpis;
  final productionKpis = results[5] as ProductionKpis;

  return HomeDashboardData(
    today: results[0] as PeriodSales,
    thisWeek: results[1] as PeriodSales,
    thisMonth: results[2] as PeriodSales,
    receivables: saleKpis.outstanding,
    payables: purchaseKpis.outstanding,
    stockValue: results[6] as double,
    lowStockCount: (results[7] as List).length,
    outOfStockCount: (results[8] as List).length,
    openSaleOrders: saleKpis.openOrders,
    unshippedOrders: saleKpis.unshipped,
    openPurchaseOrders: purchaseKpis.openOrders,
    unreceivedOrders: purchaseKpis.unreceived,
    productionInProgress: productionKpis.inProgress,
    trendToday: results[9] as List<SalesTrendPoint>,
    trend7d: results[10] as List<SalesTrendPoint>,
    trend30d: results[11] as List<SalesTrendPoint>,
  );
});
