import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventoryhub_mobile/app/currency/currency_controller.dart';
import '../../../../core/l10n/l10n_ext.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../domain/purchase_order.dart';
import '../domain/purchase_order_enums.dart';
import 'purchase_order_detail_screen.dart';
import 'purchase_order_edit_screen.dart';
import 'purchase_order_list_screen.dart';
import 'purchase_order_providers.dart';
import 'widgets/purchase_order_swipeable_statistics_section.dart';

class PurchaseOrderDashboardScreen extends ConsumerWidget {
  const PurchaseOrderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final allOrdersAsync = ref.watch(allPurchaseOrdersProvider);
    final kpisAsync = ref.watch(purchaseDashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.poDashboardTitle),
        actions: [
          IconButton(
            tooltip: l10n.poViewAllOrdersTooltip,
            icon: const Icon(Icons.list_alt_rounded),
            onPressed: () {
              ref.read(purchaseOrderCriteriaProvider.notifier).reset();
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const PurchaseOrderListScreen()));
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'purchasing_fab',
        onPressed: () => _createOrder(context, ref),
        child: const Icon(Icons.add, size: 28),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Period Stats Section
          const PurchaseOrderSwipeableStatisticsSection(),
          const SizedBox(height: AppTokens.space24),

          // Outstanding payables
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

          // Receipt Status distribution
          allOrdersAsync.when(
            data: (orders) => _buildReceiptStatusDistribution(context, ref, orders, l10n),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Text('Error loading receipt status distribution: $e'),
          ),
          const SizedBox(height: AppTokens.space16),
        ],
      ),
    );
  }

  Widget _buildOutstandingCard(BuildContext context, WidgetRef ref, double amount) {
    final money = ref.watch(moneyFormatterProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final hasOutstanding = amount > 0.01;

    return AppCard(
      padding: const EdgeInsets.all(AppTokens.space16),
      onTap: () {
        ref.read(purchaseOrderCriteriaProvider.notifier).reset();
        ref.read(purchaseOrderCriteriaProvider.notifier).setPaymentStatus(PaymentStatus.notPaid);
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const PurchaseOrderListScreen()));
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
                      ? context.l10n.poOutstandingPayables
                      : context.l10n.poAllPaymentsCleared,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppTokens.space4),
                Text(
                  money(amount),
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
      List<PurchaseOrder> orders, AppLocalizations l10n) {
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
          l10n.poPaymentStatusBreakdown,
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
                  ref.read(purchaseOrderCriteriaProvider.notifier).reset();
                  ref.read(purchaseOrderCriteriaProvider.notifier).setPaymentStatus(PaymentStatus.paid);
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const PurchaseOrderListScreen()));
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
                  ref.read(purchaseOrderCriteriaProvider.notifier).reset();
                  ref.read(purchaseOrderCriteriaProvider.notifier).setPaymentStatus(PaymentStatus.partial);
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const PurchaseOrderListScreen()));
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
                  ref.read(purchaseOrderCriteriaProvider.notifier).reset();
                  ref.read(purchaseOrderCriteriaProvider.notifier).setPaymentStatus(PaymentStatus.notPaid);
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const PurchaseOrderListScreen()));
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReceiptStatusDistribution(BuildContext context, WidgetRef ref,
      List<PurchaseOrder> orders, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    int notReceived = 0;
    int partial = 0;
    int fullyReceived = 0;
    for (final o in orders) {
      switch (o.receiptStatus) {
        case ReceiptStatus.notReceived:
          notReceived++;
          break;
        case ReceiptStatus.partial:
          partial++;
          break;
        case ReceiptStatus.fullyReceived:
          fullyReceived++;
          break;
      }
    }
    final total = orders.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.poReceiptStatusBreakdown,
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
                label: receiptStatusLabel(l10n, ReceiptStatus.fullyReceived),
                count: fullyReceived,
                total: total,
                color: Colors.green.shade600,
                onTap: () {
                  ref.read(purchaseOrderCriteriaProvider.notifier).reset();
                  ref.read(purchaseOrderCriteriaProvider.notifier).setReceiptStatus(ReceiptStatus.fullyReceived);
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const PurchaseOrderListScreen()));
                },
              ),
              const Divider(),
              _buildDistributionRow(
                context: context,
                label: receiptStatusLabel(l10n, ReceiptStatus.partial),
                count: partial,
                total: total,
                color: Colors.amber.shade700,
                onTap: () {
                  ref.read(purchaseOrderCriteriaProvider.notifier).reset();
                  ref.read(purchaseOrderCriteriaProvider.notifier).setReceiptStatus(ReceiptStatus.partial);
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const PurchaseOrderListScreen()));
                },
              ),
              const Divider(),
              _buildDistributionRow(
                context: context,
                label: receiptStatusLabel(l10n, ReceiptStatus.notReceived),
                count: notReceived,
                total: total,
                color: Colors.red.shade700,
                onTap: () {
                  ref.read(purchaseOrderCriteriaProvider.notifier).reset();
                  ref.read(purchaseOrderCriteriaProvider.notifier).setReceiptStatus(ReceiptStatus.notReceived);
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const PurchaseOrderListScreen()));
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
        MaterialPageRoute(builder: (_) => const PurchaseOrderEditScreen()));
    ref.invalidate(purchaseDashboardProvider);
    ref.invalidate(allPurchaseOrdersProvider);
    ref.invalidate(purchaseOrdersProvider);
    if (id != null && context.mounted) {
      await Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => PurchaseOrderDetailScreen(orderId: id)));
    }
  }
}
