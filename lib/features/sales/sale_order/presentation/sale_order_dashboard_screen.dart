import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/format/money_format.dart';
import '../../../../core/l10n/l10n_ext.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../domain/sale_order.dart';
import '../domain/sale_order_enums.dart';
import 'sale_order_detail_screen.dart';
import 'sale_order_edit_screen.dart';
import 'sale_order_list_screen.dart';
import 'sale_order_providers.dart';
import 'widgets/swipeable_statistics_section.dart';

class SaleOrderDashboardScreen extends ConsumerWidget {
  const SaleOrderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final allOrdersAsync = ref.watch(allSaleOrdersProvider);
    final kpisAsync = ref.watch(saleDashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.soDashboardTitle),
        actions: [
          IconButton(
            tooltip: l10n.soViewAllOrdersTooltip,
            icon: const Icon(Icons.list_alt_rounded),
            onPressed: () {
              ref.read(saleOrderCriteriaProvider.notifier).reset();
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const SaleOrderListScreen()));
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'sales_fab',
        onPressed: () => _createOrder(context, ref),
        child: const Icon(Icons.add, size: 28),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Period Stats Section
          const SwipeableStatisticsSection(),
          const SizedBox(height: AppTokens.space24),

          // Outstanding receivables
          kpisAsync.when(
            data: (k) => _buildOutstandingCard(context, ref, k.outstanding),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const SizedBox(),
          ),
          const SizedBox(height: AppTokens.space24),

          // Payment Status distribution
          allOrdersAsync.when(
            data: (orders) => _buildPaymentStatusDistribution(context, ref, orders, l10n),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Text('Error loading payment status distribution: $e'),
          ),
          const SizedBox(height: AppTokens.space24),

          // Shipping Status distribution
          allOrdersAsync.when(
            data: (orders) => _buildShippingStatusDistribution(context, ref, orders, l10n),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Text('Error loading shipping status distribution: $e'),
          ),
          const SizedBox(height: AppTokens.space16),
        ],
      ),
    );
  }

  Widget _buildOutstandingCard(BuildContext context, WidgetRef ref, double amount) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final hasOutstanding = amount > 0.01;

    return AppCard(
      padding: const EdgeInsets.all(AppTokens.space16),
      onTap: () {
        ref.read(saleOrderCriteriaProvider.notifier).reset();
        ref.read(saleOrderCriteriaProvider.notifier).setPaymentStatus(PaymentStatus.notPaid);
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const SaleOrderListScreen()));
      },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTokens.space12),
            decoration: BoxDecoration(
              color: hasOutstanding ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasOutstanding ? Icons.warning_rounded : Icons.check_circle_rounded,
              color: hasOutstanding ? Colors.orange.shade700 : Colors.green.shade700,
              size: 24,
            ),
          ),
          const SizedBox(width: AppTokens.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasOutstanding
                      ? context.l10n.soOutstandingReceivables
                      : context.l10n.soAllPaymentsCleared,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppTokens.space4),
                Text(
                  formatMoney(amount),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: hasOutstanding ? Colors.orange.shade700 : Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant.withOpacity(0.5)),
        ],
      ),
    );
  }

  Widget _buildPaymentStatusDistribution(BuildContext context, WidgetRef ref,
      List<SaleOrder> orders, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    int notPaid = 0;
    int partial = 0;
    int paid = 0;
    for (final o in orders) {
      switch (o.paymentStatus) {
        case PaymentStatus.notPaid:
          notPaid++;
          break;
        case PaymentStatus.partial:
          partial++;
          break;
        case PaymentStatus.paid:
          paid++;
          break;
      }
    }
    final total = orders.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.soPaymentStatusBreakdown,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppTokens.space12),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _buildDistributionRow(
                context: context,
                label: paymentStatusLabel(l10n, PaymentStatus.paid),
                count: paid,
                total: total,
                color: Colors.green.shade600,
                onTap: () {
                  ref.read(saleOrderCriteriaProvider.notifier).reset();
                  ref.read(saleOrderCriteriaProvider.notifier).setPaymentStatus(PaymentStatus.paid);
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const SaleOrderListScreen()));
                },
              ),
              const Divider(),
              _buildDistributionRow(
                context: context,
                label: paymentStatusLabel(l10n, PaymentStatus.partial),
                count: partial,
                total: total,
                color: Colors.amber.shade700,
                onTap: () {
                  ref.read(saleOrderCriteriaProvider.notifier).reset();
                  ref.read(saleOrderCriteriaProvider.notifier).setPaymentStatus(PaymentStatus.partial);
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const SaleOrderListScreen()));
                },
              ),
              const Divider(),
              _buildDistributionRow(
                context: context,
                label: paymentStatusLabel(l10n, PaymentStatus.notPaid),
                count: notPaid,
                total: total,
                color: Colors.red.shade700,
                onTap: () {
                  ref.read(saleOrderCriteriaProvider.notifier).reset();
                  ref.read(saleOrderCriteriaProvider.notifier).setPaymentStatus(PaymentStatus.notPaid);
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const SaleOrderListScreen()));
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShippingStatusDistribution(BuildContext context, WidgetRef ref,
      List<SaleOrder> orders, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    int notShipped = 0;
    int partiallyShipped = 0;
    int fullyShipped = 0;
    for (final o in orders) {
      switch (o.shippingStatus) {
        case ShippingStatus.notShipped:
          notShipped++;
          break;
        case ShippingStatus.partiallyShipped:
          partiallyShipped++;
          break;
        case ShippingStatus.fullyShipped:
          fullyShipped++;
          break;
      }
    }
    final total = orders.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.soShippingStatusBreakdown,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppTokens.space12),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _buildDistributionRow(
                context: context,
                label: shippingStatusLabel(l10n, ShippingStatus.fullyShipped),
                count: fullyShipped,
                total: total,
                color: Colors.green.shade600,
                onTap: () {
                  ref.read(saleOrderCriteriaProvider.notifier).reset();
                  ref.read(saleOrderCriteriaProvider.notifier).setShippingStatus(ShippingStatus.fullyShipped);
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const SaleOrderListScreen()));
                },
              ),
              const Divider(),
              _buildDistributionRow(
                context: context,
                label: shippingStatusLabel(l10n, ShippingStatus.partiallyShipped),
                count: partiallyShipped,
                total: total,
                color: Colors.amber.shade700,
                onTap: () {
                  ref.read(saleOrderCriteriaProvider.notifier).reset();
                  ref.read(saleOrderCriteriaProvider.notifier).setShippingStatus(ShippingStatus.partiallyShipped);
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const SaleOrderListScreen()));
                },
              ),
              const Divider(),
              _buildDistributionRow(
                context: context,
                label: shippingStatusLabel(l10n, ShippingStatus.notShipped),
                count: notShipped,
                total: total,
                color: Colors.red.shade700,
                onTap: () {
                  ref.read(saleOrderCriteriaProvider.notifier).reset();
                  ref.read(saleOrderCriteriaProvider.notifier).setShippingStatus(ShippingStatus.notShipped);
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const SaleOrderListScreen()));
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDistributionRow({
    required BuildContext context,
    required String label,
    required int count,
    required int total,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final pct = total > 0 ? (count / total * 100).toStringAsFixed(0) : '0';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTokens.radiusLg),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppTokens.space16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: AppTokens.space12),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
            ),
            Text(
              '$count ($pct%)',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant.withOpacity(0.4), size: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _createOrder(BuildContext context, WidgetRef ref) async {
    final id = await Navigator.of(context).push<String>(
        MaterialPageRoute(builder: (_) => const SaleOrderEditScreen()));
    ref.invalidate(saleDashboardProvider);
    ref.invalidate(allSaleOrdersProvider);
    ref.invalidate(saleOrdersProvider);
    if (id != null && context.mounted) {
      await Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => SaleOrderDetailScreen(orderId: id)));
    }
  }
}
