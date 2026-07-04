import '../../sale_order/domain/sale_order.dart';

/// Order count for one local calendar month, used by the customer detail
/// page's business-snapshot trend chart.
class CustomerOrderMonthlyBucket {
  const CustomerOrderMonthlyBucket({
    required this.month,
    required this.orderCount,
  });

  /// First day of the local calendar month.
  final DateTime month;
  final int orderCount;
}

/// Sum of [SaleOrder.totalAmount] over non-cancelled orders (drafts
/// included) — same inclusion rule used by the app's other revenue KPIs.
double customerLifetimeValue(List<SaleOrder> orders) => orders
    .where((o) => !o.isCancelled)
    .fold<double>(0, (sum, o) => sum + o.totalAmount);

/// Dense per-month order counts for the [months] local calendar months
/// ending on the month of [now] (defaults to the current instant),
/// oldest first. Cancelled orders excluded, drafts included. Buckets are
/// keyed by LOCAL month; `DateTime(y, m - i)` constructor arithmetic
/// normalizes across year boundaries (mirrors the day/hour bucketing in
/// `SaleOrderService.dailySalesTotals`/`hourlySalesTotals`).
List<CustomerOrderMonthlyBucket> customerMonthlyOrderBuckets(
  List<SaleOrder> orders, {
  DateTime? now,
  int months = 6,
}) {
  final n = now ?? DateTime.now();
  final keys = [
    for (var i = months - 1; i >= 0; i--) DateTime(n.year, n.month - i),
  ];
  final counts = {for (final k in keys) k: 0};
  for (final o in orders) {
    if (o.isCancelled) continue;
    final d = o.orderDate.toLocal();
    final key = DateTime(d.year, d.month);
    if (counts.containsKey(key)) counts[key] = counts[key]! + 1;
  }
  return [
    for (final k in keys)
      CustomerOrderMonthlyBucket(month: k, orderCount: counts[k]!),
  ];
}
