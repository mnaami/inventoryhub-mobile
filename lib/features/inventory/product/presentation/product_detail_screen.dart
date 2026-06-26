import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../../core/widgets/section_header.dart';
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
            padding: const EdgeInsets.all(AppTokens.space16),
            children: [
              // Header card: image or icon + name + price
              AppCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(AppTokens.radiusSm),
                      child: p.imagePath != null
                          ? Image.file(
                              File(p.imagePath!),
                              width: 72,
                              height: 72,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 72,
                              height: 72,
                              color: scheme.primaryContainer,
                              child: Icon(
                                Icons.inventory_2_outlined,
                                size: 36,
                                color: scheme.onPrimaryContainer,
                              ),
                            ),
                    ),
                    const SizedBox(width: AppTokens.space16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.name,
                              style: theme.textTheme.titleLarge,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: AppTokens.space4),
                          Text(
                            p.sellingPrice.toStringAsFixed(2),
                            style: theme.textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurfaceVariant),
                          ),
                          if (p.description != null) ...[
                            const SizedBox(height: AppTokens.space4),
                            Text(
                              p.description!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTokens.space16),

              // Stats row
              const SectionHeader('Stock'),
              Row(
                children: [
                  Expanded(
                    child: StatTile(
                      label: 'Stock',
                      value: _fmtQty(p.currentStock),
                    ),
                  ),
                  const SizedBox(width: AppTokens.space12),
                  Expanded(
                    child: StatTile(
                      label: 'Minimum',
                      value: _fmtQty(p.minimumStock),
                    ),
                  ),
                  const SizedBox(width: AppTokens.space12),
                  Expanded(
                    child: StatTile(
                      label: 'Value',
                      value: (p.currentStock * p.purchasePrice)
                          .toStringAsFixed(2),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppTokens.space16),

              // Additional info
              const SectionHeader('Pricing'),
              AppCard(
                child: Column(
                  children: [
                    _infoRow(context, 'Purchase price',
                        p.purchasePrice.toStringAsFixed(2)),
                    _divider(context),
                    _infoRow(context, 'Selling price',
                        p.sellingPrice.toStringAsFixed(2)),
                    if (p.barcode != null) ...[
                      _divider(context),
                      _infoRow(context, 'Barcode', p.barcode!),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: AppTokens.space24),

              // Actions
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
              const SizedBox(height: AppTokens.space8),
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

  String _fmtQty(double v) =>
      v.toStringAsFixed(v == v.roundToDouble() ? 0 : 1);

  Widget _infoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTokens.space8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          Text(value, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _divider(BuildContext context) => Divider(
        height: 1,
        color: Theme.of(context).colorScheme.outlineVariant,
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
