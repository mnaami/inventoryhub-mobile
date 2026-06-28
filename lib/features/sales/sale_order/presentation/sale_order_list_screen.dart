import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/paginated_list_view.dart';
import '../../../../core/widgets/search_field.dart';
import '../domain/sale_order.dart';
import '../domain/sale_order_enums.dart';
import 'sale_order_detail_screen.dart';
import 'sale_order_edit_screen.dart';
import 'sale_order_providers.dart';

class SaleOrderListScreen extends ConsumerStatefulWidget {
  const SaleOrderListScreen({super.key});

  @override
  ConsumerState<SaleOrderListScreen> createState() => _SaleOrderListScreenState();
}

class _SaleOrderListScreenState extends ConsumerState<SaleOrderListScreen> {
  bool _searching = false;

  SaleOrderListNotifier get _notifier =>
      ref.read(saleOrderListProvider.notifier);

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(saleOrderListProvider);
    final criteria = ref.watch(saleOrderCriteriaProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: _searching
            ? SearchField(
                initial: criteria.search,
                hint: 'Search SO number',
                onChanged: (v) =>
                    ref.read(saleOrderCriteriaProvider.notifier).setSearch(v),
              )
            : const Text('Sale Orders'),
        actions: [
          IconButton(
            icon: Icon(_searching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() => _searching = !_searching);
              if (!_searching) {
                ref.read(saleOrderCriteriaProvider.notifier).setSearch('');
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'sale_orders_list_fab',
        onPressed: () async {
          final id = await Navigator.of(context).push<String>(
              MaterialPageRoute(builder: (_) => const SaleOrderEditScreen()));
          if (!mounted) return;
          await _notifier.refresh();
          if (id != null && context.mounted) {
            await Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => SaleOrderDetailScreen(orderId: id)));
            if (mounted) await _notifier.refresh();
          }
        },
        child: const Icon(Icons.add, size: 28),
      ),
      body: Column(
        children: [
          _StatusChips(criteria: criteria),
          _SecondaryFilters(criteria: criteria),
          Expanded(
            child: PaginatedListView<SaleOrder>(
              state: state,
              onLoadMore: _notifier.loadMore,
              onRefresh: _notifier.refresh,
              onRetryInitial: _notifier.loadInitial,
              empty: const EmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'No sale orders yet. Tap + to create one.',
              ),
              itemBuilder: (context, o) => AppCard(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                onTap: () async {
                  await Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => SaleOrderDetailScreen(orderId: o.id)));
                  if (mounted) await _notifier.refresh();
                },
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: scheme.primary.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.receipt_long,
                          color: scheme.primary, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(o.soNumber,
                              style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: scheme.onSurface)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _badge(context, orderStatusLabel(o.status),
                                  _statusColor(o.status)),
                              const SizedBox(width: 6),
                              _badge(context, paymentStatusLabel(o.paymentStatus),
                                  _paymentColor(o.paymentStatus)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('\$${o.totalAmount.toStringAsFixed(2)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: scheme.onSurface)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(BuildContext context, String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(6)),
        child: Text(label,
            style: TextStyle(
                color: color, fontSize: 10, fontWeight: FontWeight.bold)),
      );

  Color _statusColor(OrderStatus s) => switch (s) {
        OrderStatus.draft => Colors.blueGrey,
        OrderStatus.confirmed => Colors.blue,
        OrderStatus.processing => Colors.indigo,
        OrderStatus.shipped => Colors.purple,
        OrderStatus.delivered => Colors.green,
        OrderStatus.cancelled => Colors.red,
      };

  Color _paymentColor(PaymentStatus s) => switch (s) {
        PaymentStatus.notPaid => Colors.red,
        PaymentStatus.partial => Colors.amber,
        PaymentStatus.paid => Colors.green,
      };
}

class _StatusChips extends ConsumerWidget {
  const _StatusChips({required this.criteria});
  final SaleOrderListCriteria criteria;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = ref.read(saleOrderCriteriaProvider.notifier);
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          FilterChip(
            label: const Text('All'),
            selected: criteria.status == null,
            onSelected: (_) => n.setStatus(null),
          ),
          for (final s in OrderStatus.values)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: FilterChip(
                label: Text(orderStatusLabel(s)),
                selected: criteria.status == s,
                onSelected: (_) => n.setStatus(s),
              ),
            ),
        ],
      ),
    );
  }
}

class _SecondaryFilters extends ConsumerWidget {
  const _SecondaryFilters({required this.criteria});
  final SaleOrderListCriteria criteria;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = ref.read(saleOrderCriteriaProvider.notifier);
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          DropdownButton<DatePreset>(
            value: criteria.datePreset,
            onChanged: (v) => n.setDatePreset(v ?? DatePreset.all),
            items: const [
              DropdownMenuItem(value: DatePreset.all, child: Text('All dates')),
              DropdownMenuItem(value: DatePreset.today, child: Text('Today')),
              DropdownMenuItem(value: DatePreset.week, child: Text('This week')),
              DropdownMenuItem(value: DatePreset.month, child: Text('This month')),
            ],
          ),
          const SizedBox(width: 12),
          DropdownButton<PaymentStatus?>(
            value: criteria.paymentStatus,
            hint: const Text('Payment'),
            onChanged: n.setPaymentStatus,
            items: [
              const DropdownMenuItem(value: null, child: Text('Any payment')),
              for (final p in PaymentStatus.values)
                DropdownMenuItem(value: p, child: Text(paymentStatusLabel(p))),
            ],
          ),
          const SizedBox(width: 12),
          DropdownButton<ShippingStatus?>(
            value: criteria.shippingStatus,
            hint: const Text('Shipping'),
            onChanged: n.setShippingStatus,
            items: [
              const DropdownMenuItem(value: null, child: Text('Any shipping')),
              for (final s in ShippingStatus.values)
                DropdownMenuItem(value: s, child: Text(_shippingLabel(s))),
            ],
          ),
        ],
      ),
    );
  }

  String _shippingLabel(ShippingStatus s) => switch (s) {
        ShippingStatus.notShipped => 'Not shipped',
        ShippingStatus.partiallyShipped => 'Partially shipped',
        ShippingStatus.fullyShipped => 'Fully shipped',
      };
}
