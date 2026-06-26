import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../../core/widgets/empty_state.dart';
import '../domain/sale_order_enums.dart';
import 'sale_order_detail_screen.dart';
import 'sale_order_edit_screen.dart';
import 'sale_order_providers.dart';

class SaleOrderListScreen extends ConsumerWidget {
  const SaleOrderListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(saleOrdersProvider);
    final filter = ref.watch(saleOrderFilterProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Sale Orders')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const SaleOrderEditScreen()));
          ref.invalidate(saleOrdersProvider);
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: filter == null,
                  onSelected: (_) =>
                      ref.read(saleOrderFilterProvider.notifier).set(null),
                ),
                for (final s in OrderStatus.values)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: FilterChip(
                      label: Text(orderStatusLabel(s)),
                      selected: filter == s,
                      onSelected: (_) =>
                          ref.read(saleOrderFilterProvider.notifier).set(s),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: AsyncValueView(
              value: orders,
              data: (list) => list.isEmpty
                  ? const EmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: 'No sale orders yet. Tap + to create one.')
                  : ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (_, i) {
                        final o = list[i];
                        return ListTile(
                          title: Text(o.soNumber),
                          subtitle: Text(
                              '${orderStatusLabel(o.status)} · ${paymentStatusLabel(o.paymentStatus)} · ${shippingStatusLabel(o.shippingStatus)}'),
                          trailing: Text(o.totalAmount.toStringAsFixed(2)),
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) =>
                                      SaleOrderDetailScreen(orderId: o.id))),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
