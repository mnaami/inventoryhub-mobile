import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/paginated_list_view.dart';
import '../../../../core/widgets/search_field.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/app_card.dart';
import '../domain/supplier.dart';
import 'add_edit_supplier_screen.dart';
import 'supplier_detail_screen.dart';
import 'supplier_providers.dart';

class SupplierListScreen extends ConsumerStatefulWidget {
  const SupplierListScreen({super.key});

  @override
  ConsumerState<SupplierListScreen> createState() => _SupplierListScreenState();
}

class _SupplierListScreenState extends ConsumerState<SupplierListScreen> {
  bool _searching = false;

  SupplierListNotifier get _notifier => ref.read(supplierListProvider.notifier);

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(supplierListProvider);
    final criteria = ref.watch(supplierCriteriaProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: _searching
            ? SearchField(
                initial: criteria.search,
                hint: 'Search suppliers',
                onChanged: (v) =>
                    ref.read(supplierCriteriaProvider.notifier).setSearch(v),
              )
            : const Text('Suppliers'),
        actions: [
          if (criteria.hasActiveFilters)
            IconButton(
              tooltip: 'Clear all filters',
              icon: const Icon(Icons.filter_alt_off),
              onPressed: () {
                ref.read(supplierCriteriaProvider.notifier).reset();
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
                ref.read(supplierCriteriaProvider.notifier).setSearch('');
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () async {
          final added = await Navigator.of(context).push<bool>(MaterialPageRoute(
              builder: (_) => const AddEditSupplierScreen()));
          if (added == true && mounted) {
            _notifier.refresh();
          }
        },
        child: const Icon(Icons.add),
      ),
      body: PaginatedListView<Supplier>(
        state: state,
        onLoadMore: _notifier.loadMore,
        onRefresh: _notifier.refresh,
        onRetryInitial: _notifier.loadInitial,
        empty: const EmptyState(
          icon: Icons.local_shipping_outlined,
          title: 'No suppliers yet. Tap + to add one.',
        ),
        itemBuilder: (context, s) {
          final initial = s.name.isNotEmpty ? s.name[0].toUpperCase() : '?';
          final subtitle = s.contactPerson != null
              ? s.contactPerson
              : (s.email != null && s.email!.isNotEmpty ? s.email : null);

          return AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            onTap: () async {
              await Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => SupplierDetailScreen(supplierId: s.id)));
              if (mounted) _notifier.refresh();
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
                  alignment: Alignment.center,
                  child: Text(
                    initial,
                    style: TextStyle(
                      color: scheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: scheme.onSurfaceVariant.withOpacity(0.5),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
