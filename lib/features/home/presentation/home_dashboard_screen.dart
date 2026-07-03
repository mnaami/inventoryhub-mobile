import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/currency/currency_controller.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../core/l10n/l10n_ext.dart';
import '../../../core/widgets/app_card.dart';
import '../../inventory/product/presentation/product_list_screen.dart';
import '../../inventory/product/presentation/product_providers.dart';
import '../../production/presentation/production_home_screen.dart';
import '../../purchasing/purchase_order/domain/purchase_order_enums.dart'
    as po_enums;
import '../../purchasing/purchase_order/presentation/purchase_order_list_screen.dart';
import '../../purchasing/purchase_order/presentation/purchase_order_providers.dart'
    as po;
import '../../sales/sale_order/domain/sale_order_enums.dart';
import '../../sales/sale_order/presentation/sale_order_list_screen.dart';
import '../../sales/sale_order/presentation/sale_order_providers.dart'
    hide DatePreset;
import '../domain/home_dashboard_data.dart';
import 'home_providers.dart';
import 'widgets/home_swipeable_statistics_section.dart';
import 'widgets/sales_trend_chart.dart';

/// Cross-domain business-pulse screen: the first bottom-nav tab. No FAB.
class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final statsAsync = ref.watch(homeDashboardProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.homeDashboardTitle)),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(homeDashboardProvider);
          await ref.read(homeDashboardProvider.future);
        },
        child: statsAsync.when(
          data: (data) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              HomeSwipeableStatisticsSection(data: data),
              const SizedBox(height: AppTokens.space24),
              SalesTrendChart(
                trendToday: data.trendToday,
                trend7d: data.trend7d,
                trend30d: data.trend30d,
              ),
              const SizedBox(height: AppTokens.space24),
              _buildMoneySection(context, ref, data),
              const SizedBox(height: AppTokens.space24),
              _buildStockSection(context, ref, data),
              const SizedBox(height: AppTokens.space24),
              _buildOpenWorkSection(context, ref, data),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(l10n.homeErrorLoading('$e'),
                          style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(homeDashboardProvider),
                        child: Text(l10n.homeRetry),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _heading(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildMoneySection(
      BuildContext context, WidgetRef ref, HomeDashboardData data) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading(context, l10n.homeMoneyHeading),
        const SizedBox(height: AppTokens.space8),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _moneyRow(
                context,
                ref,
                label: l10n.homeReceivables,
                amount: data.receivables,
                icon: Icons.call_received_rounded,
                onTap: () {
                  final c = ref.read(saleOrderCriteriaProvider.notifier);
                  c.reset();
                  c.setPaymentStatus(PaymentStatus.notPaid);
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const SaleOrderListScreen()));
                },
              ),
              const Divider(height: 1),
              _moneyRow(
                context,
                ref,
                label: l10n.homePayables,
                amount: data.payables,
                icon: Icons.call_made_rounded,
                onTap: () {
                  final c = ref.read(po.purchaseOrderCriteriaProvider.notifier);
                  c.reset();
                  c.setPaymentStatus(po_enums.PaymentStatus.notPaid);
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

  Widget _moneyRow(
    BuildContext context,
    WidgetRef ref, {
    required String label,
    required double amount,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final money = ref.watch(moneyFormatterProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final hasAmount = amount > 0.01;
    final color = hasAmount ? Colors.orange.shade700 : Colors.green.shade700;
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(AppTokens.space8),
        decoration: BoxDecoration(
          color: (hasAmount ? Colors.orange : Colors.green).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(label,
          style:
              theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            money(amount),
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w800, color: color),
          ),
          const SizedBox(width: AppTokens.space8),
          Icon(Icons.chevron_right_rounded, color: scheme.outline, size: 16),
        ],
      ),
    );
  }

  Widget _buildStockSection(
      BuildContext context, WidgetRef ref, HomeDashboardData data) {
    final l10n = context.l10n;
    final money = ref.watch(moneyFormatterProvider);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading(context, l10n.homeStockHeading),
        const SizedBox(height: AppTokens.space8),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Icon(Icons.inventory_2_outlined,
                    color: theme.colorScheme.primary),
                title: Text(l10n.homeStockValue,
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w600)),
                trailing: Text(
                  money(data.stockValue),
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                onTap: () {
                  ref
                      .read(productCriteriaProvider.notifier)
                      .set(const ProductCriteria());
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const ProductListScreen()));
                },
              ),
              const Divider(height: 1),
              _countRow(
                context,
                label: l10n.homeLowStock,
                count: data.lowStockCount,
                color: Colors.orange,
                onTap: () {
                  ref
                      .read(productCriteriaProvider.notifier)
                      .set(const ProductCriteria(lowStock: true));
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) =>
                          const ProductListScreen(initialLowStock: true)));
                },
              ),
              const Divider(height: 1),
              _countRow(
                context,
                label: l10n.homeOutOfStock,
                count: data.outOfStockCount,
                color: Colors.red,
                onTap: () {
                  ref
                      .read(productCriteriaProvider.notifier)
                      .set(const ProductCriteria(outOfStock: true));
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) =>
                          const ProductListScreen(initialOutOfStock: true)));
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _countRow(
    BuildContext context, {
    required String label,
    required int count,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return ListTile(
      onTap: onTap,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      title: Text(label,
          style:
              theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count',
            style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: AppTokens.space8),
          Icon(Icons.chevron_right_rounded, color: scheme.outline, size: 16),
        ],
      ),
    );
  }

  Widget _buildOpenWorkSection(
      BuildContext context, WidgetRef ref, HomeDashboardData data) {
    final l10n = context.l10n;

    void pushSaleList(void Function(SaleOrderCriteria c) apply) {
      final c = ref.read(saleOrderCriteriaProvider.notifier);
      c.reset();
      apply(c);
      Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SaleOrderListScreen()));
    }

    void pushPurchaseList(void Function(po.PurchaseOrderCriteria c) apply) {
      final c = ref.read(po.purchaseOrderCriteriaProvider.notifier);
      c.reset();
      apply(c);
      Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PurchaseOrderListScreen()));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading(context, l10n.homeOpenWorkHeading),
        const SizedBox(height: AppTokens.space8),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _countRow(context,
                  label: l10n.homeOpenSaleOrders,
                  count: data.openSaleOrders,
                  color: Colors.blue,
                  onTap: () => pushSaleList((_) {})),
              const Divider(height: 1),
              _countRow(context,
                  label: l10n.homeUnshipped,
                  count: data.unshippedOrders,
                  color: Colors.orange,
                  onTap: () => pushSaleList(
                      (c) => c.setShippingStatus(ShippingStatus.notShipped))),
              const Divider(height: 1),
              _countRow(context,
                  label: l10n.homeOpenPurchaseOrders,
                  count: data.openPurchaseOrders,
                  color: Colors.teal,
                  onTap: () => pushPurchaseList((_) {})),
              const Divider(height: 1),
              _countRow(context,
                  label: l10n.homeUnreceived,
                  count: data.unreceivedOrders,
                  color: Colors.purple,
                  onTap: () => pushPurchaseList((c) => c.setReceiptStatus(
                      po_enums.ReceiptStatus.notReceived))),
              const Divider(height: 1),
              _countRow(context,
                  label: l10n.homeInProduction,
                  count: data.productionInProgress,
                  color: Colors.indigo,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const ProductionHomeScreen()))),
            ],
          ),
        ),
      ],
    );
  }
}
