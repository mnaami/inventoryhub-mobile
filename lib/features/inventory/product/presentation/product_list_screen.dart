import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../app/theme/app_tokens.dart';
import '../domain/product.dart';
import 'add_edit_product_screen.dart';
import 'product_detail_screen.dart';
import 'product_providers.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});
  @override
  ConsumerState<ProductListScreen> createState() => _State();
}

class _State extends ConsumerState<ProductListScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels >=
          _scroll.position.maxScrollExtent - 200) {
        ref.read(productListProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _add(context),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search name or barcode',
              ),
              onChanged: (q) =>
                  ref.read(productListProvider.notifier).search(q),
            ),
          ),
          Expanded(
            child: AsyncValueView<List<Product>>(
              value: products,
              data: (list) => list.isEmpty
                  ? EmptyState(
                      icon: Icons.inventory_2_outlined,
                      title: 'No products yet',
                      subtitle:
                          'Add your first product to start tracking stock.',
                      actionLabel: 'Add product',
                      onAction: () => _add(context),
                    )
                  : ListView.separated(
                      controller: _scroll,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: list.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppTokens.space8),
                      itemBuilder: (_, i) => _tile(context, list[i]),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, Product p) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
            p.currentStock.toStringAsFixed(
                p.currentStock == p.currentStock.roundToDouble() ? 0 : 1),
            style: textTheme.titleMedium,
          ),
          Text(
            'pcs',
            style: textTheme.bodySmall
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      );
    }

    return AppCard(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ProductDetailScreen(productId: p.id),
      )),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(AppTokens.radiusSm),
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              color: scheme.onPrimaryContainer,
              size: 22,
            ),
          ),
          const SizedBox(width: AppTokens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.name,
                  style: textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppTokens.space2),
                Text(
                  p.sellingPrice.toStringAsFixed(2),
                  style: textTheme.bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppTokens.space12),
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
