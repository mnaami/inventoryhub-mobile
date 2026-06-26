import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../../core/widgets/stat_tile.dart';
import 'sale_order_list_screen.dart';
import 'sale_order_providers.dart';

class SaleOrderDashboardScreen extends ConsumerWidget {
  const SaleOrderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kpis = ref.watch(saleDashboardProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Sales')),
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
                    child:
                        StatTile(label: 'Unshipped', value: '${k.unshipped}')),
              ],
            ),
            const SizedBox(height: 12),
            StatTile(
                label: 'Outstanding',
                value: k.outstanding.toStringAsFixed(2)),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.list_alt),
              label: const Text('View all sale orders'),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const SaleOrderListScreen())),
            ),
          ],
        ),
      ),
    );
  }
}
