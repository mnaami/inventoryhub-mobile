import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/paginated_list_view.dart';
import '../../../../core/widgets/search_field.dart';
import '../domain/customer.dart';
import 'add_edit_customer_screen.dart';
import 'customer_detail_screen.dart';
import 'customer_providers.dart';

class CustomerListScreen extends ConsumerStatefulWidget {
  const CustomerListScreen({super.key});

  @override
  ConsumerState<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends ConsumerState<CustomerListScreen> {
  bool _searching = false;

  CustomerListNotifier get _notifier =>
      ref.read(customerListProvider.notifier);

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerListProvider);
    final criteria = ref.watch(customerCriteriaProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: _searching
            ? SearchField(
                initial: criteria.search,
                hint: 'Search customer name or email',
                onChanged: (v) =>
                    ref.read(customerCriteriaProvider.notifier).setSearch(v),
              )
            : const Text('Customers'),
        actions: [
          if (criteria.hasActiveFilters)
            IconButton(
              tooltip: 'Clear all filters',
              icon: const Icon(Icons.filter_alt_off),
              onPressed: () {
                ref.read(customerCriteriaProvider.notifier).reset();
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
                ref.read(customerCriteriaProvider.notifier).setSearch('');
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () async {
          final added = await Navigator.of(context).push<bool>(
              MaterialPageRoute(builder: (_) => const AddEditCustomerScreen()));
          if (added == true && mounted) {
            await _notifier.refresh();
          }
        },
        child: const Icon(Icons.add),
      ),
      body: PaginatedListView<Customer>(
        state: state,
        onLoadMore: _notifier.loadMore,
        onRefresh: _notifier.refresh,
        onRetryInitial: _notifier.loadInitial,
        empty: const EmptyState(
          icon: Icons.people_outline,
          title: 'No customers yet. Tap + to add one.',
        ),
        itemBuilder: (context, c) {
          final initial = c.name.isNotEmpty ? c.name[0].toUpperCase() : '?';
          return AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            onTap: () async {
              await Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => CustomerDetailScreen(customerId: c.id)));
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
                        c.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface,
                        ),
                      ),
                      if (c.email != null && c.email!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          c.email!,
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
