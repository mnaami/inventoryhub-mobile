import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/format/quantity_format.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../../core/widgets/stat_tile.dart';
import '../../../../app/theme/app_tokens.dart';
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
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
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(productProvider(productId));
              await ref.read(productProvider(productId).future);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                // Header Card: Product thumbnail + Name + Description + Primary selling price
                AppCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: p.imagePath != null
                            ? Image.file(
                                File(p.imagePath!),
                                width: 88,
                                height: 88,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 88,
                                height: 88,
                                color: scheme.primary.withOpacity(0.08),
                                child: Icon(
                                  Icons.inventory_2_outlined,
                                  size: 40,
                                  color: scheme.primary,
                                ),
                              ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        p.name,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (p.description != null && p.description!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          p.description!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Selling Price',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '\$${p.sellingPrice.toStringAsFixed(2)}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: scheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTokens.space16),

                // Stats Dashboard Row
                Row(
                  children: [
                    Expanded(
                      child: StatTile(
                        label: 'Stock',
                        value: formatQty(p.currentStock),
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: scheme.primary.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.inventory_2_outlined, color: scheme.primary, size: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTokens.space12),
                    Expanded(
                      child: StatTile(
                        label: 'Minimum',
                        value: formatQty(p.minimumStock),
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTokens.space12),
                    Expanded(
                      child: StatTile(
                        label: 'Value',
                        value: '\$${(p.currentStock * p.purchasePrice).toStringAsFixed(2)}',
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.attach_money_rounded, color: Colors.green, size: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTokens.space24),

                // Details & Identification Info Card
                Text(
                  'Pricing & Details',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppTokens.space8),
                AppCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Column(
                    children: [
                      _infoRow(context, 'Purchase Price', '\$${p.purchasePrice.toStringAsFixed(2)}'),
                      const Divider(height: 1),
                      _infoRow(context, 'Selling Price', '\$${p.sellingPrice.toStringAsFixed(2)}'),
                      if (p.barcode != null && p.barcode!.isNotEmpty) ...[
                        const Divider(height: 1),
                        _infoRow(context, 'Barcode', p.barcode!),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppTokens.space24),

                // Actions Container at bottom
                FilledButton.icon(
                  icon: const Icon(Icons.swap_vert_rounded),
                  label: const Text('Record stock movement'),
                  onPressed: () async {
                    final recorded = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) => RecordMovementScreen(
                          productId: p.id,
                          productName: p.name,
                        ),
                      ),
                    );
                    if (recorded == true) {
                      ref.invalidate(productProvider(productId));
                    }
                  },
                ),
                const SizedBox(height: AppTokens.space8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.history_rounded),
                  label: const Text('View stock history'),
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => ProductHistoryView(productId: p.id),
                  )),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _edit(BuildContext context, WidgetRef ref) async {
    final current = await ref.read(productServiceProvider).get(productId);
    if (current == null || !context.mounted) return;
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddEditProductScreen(existing: current),
      ),
    );
    if (saved == true) ref.invalidate(productProvider(productId));
  }
}
