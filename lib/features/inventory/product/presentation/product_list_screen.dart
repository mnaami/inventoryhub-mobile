import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/async_value_view.dart';
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
            padding: const EdgeInsets.all(12),
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
                  ? const Center(child: Text('No products yet. Tap + to add one.'))
                  : ListView.builder(
                      controller: _scroll,
                      itemCount: list.length,
                      itemBuilder: (_, i) => _tile(context, list[i]),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, Product p) {
    return ListTile(
      title: Text(p.name),
      subtitle: Text('Stock: ${p.currentStock}'),
      trailing: p.isLowStock
          ? const Chip(
              label: Text('Low'),
              backgroundColor: Color(0xFFFFE0B2),
              visualDensity: VisualDensity.compact,
            )
          : null,
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ProductDetailScreen(productId: p.id),
      )),
    );
  }

  Future<void> _add(BuildContext context) async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AddEditProductScreen()),
    );
    if (created == true) ref.read(productListProvider.notifier).refresh();
  }
}
