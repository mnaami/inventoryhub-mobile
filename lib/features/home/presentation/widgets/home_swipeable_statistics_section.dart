import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/currency/currency_controller.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../core/l10n/l10n_ext.dart';
import '../../../../core/widgets/swipeable_stats_section.dart';
import '../../../sales/sale_order/presentation/sale_order_list_screen.dart';
import '../../../sales/sale_order/presentation/sale_order_providers.dart';
import '../../domain/home_dashboard_data.dart';

/// Swipeable Today / This week / This month sales stats. Tapping a page opens
/// the sale-order list pre-filtered to the same date window.
class HomeSwipeableStatisticsSection extends ConsumerWidget {
  const HomeSwipeableStatisticsSection({super.key, required this.data});

  final HomeDashboardData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final titles = [
      l10n.homeSalesToday,
      l10n.homeSalesThisWeek,
      l10n.homeSalesThisMonth,
    ];
    final periods = [data.today, data.thisWeek, data.thisMonth];
    final presets = [DatePreset.today, DatePreset.week, DatePreset.month];
    return SwipeableStatsSection(
      pageCount: 3,
      titleForPage: (page) => titles[page],
      itemBuilder: (context, page) => _StatsPage(
        period: periods[page],
        onTap: () {
          final criteria = ref.read(saleOrderCriteriaProvider.notifier);
          criteria.reset();
          criteria.setDatePreset(presets[page]);
          Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const SaleOrderListScreen()));
        },
      ),
    );
  }
}

class _StatsPage extends ConsumerWidget {
  const _StatsPage({required this.period, required this.onTap});

  final PeriodSales period;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final money = ref.watch(moneyFormatterProvider);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Expanded(
            child: _CompactStatCard(
              title: l10n.homeStatOrders,
              value: '${period.orderCount}',
              icon: Icons.shopping_bag_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: AppTokens.space12),
          Expanded(
            child: _CompactStatCard(
              title: l10n.homeStatRevenue,
              value: money(period.revenue),
              icon: Icons.attach_money_rounded,
              color: Colors.green.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactStatCard extends StatelessWidget {
  const _CompactStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.space12, vertical: AppTokens.space12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.space8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
