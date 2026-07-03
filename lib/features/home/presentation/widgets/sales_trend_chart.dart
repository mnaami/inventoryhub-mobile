import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../app/currency/currency_controller.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../core/l10n/l10n_ext.dart';
import '../../../../core/widgets/swipeable_stats_section.dart';
import '../../../sales/sale_order/domain/sale_order_usecases.dart'
    show SalesTrendPoint;

/// Swipeable sales-trend card: Today (hourly) / last 7 days / last 30 days.
class SalesTrendChart extends ConsumerWidget {
  const SalesTrendChart({
    super.key,
    required this.trendToday,
    required this.trend7d,
    required this.trend30d,
  });

  final List<SalesTrendPoint> trendToday;
  final List<SalesTrendPoint> trend7d;
  final List<SalesTrendPoint> trend30d;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final titles = [
      l10n.homeSalesTrendToday,
      l10n.homeSalesTrend7d,
      l10n.homeSalesTrend30d,
    ];
    final series = [trendToday, trend7d, trend30d];
    return SwipeableStatsSection(
      pageCount: 3,
      leadingIcon: Icons.bar_chart_rounded,
      titleForPage: (page) => titles[page],
      pageHeight: 180,
      itemBuilder: (context, page) =>
          _TrendBarChart(points: series[page], page: page),
    );
  }
}

class _TrendBarChart extends ConsumerWidget {
  const _TrendBarChart({required this.points, required this.page});

  final List<SalesTrendPoint> points;
  final int page; // 0 = hourly today, 1 = 7 days, 2 = 30 days

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final money = ref.watch(moneyFormatterProvider);
    final maxTotal = points.fold<double>(
      0,
      (a, p) => a > p.total ? a : p.total,
    );

    if (maxTotal <= 0) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.show_chart_rounded,
              size: 32,
              color: scheme.outlineVariant,
            ),
            const SizedBox(height: AppTokens.space8),
            Text(
              context.l10n.homeSalesTrendEmpty,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    final locale = Localizations.localeOf(context).toString();
    final barWidth = switch (page) {
      0 => 7.0,
      1 => 18.0,
      _ => 5.0,
    };
    final highlighted = page == 0 ? DateTime.now().hour : points.length - 1;

    return Padding(
      padding: const EdgeInsets.only(top: AppTokens.space8),
      child: BarChart(
        BarChartData(
          maxY: maxTotal * 1.2,
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                getTitlesWidget: (value, meta) =>
                    _bottomLabel(context, locale, value.toInt()),
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => scheme.inverseSurface,
              getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                  BarTooltipItem(
                    money(rod.toY),
                    theme.textTheme.labelMedium!.copyWith(
                      color: scheme.onInverseSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < points.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: points[i].total,
                    width: barWidth,
                    borderRadius: BorderRadius.circular(2),
                    color: i == highlighted
                        ? scheme.primary
                        : scheme.primary.withOpacity(0.55),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _bottomLabel(BuildContext context, String locale, int index) {
    if (index < 0 || index >= points.length) return const SizedBox.shrink();
    final showEvery = switch (page) {
      0 => 6,
      1 => 1,
      _ => 5,
    };
    if (index % showEvery != 0) return const SizedBox.shrink();
    final bucket = points[index].bucketStart;
    final text = switch (page) {
      0 => DateFormat.j(locale).format(bucket),
      1 => DateFormat.E(locale).format(bucket),
      _ => DateFormat.Md(locale).format(bucket),
    };
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
