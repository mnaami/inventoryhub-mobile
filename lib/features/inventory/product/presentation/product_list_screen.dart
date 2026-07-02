import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/format/money_format.dart';
import '../../../../core/format/quantity_format.dart';
import '../../../../core/paging/paged_state.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/widgets/search_field.dart';
import '../../../../core/widgets/paginated_list_view.dart';
import '../../category/domain/category.dart';
import '../../category/presentation/category_providers.dart';
import '../domain/product.dart';
import 'add_edit_product_screen.dart';
import 'product_detail_screen.dart';
import 'product_providers.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({
    super.key,
    this.initialLowStock = false,
    this.initialOutOfStock = false,
  });

  final bool initialLowStock;
  final bool initialOutOfStock;

  @override
  ConsumerState<ProductListScreen> createState() => _State();
}

class _State extends ConsumerState<ProductListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialLowStock) {
        ref.read(productCriteriaProvider.notifier).set(const ProductCriteria(lowStock: true));
      } else if (widget.initialOutOfStock) {
        ref.read(productCriteriaProvider.notifier).set(const ProductCriteria(outOfStock: true));
      }
    });
  }

  ProductListNotifier get _notifier => ref.read(productListProvider.notifier);

  @override
  Widget build(BuildContext context) {
    ref.listen(productSearchQueryProvider, (_, q) {
      ref.read(productCriteriaProvider.notifier).update((c) => c.copyWith(searchQuery: q));
    });

    final state = ref.watch(productListProvider);
    final criteria = ref.watch(productCriteriaProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all_rounded),
            onPressed: () {
              ref.read(productCriteriaProvider.notifier).set(const ProductCriteria());
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () => _add(context),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Debounced Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: SearchField(
              hint: 'Search product name or barcode',
              onChanged: (q) {
                ref.read(productSearchQueryProvider.notifier).set(q);
              },
            ),
          ),

          // Horizontal Filter Pills
          _buildFilters(context, ref, criteria),
          const SizedBox(height: 8),

          // Paginated List View
          Expanded(
            child: PaginatedListView<Product>(
              state: state,
              onLoadMore: _notifier.loadMore,
              onRefresh: _notifier.refresh,
              onRetryInitial: _notifier.loadInitial,
              itemBuilder: (context, p) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: _tile(context, p),
              ),
              empty: const EmptyState(
                icon: Icons.inventory_2_outlined,
                title: 'No products yet',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context, WidgetRef ref, ProductCriteria criteria) {
    final categoriesAsync = ref.watch(activeCategoriesProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Low Stock Pill
          _FilterPill<bool?>(
            label: 'Low Stock',
            isActive: criteria.lowStock != null,
            displayValue: 'Low Stock Only',
            onChanged: (val) {
              ref.read(productCriteriaProvider.notifier).update((c) => c.copyWith(
                lowStock: () => val,
                outOfStock: () => null,
              ));
            },
            onClear: () {
              ref.read(productCriteriaProvider.notifier).update((c) => c.copyWith(lowStock: () => null));
            },
            items: const [
              PopupMenuItem(value: null, child: Text('All')),
              PopupMenuItem(value: true, child: Text('Low Stock Only')),
            ],
          ),
          const SizedBox(width: 8),

          // Out of Stock Pill
          _FilterPill<bool?>(
            label: 'Out of Stock',
            isActive: criteria.outOfStock != null,
            displayValue: 'Out of Stock Only',
            onChanged: (val) {
              ref.read(productCriteriaProvider.notifier).update((c) => c.copyWith(
                outOfStock: () => val,
                lowStock: () => null,
              ));
            },
            onClear: () {
              ref.read(productCriteriaProvider.notifier).update((c) => c.copyWith(outOfStock: () => null));
            },
            items: const [
              PopupMenuItem(value: null, child: Text('All')),
              PopupMenuItem(value: true, child: Text('Out of Stock Only')),
            ],
          ),
          const SizedBox(width: 8),

          // Category Pill
          categoriesAsync.maybeWhen(
            data: (categories) => _FilterPill<String?>(
              label: 'Category',
              isActive: criteria.categoryId != null,
              displayValue: criteria.categoryId != null
                  ? categories.firstWhere((c) => c.id == criteria.categoryId, orElse: () => categories.first).name
                  : '',
              onChanged: (val) {
                ref.read(productCriteriaProvider.notifier).update((c) => c.copyWith(categoryId: () => val));
              },
              onClear: () {
                ref.read(productCriteriaProvider.notifier).update((c) => c.copyWith(categoryId: () => null));
              },
              items: [
                const PopupMenuItem(value: null, child: Text('All Categories')),
                ...categories.map((c) => PopupMenuItem(value: c.id, child: Text(c.name))),
              ],
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, Product p) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    Widget trailing;
    if (p.currentStock <= 0) {
      trailing = const StatusBadge.out();
    } else if (p.isLowStock) {
      trailing = const StatusBadge.low();
    } else {
      trailing = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            formatQty(p.currentStock),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          Text(
            'pcs',
            style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      );
    }

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ProductDetailScreen(productId: p.id),
      )),
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
            child: Icon(
              Icons.inventory_2_outlined,
              color: scheme.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  formatMoney(p.sellingPrice),
                  style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          trailing,
        ],
      ),
    );
  }

  Future<void> _add(BuildContext context) async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AddEditProductScreen()),
    );
    if (created == true) ref.read(productListProvider.notifier).refresh();
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
