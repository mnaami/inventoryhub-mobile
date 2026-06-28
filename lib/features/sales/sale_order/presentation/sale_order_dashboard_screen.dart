import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../../core/widgets/stat_tile.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../app/theme/app_tokens.dart';
import 'sale_order_detail_screen.dart';
import 'sale_order_edit_screen.dart';
import 'sale_order_list_screen.dart';
import 'sale_order_providers.dart';

class SaleOrderDashboardScreen extends ConsumerWidget {
  const SaleOrderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kpis = ref.watch(saleDashboardProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Dashboard'),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'sales_fab',
        onPressed: () => _createOrder(context, ref),
        child: const Icon(Icons.add, size: 28),
      ),
      body: AsyncValueView(
        value: kpis,
        data: (k) => ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // Welcome Section
            Text(
              'Overview',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppTokens.space12),
            
            // KPI Grid
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    label: 'Open Orders',
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
                    label: 'Unshipped',
                    value: '${k.unshipped}',
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.local_shipping_outlined, color: Colors.amber, size: 20),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.space12),
            StatTile(
              label: 'Outstanding Balance',
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
            
            // Main Actions Section
            AppCard(
              padding: const EdgeInsets.all(20),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const SaleOrderListScreen())),
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
                          'View Sale Orders',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Manage your order-to-cash workflow',
                          style: theme.textTheme.bodySmall?.copyWith(
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
        MaterialPageRoute(builder: (_) => const SaleOrderEditScreen()));
    ref.invalidate(saleDashboardProvider);
    ref.invalidate(saleOrdersProvider);
    if (id != null && context.mounted) {
      await Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => SaleOrderDetailScreen(orderId: id)));
    }
  }
}
