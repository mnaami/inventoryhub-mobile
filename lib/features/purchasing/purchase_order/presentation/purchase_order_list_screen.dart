import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/paginated_list_view.dart';
import '../../../../core/widgets/search_field.dart';
import '../domain/purchase_order.dart';
import '../domain/purchase_order_enums.dart';
import 'purchase_order_detail_screen.dart';
import 'purchase_order_edit_screen.dart';
import 'purchase_order_providers.dart';
import '../../supplier/presentation/supplier_providers.dart';

class PurchaseOrderListScreen extends ConsumerStatefulWidget {
  const PurchaseOrderListScreen({super.key});

  @override
  ConsumerState<PurchaseOrderListScreen> createState() => _PurchaseOrderListScreenState();
}

class _PurchaseOrderListScreenState extends ConsumerState<PurchaseOrderListScreen> {
  bool _searching = false;

  PurchaseOrderListNotifier get _notifier =>
      ref.read(purchaseOrderListProvider.notifier);

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(purchaseOrderListProvider);
    final criteria = ref.watch(purchaseOrderCriteriaProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: _searching
            ? SearchField(
                initial: criteria.search,
                hint: 'Search PO number',
                onChanged: (v) =>
                    ref.read(purchaseOrderCriteriaProvider.notifier).setSearch(v),
              )
            : const Text('Purchase Orders'),
        actions: [
          if (criteria.hasActiveFilters)
            IconButton(
              tooltip: 'Clear all filters',
              icon: const Icon(Icons.filter_alt_off),
              onPressed: () {
                ref.read(purchaseOrderCriteriaProvider.notifier).reset();
                if (_searching) {
                  setState(() => _searching = false);
                }
              },
            ),
          IconButton(
            icon: Icon(_searching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() => _searching = !_searching);
              if (!_searching) {
                ref.read(purchaseOrderCriteriaProvider.notifier).setSearch('');
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'purchase_orders_list_fab',
        onPressed: () async {
          final id = await Navigator.of(context).push<String>(
              MaterialPageRoute(builder: (_) => const PurchaseOrderEditScreen()));
          if (!mounted) return;
          await _notifier.refresh();
          if (id != null && context.mounted) {
            await Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => PurchaseOrderDetailScreen(orderId: id)));
            if (mounted) await _notifier.refresh();
          }
        },
        child: const Icon(Icons.add, size: 28),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          _Filters(criteria: criteria),
          const SizedBox(height: 8),
          Expanded(
            child: PaginatedListView<PurchaseOrder>(
              state: state,
              onLoadMore: _notifier.loadMore,
              onRefresh: _notifier.refresh,
              onRetryInitial: _notifier.loadInitial,
              empty: const EmptyState(
                icon: Icons.shopping_bag_outlined,
                title: 'No purchase orders yet. Tap + to create one.',
              ),
              itemBuilder: (context, o) => AppCard(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                onTap: () async {
                  await Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => PurchaseOrderDetailScreen(orderId: o.id)));
                  if (mounted) await _notifier.refresh();
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: scheme.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.shopping_bag_outlined,
                          color: scheme.primary, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                o.orderNumber,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: scheme.onSurface,
                                ),
                              ),
                              Text(
                                '\$${o.totalAmount.toStringAsFixed(2)}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: scheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Consumer(
                            builder: (context, ref, child) {
                              final supplierAsync = ref.watch(supplierProvider(o.supplierId));
                              return supplierAsync.when(
                                data: (supplier) => Text(
                                  supplier?.name ?? 'Unknown Supplier',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                loading: () => Text(
                                  'Loading supplier...',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: scheme.onSurfaceVariant.withOpacity(0.6),
                                  ),
                                ),
                                error: (_, __) => Text(
                                  'Unknown Supplier',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: scheme.onSurfaceVariant.withOpacity(0.6),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat.yMMMd().format(o.orderDate),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Row(
                                children: [
                                  _badge(context, poStatusLabel(o.status),
                                      _statusColor(o.status)),
                                  const SizedBox(width: 6),
                                  _badge(context, paymentStatusLabel(o.paymentStatus),
                                      _paymentColor(o.paymentStatus)),
                                  const SizedBox(width: 6),
                                  _badge(context, receiptStatusLabel(o.receiptStatus),
                                      _receiptColor(o.receiptStatus)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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

  Color _statusColor(PurchaseOrderStatus s) => switch (s) {
        PurchaseOrderStatus.draft => Colors.blueGrey.shade600,
        PurchaseOrderStatus.sent => Colors.blue.shade700,
        PurchaseOrderStatus.confirmed => Colors.indigo.shade600,
        PurchaseOrderStatus.received => Colors.green.shade700,
        PurchaseOrderStatus.cancelled => Colors.red.shade700,
      };

  Color _paymentColor(PaymentStatus s) => switch (s) {
        PaymentStatus.notPaid => Colors.red.shade700,
        PaymentStatus.partial => Colors.amber.shade700,
        PaymentStatus.paid => Colors.green.shade700,
      };

  Color _receiptColor(ReceiptStatus s) => switch (s) {
        ReceiptStatus.notReceived => Colors.red.shade700,
        ReceiptStatus.partial => Colors.amber.shade700,
        ReceiptStatus.fullyReceived => Colors.green.shade700,
      };
}

class _Filters extends ConsumerWidget {
  const _Filters({required this.criteria});
  final PurchaseOrderListCriteria criteria;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = ref.read(purchaseOrderCriteriaProvider.notifier);
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          if (criteria.hasActiveFilters)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ActionChip(
                avatar: Icon(Icons.filter_alt_off_rounded, size: 14, color: scheme.error),
                label: Text(
                  'Clear All',
                  style: TextStyle(
                    color: scheme.error,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                backgroundColor: scheme.error.withOpacity(0.08),
                side: BorderSide(color: scheme.error.withOpacity(0.3)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                onPressed: () {
                  ref.read(purchaseOrderCriteriaProvider.notifier).reset();
                },
              ),
            ),
          _FilterPill<PurchaseOrderStatus?>(
            label: 'Status',
            isActive: criteria.status != null,
            displayValue: criteria.status != null
                ? poStatusLabel(criteria.status!)
                : '',
            onChanged: n.setStatus,
            onClear: () => n.setStatus(null),
            items: [
              const PopupMenuItem(value: null, child: Text('Any status')),
              for (final s in PurchaseOrderStatus.values)
                PopupMenuItem(value: s, child: Text(poStatusLabel(s))),
            ],
          ),
          const SizedBox(width: 8),
          _FilterPill<DatePreset>(
            label: 'Date',
            isActive: criteria.datePreset != DatePreset.all,
            displayValue: _datePresetLabel(criteria.datePreset),
            onChanged: n.setDatePreset,
            onClear: () => n.setDatePreset(DatePreset.all),
            items: const [
              PopupMenuItem(value: DatePreset.all, child: Text('All dates')),
              PopupMenuItem(value: DatePreset.today, child: Text('Today')),
              PopupMenuItem(value: DatePreset.week, child: Text('This week')),
              PopupMenuItem(value: DatePreset.month, child: Text('This month')),
            ],
          ),
          const SizedBox(width: 8),
          _FilterPill<PaymentStatus?>(
            label: 'Payment',
            isActive: criteria.paymentStatus != null,
            displayValue: criteria.paymentStatus != null
                ? paymentStatusLabel(criteria.paymentStatus!)
                : '',
            onChanged: n.setPaymentStatus,
            onClear: () => n.setPaymentStatus(null),
            items: [
              const PopupMenuItem(value: null, child: Text('Any payment')),
              for (final p in PaymentStatus.values)
                PopupMenuItem(value: p, child: Text(paymentStatusLabel(p))),
            ],
          ),
          const SizedBox(width: 8),
          _FilterPill<ReceiptStatus?>(
            label: 'Receipt',
            isActive: criteria.receiptStatus != null,
            displayValue: criteria.receiptStatus != null
                ? receiptStatusLabel(criteria.receiptStatus!)
                : '',
            onChanged: n.setReceiptStatus,
            onClear: () => n.setReceiptStatus(null),
            items: [
              const PopupMenuItem(value: null, child: Text('Any receipt')),
              for (final s in ReceiptStatus.values)
                PopupMenuItem(value: s, child: Text(receiptStatusLabel(s))),
            ],
          ),
        ],
      ),
    );
  }

  String _datePresetLabel(DatePreset p) => switch (p) {
        DatePreset.all => 'All',
        DatePreset.today => 'Today',
        DatePreset.week => 'This week',
        DatePreset.month => 'This month',
      };
}

class _FilterPill<T> extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.isActive,
    required this.displayValue,
    required this.items,
    required this.onChanged,
    required this.onClear,
  });

  final String label;
  final bool isActive;
  final String displayValue;
  final List<PopupMenuEntry<T>> items;
  final ValueChanged<T> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: isActive
            ? scheme.primary.withOpacity(0.08)
            : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive
              ? scheme.primary
              : scheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PopupMenuButton<T>(
            onSelected: onChanged,
            itemBuilder: (_) => items,
            child: Padding(
              padding: EdgeInsets.only(
                left: 12,
                right: isActive ? 6 : 12,
                top: 6,
                bottom: 6,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isActive ? '$label: ' : label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                      color: isActive ? scheme.primary : scheme.onSurfaceVariant,
                    ),
                  ),
                  if (isActive)
                    Text(
                      displayValue,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.primary,
                      ),
                    )
                  else ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_drop_down,
                      size: 16,
                      color: scheme.onSurfaceVariant,
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isActive)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: onClear,
                borderRadius: BorderRadius.circular(100),
                child: Icon(
                  Icons.cancel,
                  size: 16,
                  color: scheme.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
