import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../../core/widgets/empty_state.dart';
import '../domain/purchase_order_enums.dart';
import 'purchase_order_detail_screen.dart';
import 'purchase_order_edit_screen.dart';
import 'purchase_order_providers.dart';

class PurchaseOrderListScreen extends ConsumerWidget {
  const PurchaseOrderListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(purchaseOrdersProvider);
    final filter = ref.watch(purchaseOrderFilterProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Purchase Orders')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const PurchaseOrderEditScreen()));
          ref.invalidate(purchaseOrdersProvider);
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
                      ref.read(purchaseOrderFilterProvider.notifier).set(null),
                ),
                for (final s in PurchaseOrderStatus.values)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: FilterChip(
                      label: Text(poStatusLabel(s)),
                      selected: filter == s,
                      onSelected: (_) => ref
                          .read(purchaseOrderFilterProvider.notifier)
                          .set(s),
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
                      icon: Icons.shopping_cart_outlined,
                      title: 'No purchase orders yet. Tap + to create one.')
                  : ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (_, i) {
                        final o = list[i];
                        return ListTile(
                          title: Text(o.orderNumber),
                          subtitle: Text(
                              '${poStatusLabel(o.status)} · ${paymentStatusLabel(o.paymentStatus)} · ${receiptStatusLabel(o.receiptStatus)}'),
                          trailing: Text(o.totalAmount.toStringAsFixed(2)),
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => PurchaseOrderDetailScreen(
                                      orderId: o.id))),
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
