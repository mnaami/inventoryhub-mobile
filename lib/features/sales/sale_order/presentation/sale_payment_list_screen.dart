import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:inventoryhub_mobile/app/currency/currency_controller.dart';
import '../../../../core/l10n/l10n_ext.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/filter_pill.dart';
import '../../../../core/widgets/paginated_list_view.dart';
import '../../../../core/widgets/search_field.dart';
import '../domain/sale_order.dart';
import '../domain/sale_order_enums.dart';
import '../../../../l10n/app_localizations.dart';
import '../../customer/presentation/customer_providers.dart';
import 'sale_order_detail_screen.dart';
import 'sale_order_providers.dart' show DatePreset;
import 'sale_payment_providers.dart';

class SalePaymentListScreen extends ConsumerStatefulWidget {
  const SalePaymentListScreen({super.key});

  @override
  ConsumerState<SalePaymentListScreen> createState() =>
      _SalePaymentListScreenState();
}

class _SalePaymentListScreenState extends ConsumerState<SalePaymentListScreen> {
  bool _searching = false;

  SalePaymentListNotifier get _notifier =>
      ref.read(salePaymentListProvider.notifier);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final money = ref.watch(moneyFormatterProvider);
    final state = ref.watch(salePaymentListProvider);
    final criteria = ref.watch(salePaymentCriteriaProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: _searching
            ? SearchField(
                initial: criteria.search,
                hint: l10n.soSearchHint,
                onChanged: (v) => ref
                    .read(salePaymentCriteriaProvider.notifier)
                    .setSearch(v),
              )
            : Text(l10n.spLedgerTitle),
        actions: [
          if (criteria.hasActiveFilters)
            IconButton(
              tooltip: l10n.soClearAllFiltersTooltip,
              icon: const Icon(Icons.filter_alt_off),
              onPressed: () {
                ref.read(salePaymentCriteriaProvider.notifier).reset();
                if (_searching) setState(() => _searching = false);
              },
            ),
          IconButton(
            icon: Icon(_searching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() => _searching = !_searching);
              if (!_searching) {
                ref.read(salePaymentCriteriaProvider.notifier).setSearch('');
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          _Filters(criteria: criteria),
          const SizedBox(height: 8),
          Expanded(
            child: PaginatedListView<SalePaymentListItem>(
              state: state,
              onLoadMore: _notifier.loadMore,
              onRefresh: _notifier.refresh,
              onRetryInitial: _notifier.loadInitial,
              empty: EmptyState(
                icon: Icons.payments_outlined,
                title: l10n.spLedgerEmpty,
              ),
              itemBuilder: (context, p) => AppCard(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                onTap: () async {
                  await Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) =>
                          SaleOrderDetailScreen(orderId: p.saleOrderId)));
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
                      child: Icon(Icons.payments,
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
                                p.paymentNumber,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: scheme.onSurface,
                                ),
                              ),
                              Text(
                                money(p.amount),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: scheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                p.soNumber,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text('  •  ',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                      color: scheme.onSurfaceVariant)),
                              Expanded(
                                child: Consumer(
                                  builder: (context, ref, child) {
                                    final customerAsync =
                                        ref.watch(customerProvider(p.customerId));
                                    return customerAsync.when(
                                      data: (customer) => Text(
                                        customer?.name ?? l10n.soUnknownCustomer,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: scheme.onSurfaceVariant,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      loading: () => Text(
                                        l10n.soLoadingCustomer,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: scheme.onSurfaceVariant
                                              .withOpacity(0.6),
                                        ),
                                      ),
                                      error: (_, __) => Text(
                                        l10n.soUnknownCustomer,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: scheme.onSurfaceVariant
                                              .withOpacity(0.6),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat.yMMMd().format(p.paymentDate),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Row(
                                children: [
                                  _badge(
                                      context,
                                      paymentMethodLabel(l10n, p.method),
                                      scheme.primary),
                                  const SizedBox(width: 6),
                                  _badge(
                                      context,
                                      paymentRecordStatusLabel(l10n, p.status),
                                      _statusColor(p.status)),
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

  Color _statusColor(PaymentRecordStatus s) => switch (s) {
        PaymentRecordStatus.completed => Colors.green.shade700,
        PaymentRecordStatus.pending => Colors.amber.shade700,
        PaymentRecordStatus.failed => Colors.red.shade700,
        PaymentRecordStatus.refunded => Colors.blueGrey.shade600,
      };
}

class _Filters extends ConsumerWidget {
  const _Filters({required this.criteria});
  final SalePaymentListCriteria criteria;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final n = ref.read(salePaymentCriteriaProvider.notifier);
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
                avatar: Icon(Icons.filter_alt_off_rounded,
                    size: 14, color: scheme.error),
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
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                onPressed: n.reset,
              ),
            ),
          FilterPill<DatePreset>(
            label: l10n.soFilterDateLabel,
            isActive: criteria.datePreset != DatePreset.all,
            displayValue: _datePresetLabel(l10n, criteria.datePreset),
            onChanged: n.setDatePreset,
            onClear: () => n.setDatePreset(DatePreset.all),
            items: [
              PopupMenuItem(
                  value: DatePreset.all, child: Text(l10n.soDateAllDates)),
              PopupMenuItem(
                  value: DatePreset.today, child: Text(l10n.soDateToday)),
              PopupMenuItem(
                  value: DatePreset.week, child: Text(l10n.soDateWeek)),
              PopupMenuItem(
                  value: DatePreset.month, child: Text(l10n.soDateMonth)),
            ],
          ),
          const SizedBox(width: 8),
          FilterPill<PaymentMethod?>(
            label: l10n.spFilterMethodLabel,
            isActive: criteria.method != null,
            displayValue: criteria.method != null
                ? paymentMethodLabel(l10n, criteria.method!)
                : '',
            onChanged: n.setMethod,
            onClear: () => n.setMethod(null),
            items: [
              PopupMenuItem(value: null, child: Text(l10n.spMethodAny)),
              for (final m in PaymentMethod.values)
                PopupMenuItem(
                    value: m, child: Text(paymentMethodLabel(l10n, m))),
            ],
          ),
          const SizedBox(width: 8),
          FilterPill<PaymentRecordStatus?>(
            label: l10n.spFilterStatusLabel,
            isActive: criteria.status != null,
            displayValue: criteria.status != null
                ? paymentRecordStatusLabel(l10n, criteria.status!)
                : '',
            onChanged: n.setStatus,
            onClear: () => n.setStatus(null),
            items: [
              PopupMenuItem(value: null, child: Text(l10n.spStatusAny)),
              for (final s in PaymentRecordStatus.values)
                PopupMenuItem(
                    value: s, child: Text(paymentRecordStatusLabel(l10n, s))),
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
