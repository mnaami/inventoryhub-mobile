import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import 'package:inventoryhub_mobile/app/currency/currency_controller.dart';
import '../../../../core/l10n/l10n_ext.dart';
import '../../../../core/widgets/filter_pill.dart';
import '../../../../core/widgets/paginated_list_view.dart';
import '../../../../core/widgets/search_field.dart';
import '../../../../l10n/app_localizations.dart';
import '../domain/sale_order.dart';
import '../domain/sale_order_enums.dart';
import 'sale_order_detail_screen.dart';
import 'sale_order_edit_screen.dart';
import 'sale_order_providers.dart';
import '../../customer/presentation/customer_providers.dart';

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
    final l10n = context.l10n;
    final money = ref.watch(moneyFormatterProvider);
    final state = ref.watch(saleOrderListProvider);
    final criteria = ref.watch(saleOrderCriteriaProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: _searching
            ? SearchField(
                initial: criteria.search,
                hint: l10n.soSearchHint,
                onChanged: (v) =>
                    ref.read(saleOrderCriteriaProvider.notifier).setSearch(v),
              )
            : Text(l10n.soListTitle),
        actions: [
          if (criteria.hasActiveFilters)
            IconButton(
              tooltip: l10n.soClearAllFiltersTooltip,
              icon: const Icon(Icons.filter_alt_off),
              onPressed: () {
                ref.read(saleOrderCriteriaProvider.notifier).reset();
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
          const SizedBox(height: 8),
          _Filters(criteria: criteria),
          const SizedBox(height: 8),
          Expanded(
            child: PaginatedListView<SaleOrder>(
              state: state,
              onLoadMore: _notifier.loadMore,
              onRefresh: _notifier.refresh,
              onRetryInitial: _notifier.loadInitial,
              empty: EmptyState(
                icon: Icons.receipt_long_outlined,
                title: l10n.soListEmpty,
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: scheme.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.receipt_long,
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
                                o.soNumber,
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
                              final customerAsync = ref.watch(customerProvider(o.customerId));
                              return customerAsync.when(
                                data: (customer) => Text(
                                  customer?.name ?? l10n.soUnknownCustomer,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                loading: () => Text(
                                  l10n.soLoadingCustomer,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: scheme.onSurfaceVariant.withOpacity(0.6),
                                  ),
                                ),
                                error: (_, __) => Text(
                                  l10n.soUnknownCustomer,
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
                                  _badge(context, orderStatusLabel(l10n, o.status),
                                      _statusColor(o.status)),
                                  const SizedBox(width: 6),
                                  _badge(context, paymentStatusLabel(l10n, o.paymentStatus),
                                      _paymentColor(o.paymentStatus)),
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

  Color _statusColor(OrderStatus s) => switch (s) {
        OrderStatus.draft => Colors.blueGrey.shade600,
        OrderStatus.confirmed => Colors.blue.shade700,
        OrderStatus.processing => Colors.indigo.shade600,
        OrderStatus.shipped => Colors.purple.shade600,
        OrderStatus.delivered => Colors.green.shade700,
        OrderStatus.cancelled => Colors.red.shade700,
      };

  Color _paymentColor(PaymentStatus s) => switch (s) {
        PaymentStatus.notPaid => Colors.red.shade700,
        PaymentStatus.partial => Colors.amber.shade700,
        PaymentStatus.paid => Colors.green.shade700,
      };
}

class _Filters extends ConsumerWidget {
  const _Filters({required this.criteria});
  final SaleOrderListCriteria criteria;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final n = ref.read(saleOrderCriteriaProvider.notifier);
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
                  l10n.soClearAll,
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
                  ref.read(saleOrderCriteriaProvider.notifier).reset();
                },
              ),
            ),
          if (criteria.customerId != null) ...[
            Consumer(
              builder: (context, ref, _) {
                final customerVal = ref.watch(customerProvider(criteria.customerId!));
                final name = customerVal.asData?.value?.name ?? 'Loading...';
                return FilterPill<String?>(
                  label: 'Customer',
                  isActive: true,
                  displayValue: name,
                  onChanged: (_) {},
                  onClear: () => n.setCustomerId(null),
                  items: const [],
                );
              },
            ),
            const SizedBox(width: 8),
          ],
          FilterPill<OrderStatus?>(
            label: l10n.soFilterStatusLabel,
            isActive: criteria.status != null,
            displayValue: criteria.status != null
                ? orderStatusLabel(l10n, criteria.status!)
                : '',
            onChanged: n.setStatus,
            onClear: () => n.setStatus(null),
            items: [
              PopupMenuItem(value: null, child: Text(l10n.soFilterAnyStatus)),
              for (final s in OrderStatus.values)
                PopupMenuItem(value: s, child: Text(orderStatusLabel(l10n, s))),
            ],
          ),
          const SizedBox(width: 8),
          FilterPill<DatePreset>(
            label: l10n.soFilterDateLabel,
            isActive: criteria.datePreset != DatePreset.all,
            displayValue: _datePresetLabel(l10n, criteria.datePreset),
            onChanged: n.setDatePreset,
            onClear: () => n.setDatePreset(DatePreset.all),
            items: [
              PopupMenuItem(value: DatePreset.all, child: Text(l10n.soDateAllDates)),
              PopupMenuItem(value: DatePreset.today, child: Text(l10n.soDateToday)),
              PopupMenuItem(value: DatePreset.week, child: Text(l10n.soDateWeek)),
              PopupMenuItem(value: DatePreset.month, child: Text(l10n.soDateMonth)),
            ],
          ),
          const SizedBox(width: 8),
          FilterPill<PaymentStatus?>(
            label: l10n.soFilterPaymentLabel,
            isActive: criteria.paymentStatus != null,
            displayValue: criteria.paymentStatus != null
                ? paymentStatusLabel(l10n, criteria.paymentStatus!)
                : '',
            onChanged: n.setPaymentStatus,
            onClear: () => n.setPaymentStatus(null),
            items: [
              PopupMenuItem(value: null, child: Text(l10n.soFilterAnyPayment)),
              for (final p in PaymentStatus.values)
                PopupMenuItem(value: p, child: Text(paymentStatusLabel(l10n, p))),
            ],
          ),
          const SizedBox(width: 8),
          FilterPill<ShippingStatus?>(
            label: l10n.soFilterShippingLabel,
            isActive: criteria.shippingStatus != null,
            displayValue: criteria.shippingStatus != null
                ? shippingStatusLabel(l10n, criteria.shippingStatus!)
                : '',
            onChanged: n.setShippingStatus,
            onClear: () => n.setShippingStatus(null),
            items: [
              PopupMenuItem(value: null, child: Text(l10n.soFilterAnyShipping)),
              for (final s in ShippingStatus.values)
                PopupMenuItem(value: s, child: Text(shippingStatusLabel(l10n, s))),
            ],
          ),
        ],
      ),
    );
  }

  String _datePresetLabel(AppLocalizations l10n, DatePreset p) => switch (p) {
        DatePreset.all => l10n.soDateAll,
        DatePreset.today => l10n.soDateToday,
        DatePreset.week => l10n.soDateWeek,
        DatePreset.month => l10n.soDateMonth,
      };
}

