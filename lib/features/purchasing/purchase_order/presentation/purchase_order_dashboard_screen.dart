import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../../core/widgets/stat_tile.dart';
import 'purchase_order_list_screen.dart';
import 'purchase_order_providers.dart';

class PurchaseOrderDashboardScreen extends ConsumerWidget {
  const PurchaseOrderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kpis = ref.watch(purchaseDashboardProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Purchasing')),
      body: AsyncValueView(
        value: kpis,
        data: (k) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                    child: StatTile(
                        label: 'Open orders', value: '${k.openOrders}')),
                const SizedBox(width: 12),
                Expanded(
                    child: StatTile(
                        label: 'Unreceived', value: '${k.unreceived}')),
              ],
            ),
            const SizedBox(height: 12),
            StatTile(
                label: 'Outstanding payable',
                value: k.outstanding.toStringAsFixed(2)),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.list_alt),
              label: const Text('View all purchase orders'),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const PurchaseOrderListScreen())),
            ),
          ],
        ),
      ),
    );
  }
}
