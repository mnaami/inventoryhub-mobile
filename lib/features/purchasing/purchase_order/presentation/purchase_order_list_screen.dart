import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import 'package:inventoryhub_mobile/app/currency/currency_controller.dart';
import '../../../../core/l10n/l10n_ext.dart';
import '../../../../core/widgets/paginated_list_view.dart';
import '../../../../core/widgets/search_field.dart';
import '../../../../l10n/app_localizations.dart';
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
    final l10n = context.l10n;
    final money = ref.watch(moneyFormatterProvider);
    final state = ref.watch(purchaseOrderListProvider);
    final criteria = ref.watch(purchaseOrderCriteriaProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: _searching
            ? SearchField(
                initial: criteria.search,
                hint: l10n.poSearchHint,
                onChanged: (v) =>
                    ref.read(purchaseOrderCriteriaProvider.notifier).setSearch(v),
              )
            : Text(l10n.poListTitle),
        actions: [
          if (criteria.hasActiveFilters)
            IconButton(
              tooltip: l10n.poClearAllFiltersTooltip,
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
              empty: EmptyState(
                icon: Icons.shopping_bag_outlined,
                title: l10n.poListEmpty,
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
                                money(o.totalAmount),
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
                                  supplier?.name ?? l10n.poUnknownSupplier,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                loading: () => Text(
                                  l10n.poLoadingSupplier,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: scheme.onSurfaceVariant.withOpacity(0.6),
                                  ),
                                ),
                                error: (_, __) => Text(
                                  l10n.poUnknownSupplier,
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
                                  _badge(context, poStatusLabel(l10n, o.status),
                                      _statusColor(o.status)),
                                  const SizedBox(width: 6),
                                  _badge(context, paymentStatusLabel(l10n, o.paymentStatus),
                                      _paymentColor(o.paymentStatus)),
                                  const SizedBox(width: 6),
                                  _badge(context, receiptStatusLabel(l10n, o.receiptStatus),
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
    final l10n = context.l10n;
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
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: ActionChip(
                avatar: Icon(Icons.filter_alt_off_rounded, size: 14, color: scheme.error),
                label: Text(
                  l10n.poClearAll,
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
          if (criteria.supplierId != null) ...[
            Consumer(
              builder: (context, ref, _) {
                final supplierVal = ref.watch(supplierProvider(criteria.supplierId!));
                final name = supplierVal.asData?.value?.name ?? 'Loading...';
                return _FilterPill<String?>(
                  label: 'Supplier',
                  isActive: true,
                  displayValue: name,
                  onChanged: (_) {},
                  onClear: () => n.setSupplierId(null),
                  items: const [],
                );
              },
            ),
            const SizedBox(width: 8),
          ],
          _FilterPill<PurchaseOrderStatus?>(
            label: l10n.poFilterStatusLabel,
            isActive: criteria.status != null,
            displayValue: criteria.status != null
                ? poStatusLabel(l10n, criteria.status!)
                : '',
            onChanged: n.setStatus,
            onClear: () => n.setStatus(null),
            items: [
              PopupMenuItem(value: null, child: Text(l10n.poFilterAnyStatus)),
              for (final s in PurchaseOrderStatus.values)
                PopupMenuItem(value: s, child: Text(poStatusLabel(l10n, s))),
            ],
          ),
          const SizedBox(width: 8),
          _FilterPill<DatePreset>(
            label: l10n.poFilterDateLabel,
            isActive: criteria.datePreset != DatePreset.all,
            displayValue: _datePresetLabel(l10n, criteria.datePreset),
            onChanged: n.setDatePreset,
            onClear: () => n.setDatePreset(DatePreset.all),
            items: [
              PopupMenuItem(value: DatePreset.all, child: Text(l10n.poDateAllDates)),
              PopupMenuItem(value: DatePreset.today, child: Text(l10n.poDateToday)),
              PopupMenuItem(value: DatePreset.week, child: Text(l10n.poDateWeek)),
              PopupMenuItem(value: DatePreset.month, child: Text(l10n.poDateMonth)),
            ],
          ),
          const SizedBox(width: 8),
          _FilterPill<PaymentStatus?>(
            label: l10n.poFilterPaymentLabel,
            isActive: criteria.paymentStatus != null,
            displayValue: criteria.paymentStatus != null
                ? paymentStatusLabel(l10n, criteria.paymentStatus!)
                : '',
            onChanged: n.setPaymentStatus,
            onClear: () => n.setPaymentStatus(null),
            items: [
              PopupMenuItem(value: null, child: Text(l10n.poFilterAnyPayment)),
              for (final p in PaymentStatus.values)
                PopupMenuItem(value: p, child: Text(paymentStatusLabel(l10n, p))),
            ],
          ),
          const SizedBox(width: 8),
          _FilterPill<ReceiptStatus?>(
            label: l10n.poFilterReceiptLabel,
            isActive: criteria.receiptStatus != null,
            displayValue: criteria.receiptStatus != null
                ? receiptStatusLabel(l10n, criteria.receiptStatus!)
                : '',
            onChanged: n.setReceiptStatus,
            onClear: () => n.setReceiptStatus(null),
            items: [
              PopupMenuItem(value: null, child: Text(l10n.poFilterAnyReceipt)),
              for (final s in ReceiptStatus.values)
                PopupMenuItem(value: s, child: Text(receiptStatusLabel(l10n, s))),
            ],
          ),
        ],
      ),
    );
  }

  String _datePresetLabel(AppLocalizations l10n, DatePreset p) => switch (p) {
        DatePreset.all => l10n.poDateAll,
        DatePreset.today => l10n.poDateToday,
        DatePreset.week => l10n.poDateWeek,
        DatePreset.month => l10n.poDateMonth,
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
              padding: EdgeInsetsDirectional.only(
                start: 12,
                end: isActive ? 6 : 12,
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
              padding: const EdgeInsetsDirectional.only(end: 8),
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
