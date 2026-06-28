import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../../core/widgets/stat_tile.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../app/theme/app_tokens.dart';
import 'purchase_order_detail_screen.dart';
import 'purchase_order_edit_screen.dart';
import 'purchase_order_list_screen.dart';
import 'purchase_order_providers.dart';

class PurchaseOrderDashboardScreen extends ConsumerWidget {
  const PurchaseOrderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kpis = ref.watch(purchaseDashboardProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Purchasing')),
      floatingActionButton: FloatingActionButton(
        heroTag: 'purchasing_fab',
        onPressed: () => _createOrder(context, ref),
        child: const Icon(Icons.add, size: 28),
      ),
      body: AsyncValueView(
        value: kpis,
        data: (k) => ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // Overview section title
            Text(
              'Overview',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppTokens.space12),

            // KPIs row
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    label: 'Open orders',
                    value: '${k.openOrders}',
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: scheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.shopping_bag_outlined, color: scheme.primary, size: 20),
                    ),
                  ),
                ),
                const SizedBox(width: AppTokens.space12),
                Expanded(
                  child: StatTile(
                    label: 'Unreceived',
                    value: '${k.unreceived}',
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.archive_outlined, color: Colors.amber, size: 20),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.space12),

            // Outstanding Payable card
            StatTile(
              label: 'Outstanding payable',
              value: '\$${k.outstanding.toStringAsFixed(2)}',
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.account_balance_wallet_outlined, color: Colors.green, size: 20),
              ),
            ),
            const SizedBox(height: AppTokens.space24),

            // Main View All Purchase Orders link card
            AppCard(
              padding: const EdgeInsets.all(20),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const PurchaseOrderListScreen())),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: scheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.list_alt_rounded, color: scheme.primary, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'View All Purchase Orders',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Browse and manage your purchasing history',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createOrder(BuildContext context, WidgetRef ref) async {
    final id = await Navigator.of(context).push<String>(
        MaterialPageRoute(builder: (_) => const PurchaseOrderEditScreen()));
    ref.invalidate(purchaseDashboardProvider);
    ref.invalidate(purchaseOrdersProvider);
    if (id != null && context.mounted) {
      await Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => PurchaseOrderDetailScreen(orderId: id)));
    }
  }
}
