import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/l10n/l10n_ext.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/filter_pill.dart';
import '../../../../core/widgets/paginated_list_view.dart';
import '../../../../core/widgets/search_field.dart';
import '../../../../l10n/app_localizations.dart';
import '../domain/sale_order.dart';
import '../domain/sale_order_enums.dart';
import '../../customer/presentation/customer_providers.dart';
import 'sale_order_detail_screen.dart';
import 'sale_order_providers.dart' show DatePreset;
import 'sale_shipment_providers.dart';

class SaleShipmentListScreen extends ConsumerStatefulWidget {
  const SaleShipmentListScreen({super.key});

  @override
  ConsumerState<SaleShipmentListScreen> createState() =>
      _SaleShipmentListScreenState();
}

class _SaleShipmentListScreenState
    extends ConsumerState<SaleShipmentListScreen> {
  bool _searching = false;

  SaleShipmentListNotifier get _notifier =>
      ref.read(saleShipmentListProvider.notifier);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(saleShipmentListProvider);
    final criteria = ref.watch(saleShipmentCriteriaProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: _searching
            ? SearchField(
                initial: criteria.search,
                hint: l10n.soSearchHint,
                onChanged: (v) => ref
                    .read(saleShipmentCriteriaProvider.notifier)
                    .setSearch(v),
              )
            : Text(l10n.shipLedgerTitle),
        actions: [
          if (criteria.hasActiveFilters)
            IconButton(
              tooltip: l10n.soClearAllFiltersTooltip,
              icon: const Icon(Icons.filter_alt_off),
              onPressed: () {
                ref.read(saleShipmentCriteriaProvider.notifier).reset();
                if (_searching) setState(() => _searching = false);
              },
            ),
          IconButton(
            icon: Icon(_searching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() => _searching = !_searching);
              if (!_searching) {
                ref.read(saleShipmentCriteriaProvider.notifier).setSearch('');
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
            child: PaginatedListView<SaleShipmentListItem>(
              state: state,
              onLoadMore: _notifier.loadMore,
              onRefresh: _notifier.refresh,
              onRetryInitial: _notifier.loadInitial,
              empty: EmptyState(
                icon: Icons.local_shipping_outlined,
                title: l10n.shipLedgerEmpty,
              ),
              itemBuilder: (context, s) => AppCard(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                onTap: () async {
                  await Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) =>
                          SaleOrderDetailScreen(orderId: s.saleOrderId)));
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
                      child: Icon(Icons.local_shipping,
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
                                s.soShippingNumber,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: scheme.onSurface,
                                ),
                              ),
                              _badge(context, shipmentStatusLabel(l10n, s.status),
                                  _statusColor(s.status)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                s.soNumber,
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
                                        ref.watch(customerProvider(s.customerId));
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
                                DateFormat.yMMMd().format(s.shippingDate),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (_carrierLine(s) != null)
                                Flexible(
                                  child: Text(
                                    _carrierLine(s)!,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.end,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
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

  /// "carrier • tracking", or whichever of the two is present, or null.
  String? _carrierLine(SaleShipmentListItem s) {
    final parts = <String>[
      if (s.carrier != null && s.carrier!.trim().isNotEmpty) s.carrier!.trim(),
      if (s.trackingNumber != null && s.trackingNumber!.trim().isNotEmpty)
        s.trackingNumber!.trim(),
    ];
    return parts.isEmpty ? null : parts.join(' • ');
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

  Color _statusColor(ShipmentStatus s) => switch (s) {
        ShipmentStatus.shipped => Colors.blue.shade700,
        ShipmentStatus.inTransit => Colors.amber.shade700,
        ShipmentStatus.delivered => Colors.green.shade700,
        ShipmentStatus.returned => Colors.red.shade700,
      };
}

class _Filters extends ConsumerWidget {
  const _Filters({required this.criteria});
  final SaleShipmentListCriteria criteria;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final n = ref.read(saleShipmentCriteriaProvider.notifier);
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
          FilterPill<ShipmentStatus?>(
            label: l10n.shipFilterStatusLabel,
            isActive: criteria.status != null,
            displayValue: criteria.status != null
                ? shipmentStatusLabel(l10n, criteria.status!)
                : '',
            onChanged: n.setStatus,
            onClear: () => n.setStatus(null),
            items: [
              PopupMenuItem(value: null, child: Text(l10n.shipStatusAny)),
              for (final st in ShipmentStatus.values)
                PopupMenuItem(
                    value: st, child: Text(shipmentStatusLabel(l10n, st))),
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
