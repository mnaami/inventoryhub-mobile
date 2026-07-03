import '../../sales/sale_order/domain/sale_order_usecases.dart'
    show SalesTrendPoint;

/// Sales revenue + order count for one calendar period.
class PeriodSales {
  const PeriodSales({required this.orderCount, required this.revenue});
  final int orderCount;
  final double revenue;
}

/// Everything the home business-pulse screen shows, loaded in one shot.
class HomeDashboardData {
  const HomeDashboardData({
    required this.today,
    required this.thisWeek,
    required this.thisMonth,
    required this.receivables,
    required this.payables,
    required this.stockValue,
    required this.lowStockCount,
    required this.outOfStockCount,
    required this.openSaleOrders,
    required this.unshippedOrders,
    required this.openPurchaseOrders,
    required this.unreceivedOrders,
    required this.productionInProgress,
    required this.trendToday,
    required this.trend7d,
    required this.trend30d,
  });

  // 1. Sales figures.
  final PeriodSales today;
  final PeriodSales thisWeek;
  final PeriodSales thisMonth;
  // 2. Money in / out.
  final double receivables;
  final double payables;
  // 3. Stock snapshot.
  final double stockValue;
  final int lowStockCount;
  final int outOfStockCount;
  // 4. Open work.
  final int openSaleOrders;
  final int unshippedOrders;
  final int openPurchaseOrders;
  final int unreceivedOrders;
  final int productionInProgress;
  // Trend chart series (dense, oldest first).
  final List<SalesTrendPoint> trendToday; // 24 hourly buckets
  final List<SalesTrendPoint> trend7d; // 7 daily buckets
  final List<SalesTrendPoint> trend30d; // 30 daily buckets
}
