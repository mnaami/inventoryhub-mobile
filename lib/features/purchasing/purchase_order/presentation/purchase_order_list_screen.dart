import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../app/theme/app_tokens.dart';
import '../domain/purchase_order.dart';
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Purchase Orders')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final id = await Navigator.of(context).push<String>(MaterialPageRoute(
              builder: (_) => const PurchaseOrderEditScreen()));
          ref.invalidate(purchaseOrdersProvider);
          if (id != null && context.mounted) {
            await Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => PurchaseOrderDetailScreen(orderId: id)));
          }
        },
        child: const Icon(Icons.add, size: 28),
      ),
      body: Column(
        children: [
          // Filter Chips Section
          Container(
            height: 48,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
          
          // Order List Section
          Expanded(
            child: AsyncValueView<List<PurchaseOrder>>(
              value: orders,
              data: (list) => list.isEmpty
                  ? const EmptyState(
                      icon: Icons.shopping_cart_outlined,
                      title: 'No purchase orders yet. Tap + to create one.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final o = list[i];
                        return AppCard(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => PurchaseOrderDetailScreen(
                                      orderId: o.id))),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: scheme.primary.withOpacity(0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.shopping_bag_outlined, color: scheme.primary, size: 22),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      o.orderNumber,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: scheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 4,
                                      children: [
                                        _buildStatusBadge(context, o.status),
                                        _buildPaymentStatusBadge(context, o.paymentStatus),
                                        _buildReceiptStatusBadge(context, o.receiptStatus),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '\$${o.totalAmount.toStringAsFixed(2)}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: scheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, PurchaseOrderStatus status) {
    final color = switch (status) {
      PurchaseOrderStatus.draft => Colors.blueGrey,
      PurchaseOrderStatus.sent => Colors.blue,
      PurchaseOrderStatus.confirmed => Colors.indigo,
      PurchaseOrderStatus.received => Colors.green,
      PurchaseOrderStatus.cancelled => Colors.red,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        poStatusLabel(status),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPaymentStatusBadge(BuildContext context, PaymentStatus status) {
    final color = switch (status) {
      PaymentStatus.notPaid => Colors.red,
      PaymentStatus.partial => Colors.amber,
      PaymentStatus.paid => Colors.green,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        paymentStatusLabel(status),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildReceiptStatusBadge(BuildContext context, ReceiptStatus status) {
    final color = switch (status) {
      ReceiptStatus.notReceived => Colors.red,
      ReceiptStatus.partial => Colors.amber,
      ReceiptStatus.fullyReceived => Colors.green,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        receiptStatusLabel(status),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
