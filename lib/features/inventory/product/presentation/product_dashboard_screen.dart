import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'product_providers.dart';
import 'widgets/product_swipeable_statistics_section.dart';
import 'product_list_screen.dart';
import 'package:inventoryhub_mobile/app/theme/app_tokens.dart';
import 'package:inventoryhub_mobile/core/widgets/app_card.dart';
import 'package:inventoryhub_mobile/core/l10n/l10n_ext.dart';

class ProductDashboardScreen extends ConsumerWidget {
  const ProductDashboardScreen({super.key});

  void _refresh(WidgetRef ref) {
    ref.invalidate(productDashboardProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final statsAsync = ref.watch(productDashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.productDashboardTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => _refresh(ref),
          ),
        ],
      ),
      body: statsAsync.when(
        data: (stats) => ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // Swipeable statistics
            const ProductSwipeableStatisticsSection(),
            const SizedBox(height: AppTokens.space24),

            // Alert banner card
            _buildStockAlertBanner(context, ref, stats),
            const SizedBox(height: AppTokens.space24),

            // Stock Status Distribution
            _buildStockStatusDistribution(context, ref, stats),
            const SizedBox(height: AppTokens.space24),

            // Quick Actions to manage inventory
            _buildQuickActions(context),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.productDashboardErrorLoading('$e'),
                  style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _refresh(ref),
                child: Text(l10n.productDashboardRetry),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStockAlertBanner(BuildContext context, WidgetRef ref, ProductDashboardData stats) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final hasOutOfStock = stats.outOfStockCount > 0;
    final hasLowStock = stats.lowStockCount > 0;

    Color cardColor;
    Color iconColor;
    IconData icon;
    String title;
    String subtitle;
    VoidCallback onTap;

    if (hasOutOfStock) {
      cardColor = Colors.red.withOpacity(0.08);
      iconColor = Colors.red.shade700;
      icon = Icons.error_rounded;
      title = l10n.productDashboardRestockRequiredTitle;
      subtitle =
          l10n.productDashboardRestockRequiredSubtitle(stats.outOfStockCount);
      onTap = () {
        ref.read(productCriteriaProvider.notifier).set(const ProductCriteria(outOfStock: true));
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => const ProductListScreen(initialOutOfStock: true),
        ));
      };
    } else if (hasLowStock) {
      cardColor = Colors.orange.withOpacity(0.08);
      iconColor = Colors.orange.shade700;
      icon = Icons.warning_rounded;
      title = l10n.productDashboardLowStockAlertTitle;
      subtitle = l10n.productDashboardLowStockAlertSubtitle(stats.lowStockCount);
      onTap = () {
        ref.read(productCriteriaProvider.notifier).set(const ProductCriteria(lowStock: true));
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => const ProductListScreen(initialLowStock: true),
        ));
      };
    } else {
      cardColor = Colors.green.withOpacity(0.08);
      iconColor = Colors.green.shade700;
      icon = Icons.check_circle_rounded;
      title = l10n.productDashboardHealthyTitle;
      subtitle = l10n.productDashboardHealthySubtitle;
      onTap = () {
        ref.read(productCriteriaProvider.notifier).set(const ProductCriteria());
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => const ProductListScreen(),
        ));
      };
    }

    return AppCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTokens.space16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: AppTokens.space16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppTokens.space4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: iconColor, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStockStatusDistribution(BuildContext context, WidgetRef ref, ProductDashboardData stats) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final total = stats.totalProducts;
    final lowStock = stats.lowStockCount;
    final outOfStock = stats.outOfStockCount;
    final wellStocked = total - lowStock - outOfStock;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.productDashboardBreakdownHeading,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppTokens.space8),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _buildDistributionRow(
                context,
                title: l10n.productDashboardWellStocked,
                count: wellStocked,
                total: total,
                color: Colors.green,
                onTap: () {
                  ref.read(productCriteriaProvider.notifier).set(const ProductCriteria());
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const ProductListScreen(),
                  ));
                },
              ),
              const Divider(height: 1),
              _buildDistributionRow(
                context,
                title: l10n.productDashboardLowStock,
                count: lowStock,
                total: total,
                color: Colors.orange,
                onTap: () {
                  ref.read(productCriteriaProvider.notifier).set(const ProductCriteria(lowStock: true));
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const ProductListScreen(initialLowStock: true),
                  ));
                },
              ),
              const Divider(height: 1),
              _buildDistributionRow(
                context,
                title: l10n.productDashboardOutOfStock,
                count: outOfStock,
                total: total,
                color: Colors.red,
                onTap: () {
                  ref.read(productCriteriaProvider.notifier).set(const ProductCriteria(outOfStock: true));
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const ProductListScreen(initialOutOfStock: true),
                  ));
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDistributionRow(
    BuildContext context, {
    required String title,
    required int count,
    required int total,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final pct = total > 0 ? (count / total * 100).toStringAsFixed(0) : '0';

    return ListTile(
      onTap: onTap,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count ($pct%)',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: AppTokens.space8),
          Icon(Icons.chevron_right_rounded, color: scheme.outline, size: 16),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.productDashboardQuickActionsHeading,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppTokens.space8),
        Row(
          children: [
            Expanded(
              child: AppCard(
                onTap: () {
                  refReadCriteria(context).set(const ProductCriteria());
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const ProductListScreen(),
                  ));
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.list_alt_rounded, color: scheme.primary, size: 24),
                    const SizedBox(height: AppTokens.space8),
                    Text(
                      l10n.productDashboardManageProducts,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  ProductCriteriaNotifier refReadCriteria(BuildContext context) {
    final container = ProviderScope.containerOf(context);
    return container.read(productCriteriaProvider.notifier);
  }
}
