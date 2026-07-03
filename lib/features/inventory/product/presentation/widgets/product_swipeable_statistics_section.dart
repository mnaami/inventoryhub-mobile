import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventoryhub_mobile/app/currency/currency_controller.dart';
import '../product_providers.dart';
import 'package:inventoryhub_mobile/app/theme/app_tokens.dart';
import 'package:inventoryhub_mobile/core/l10n/l10n_ext.dart';
import 'package:inventoryhub_mobile/l10n/app_localizations.dart';

class ProductSwipeableStatisticsSection extends ConsumerStatefulWidget {
  const ProductSwipeableStatisticsSection({super.key});

  @override
  ConsumerState<ProductSwipeableStatisticsSection> createState() => _ProductSwipeableStatisticsSectionState();
}

class _ProductSwipeableStatisticsSectionState extends ConsumerState<ProductSwipeableStatisticsSection> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final statsAsync = ref.watch(productDashboardProvider);

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
                  Icon(Icons.inventory_2_outlined, color: scheme.primary, size: 20),
                  const SizedBox(width: AppTokens.space8),
                  Text(
                    _getCurrentPageTitle(l10n),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                    ),
                  ),
                ],
              ),
              _buildPageIndicator(scheme),
            ],
          ),
          const SizedBox(height: AppTokens.space16),
          statsAsync.when(
            data: (stats) => SizedBox(
              height: 96,
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildInventorySummaryPage(context, stats),
                  _buildStockAlertsPage(context, stats),
                ],
              ),
            ),
            loading: () => const SizedBox(
              height: 96,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, st) => SizedBox(
              height: 96,
              child: Center(
                child: Text(
                  l10n.productDashboardErrorLoading('$e'),
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getCurrentPageTitle(AppLocalizations l10n) {
    switch (_currentPage) {
      case 0:
        return l10n.productStatInventorySummary;
      case 1:
        return l10n.productStatStockAlerts;
      default:
        return l10n.productStatStatistics;
    }
  }

  Widget _buildPageIndicator(ColorScheme scheme) {
    return Row(
      children: List.generate(2, (index) {
        final isActive = index == _currentPage;
        return Container(
          width: isActive ? 12 : 6,
          height: 6,
          margin: const EdgeInsets.only(left: 4),
          decoration: BoxDecoration(
            color: isActive ? scheme.primary : scheme.outlineVariant,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }

  Widget _buildInventorySummaryPage(BuildContext context, ProductDashboardData stats) {
    final l10n = context.l10n;
    final money = ref.watch(moneyFormatterProvider);
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            context,
            label: l10n.productStatTotalValue,
            value: money(stats.totalValue),
            icon: Icons.attach_money_rounded,
            iconColor: Colors.purple,
          ),
        ),
        const VerticalDivider(width: 24, thickness: 1, indent: 8, endIndent: 8),
        Expanded(
          child: _buildStatItem(
            context,
            label: l10n.productStatActiveProducts,
            value: '${stats.activeProducts} / ${stats.totalProducts}',
            icon: Icons.check_circle_outline_rounded,
            iconColor: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStockAlertsPage(BuildContext context, ProductDashboardData stats) {
    final l10n = context.l10n;
    final lowStockColor = stats.lowStockCount > 0 ? Colors.orange : Colors.green;
    final outOfStockColor = stats.outOfStockCount > 0 ? Colors.red : Colors.green;

    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            context,
            label: l10n.productStatLowStockItems,
            value: '${stats.lowStockCount}',
            icon: Icons.warning_amber_rounded,
            iconColor: lowStockColor,
          ),
        ),
        const VerticalDivider(width: 24, thickness: 1, indent: 8, endIndent: 8),
        Expanded(
          child: _buildStatItem(
            context,
            label: l10n.productStatOutOfStock,
            value: '${stats.outOfStockCount}',
            icon: Icons.remove_shopping_cart_outlined,
            iconColor: outOfStockColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppTokens.space8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: AppTokens.space12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppTokens.space4),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
