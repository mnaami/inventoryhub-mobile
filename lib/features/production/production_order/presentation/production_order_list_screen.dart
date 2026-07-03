import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/l10n/l10n_ext.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/paginated_list_view.dart';
import '../../../../core/widgets/search_field.dart';
import '../domain/production_order.dart';
import '../domain/production_order_enums.dart';
import 'create_production_order_screen.dart';
import 'production_order_detail_screen.dart';
import 'production_order_providers.dart';

class ProductionOrderListScreen extends ConsumerStatefulWidget {
  const ProductionOrderListScreen({super.key});

  @override
  ConsumerState<ProductionOrderListScreen> createState() =>
      _ProductionOrderListScreenState();
}

class _ProductionOrderListScreenState
    extends ConsumerState<ProductionOrderListScreen> {
  bool _searching = false;

  ProductionOrderListNotifier get _notifier =>
      ref.read(productionOrderListProvider.notifier);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(productionOrderListProvider);
    final criteria = ref.watch(productionOrderCriteriaProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: _searching
            ? SearchField(
                initial: criteria.search,
                hint: 'Search order number',
                onChanged: (v) => ref
                    .read(productionOrderCriteriaProvider.notifier)
                    .setSearch(v),
              )
            : Text(l10n.productionOrdersListTitle),
        actions: [
          if (criteria.hasActiveFilters)
            IconButton(
              tooltip: 'Clear all filters',
              icon: const Icon(Icons.filter_alt_off),
              onPressed: () {
                ref.read(productionOrderCriteriaProvider.notifier).reset();
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
                ref.read(productionOrderCriteriaProvider.notifier).setSearch('');
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const CreateProductionOrderScreen()));
          if (mounted) await _notifier.refresh();
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          _Filters(criteria: criteria),
          const SizedBox(height: 8),
          Expanded(
            child: PaginatedListView<ProductionOrder>(
              state: state,
              onLoadMore: _notifier.loadMore,
              onRefresh: _notifier.refresh,
              onRetryInitial: _notifier.loadInitial,
              empty: EmptyState(
                icon: Icons.precision_manufacturing_outlined,
                title: l10n.productionOrdersEmpty,
              ),
              itemBuilder: (context, o) {
                final color = _statusColor(o.status);
                return AppCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  onTap: () async {
                    await Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) =>
                            ProductionOrderDetailScreen(orderId: o.id)));
                    if (mounted) await _notifier.refresh();
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.precision_manufacturing,
                            color: color, size: 24),
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
                            Text(
                              l10n.productionOrderListSubtitle(
                                  '${o.quantity}',
                                  productionStatusLabel(l10n, o.status)),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _badge(
                        context,
                        productionStatusLabel(l10n, o.status),
                        color,
                      ),
                    ],
                  ),
                );
              },
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

  Color _statusColor(ProductionOrderStatus s) => switch (s) {
        ProductionOrderStatus.planned => Colors.blue.shade700,
        ProductionOrderStatus.inProgress => Colors.indigo.shade600,
        ProductionOrderStatus.completed => Colors.green.shade700,
        ProductionOrderStatus.cancelled => Colors.red.shade700,
      };
}

class _Filters extends ConsumerWidget {
  const _Filters({required this.criteria});
  final ProductionOrderListCriteria criteria;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final n = ref.read(productionOrderCriteriaProvider.notifier);
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
                  'Clear All',
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
                onPressed: () {
                  ref.read(productionOrderCriteriaProvider.notifier).reset();
                },
              ),
            ),
          _FilterPill<ProductionOrderStatus?>(
            label: 'Status',
            isActive: criteria.status != null,
            displayValue: criteria.status != null
                ? productionStatusLabel(l10n, criteria.status!)
                : '',
            onChanged: n.setStatus,
            onClear: () => n.setStatus(null),
            items: [
              const PopupMenuItem(value: null, child: Text('Any Status')),
              for (final s in ProductionOrderStatus.values)
                PopupMenuItem(
                    value: s, child: Text(productionStatusLabel(l10n, s))),
            ],
          ),
        ],
      ),
    );
  }
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
                      color:
                          isActive ? scheme.primary : scheme.onSurfaceVariant,
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
