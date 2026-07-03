import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventoryhub_mobile/app/currency/currency_controller.dart';
import 'package:intl/intl.dart';
import '../../../../../app/theme/app_tokens.dart';
import '../../../../../core/widgets/app_card.dart';
import '../../../sale_order/domain/sale_order.dart';
import '../../domain/customer_business_snapshot.dart';

/// Lifetime value + 6-month order-count trend for the customer detail
/// page. Fed by the customer's full order list (already fetched by
/// `customerOrdersProvider` for the Orders section) — no extra query.
class CustomerBusinessSnapshotCard extends ConsumerWidget {
  const CustomerBusinessSnapshotCard({super.key, required this.orders});
  final List<SaleOrder> orders;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final money = ref.watch(moneyFormatterProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final lifetimeValue = customerLifetimeValue(orders);
    final buckets = customerMonthlyOrderBuckets(orders);
    final maxCount =
        buckets.fold<int>(0, (a, b) => a > b.orderCount ? a : b.orderCount);
    final locale = Localizations.localeOf(context).toString();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.insights_rounded, color: scheme.primary, size: 20),
              const SizedBox(width: AppTokens.space8),
              Text(
                'Business snapshot',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.space16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lifetime value',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
              Text(
                money(lifetimeValue),
                style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold, color: scheme.primary),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.space16),
          Text(
            'Orders per month',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppTokens.space8),
          SizedBox(
            height: 120,
            child: maxCount <= 0
                ? Center(
                    child: Text(
                      'No orders yet',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  )
                : BarChart(
                    BarChartData(
                      maxY: maxCount * 1.2,
                      borderData: FlBorderData(show: false),
                      gridData: const FlGridData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 20,
                            getTitlesWidget: (value, meta) {
                              final i = value.toInt();
                              if (i < 0 || i >= buckets.length) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  DateFormat.MMM(locale)
                                      .format(buckets[i].month),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                      color: scheme.onSurfaceVariant),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (_) => scheme.inverseSurface,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                              BarTooltipItem(
                            '${rod.toY.toInt()}',
                            theme.textTheme.labelMedium!.copyWith(
                              color: scheme.onInverseSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      barGroups: [
                        for (var i = 0; i < buckets.length; i++)
                          BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: buckets[i].orderCount.toDouble(),
                                width: 18,
                                borderRadius: BorderRadius.circular(2),
                                color: i == buckets.length - 1
                                    ? scheme.primary
                                    : scheme.primary.withValues(alpha: 0.55),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
