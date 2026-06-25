import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../domain/product.dart';
import '../../stock_movement/presentation/product_history_view.dart';
import '../../stock_movement/presentation/record_movement_screen.dart';
import 'add_edit_product_screen.dart';
import 'product_providers.dart';

class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({super.key, required this.productId});
  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final product = ref.watch(productProvider(productId));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _edit(context, ref),
          ),
        ],
      ),
      body: AsyncValueView<Product?>(
        value: product,
        data: (p) {
          if (p == null) {
            return const Center(child: Text('Product not found.'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (p.imagePath != null)
                Image.file(File(p.imagePath!), height: 180, fit: BoxFit.cover),
              const SizedBox(height: 12),
              Text(p.name, style: Theme.of(context).textTheme.headlineSmall),
              if (p.description != null) Text(p.description!),
              const Divider(height: 32),
              _row('Current stock', '${p.currentStock}'),
              _row('Minimum stock', '${p.minimumStock}'),
              _row('Purchase price', p.purchasePrice.toStringAsFixed(2)),
              _row('Selling price', p.sellingPrice.toStringAsFixed(2)),
              if (p.barcode != null) _row('Barcode', p.barcode!),
              if (p.isLowStock)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text('⚠ Low stock',
                      style: TextStyle(color: Colors.deepOrange)),
                ),
              const SizedBox(height: 24),
              FilledButton.icon(
                icon: const Icon(Icons.swap_vert),
                label: const Text('Record stock movement'),
                onPressed: () async {
                  final recorded = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => RecordMovementScreen(
                          productId: p.id, productName: p.name),
                    ),
                  );
                  if (recorded == true) {
                    ref.invalidate(productProvider(productId));
                  }
                },
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.history),
                label: const Text('View stock history'),
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ProductHistoryView(productId: p.id),
                )),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(label), Text(value)],
        ),
      );

  Future<void> _edit(BuildContext context, WidgetRef ref) async {
    final current = await ref.read(productServiceProvider).get(productId);
    if (current == null || !context.mounted) return;
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
          builder: (_) => AddEditProductScreen(existing: current)),
    );
    if (saved == true) ref.invalidate(productProvider(productId));
  }
}
