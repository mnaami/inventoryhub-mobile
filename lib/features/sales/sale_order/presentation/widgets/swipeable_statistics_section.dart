import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventoryhub_mobile/core/format/money_format.dart';
import '../sale_order_providers.dart';
import 'package:inventoryhub_mobile/app/theme/app_tokens.dart';

class SwipeableStatisticsSection extends ConsumerStatefulWidget {
  const SwipeableStatisticsSection({super.key});

  @override
  ConsumerState<SwipeableStatisticsSection> createState() => _SwipeableStatisticsSectionState();
}

class _SwipeableStatisticsSectionState extends ConsumerState<SwipeableStatisticsSection> {
  late PageController _pageController;
  int _currentPage = 2; // Default to Monthly (index 2)

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 2);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppTokens.space16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.analytics_rounded, color: scheme.primary, size: 20),
                  const SizedBox(width: AppTokens.space8),
                  Text(
                    _getCurrentPeriodTitle(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                    ),
                  ),
                ],
              ),
              _buildPeriodIndicator(scheme),
            ],
          ),
          const SizedBox(height: AppTokens.space16),
          SizedBox(
            height: 96,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: 4,
              itemBuilder: (context, index) {
                final dateRange = _getDateRangeForPage(index);
                return _buildKeyStatisticsContent(context, dateRange.start, dateRange.end);
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getCurrentPeriodTitle() {
    switch (_currentPage) {
      case 0:
        return 'Daily Statistics';
      case 1:
        return 'Weekly Statistics';
      case 2:
        return 'Monthly Statistics';
      case 3:
        return 'Yearly Statistics';
      default:
        return 'Statistics';
    }
  }

  Widget _buildPeriodIndicator(ColorScheme scheme) {
    return Row(
      children: List.generate(4, (index) {
        final isActive = _currentPage == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: isActive ? 16 : 6,
          height: 6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: isActive ? scheme.primary : scheme.outlineVariant.withOpacity(0.6),
          ),
        );
      }),
    );
  }

  ({DateTime start, DateTime end}) _getDateRangeForPage(int pageIndex) {
    final now = DateTime.now();
    switch (pageIndex) {
      case 0: // Daily
        final startOfDay = DateTime(now.year, now.month, now.day);
        final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
        return (start: startOfDay, end: endOfDay);
      case 1: // Weekly
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day, 23, 59, 59)
            .add(const Duration(days: 6));
        return (start: startOfWeek, end: endOfWeek);
      case 2: // Monthly
        final startOfMonth = DateTime(now.year, now.month, 1);
        final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        return (start: startOfMonth, end: endOfMonth);
      case 3: // Yearly
        final startOfYear = DateTime(now.year, 1, 1);
        final endOfYear = DateTime(now.year, 12, 31, 23, 59, 59);
        return (start: startOfYear, end: endOfYear);
      default:
        return (start: now, end: now);
    }
  }

  Widget _buildKeyStatisticsContent(BuildContext context, DateTime startDate, DateTime endDate) {
    return Row(
      children: [
        Expanded(
          child: Consumer(
            builder: (context, ref, child) {
              final countAsync = ref.watch(saleOrderCountProvider((startDate: startDate, endDate: endDate)));
              return _buildCompactStatCard(
                context,
                'Total Orders',
                countAsync,
                Icons.shopping_bag_outlined,
                Theme.of(context).colorScheme.primary,
              );
            },
          ),
        ),
        const SizedBox(width: AppTokens.space12),
        Expanded(
          child: Consumer(
            builder: (context, ref, child) {
              final amountAsync = ref.watch(saleOrderAmountProvider((startDate: startDate, endDate: endDate)));
              return _buildCompactStatCard(
                context,
                'Total Sales',
                amountAsync,
                Icons.attach_money_rounded,
                Colors.green.shade600,
                isCurrency: true,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCompactStatCard(
    BuildContext context,
    String title,
    AsyncValue<dynamic> value,
    IconData icon,
    Color primaryColor, {
    bool isCurrency = false,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTokens.space12, vertical: AppTokens.space12),
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
              Icon(icon, size: 16, color: primaryColor),
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
          value.when(
            data: (data) {
              final displayValue = isCurrency
                  ? formatMoney(data as double)
                  : data.toString();
              return Text(
                displayValue,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                ),
              );
            },
            loading: () => SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            ),
            error: (error, stackTrace) => Text(
              '--',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: scheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
