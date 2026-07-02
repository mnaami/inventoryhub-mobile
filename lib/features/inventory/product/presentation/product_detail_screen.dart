import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/format/money_format.dart';
import '../../../../core/format/quantity_format.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../../core/widgets/stat_tile.dart';
import '../../../../core/widgets/status_badge.dart';
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
                            formatMoney(p.sellingPrice),
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

                // Stock Status Card
                _buildStockStatusCard(context, p),
                const SizedBox(height: AppTokens.space16),

                // Valuation Card
                _buildValuationCard(context, p),
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
                      _infoRow(context, 'Purchase Price', formatMoney(p.purchasePrice)),
                      const Divider(height: 1),
                      _infoRow(context, 'Selling Price', formatMoney(p.sellingPrice)),
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

  Widget _buildStockStatusCard(BuildContext context, Product p) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final hasMinStock = p.minimumStock > 0;
    double progress = 1.0;
    Color progressColor = Colors.green;

    if (p.currentStock <= 0) {
      progress = 0.0;
      progressColor = Colors.red;
    } else if (hasMinStock && p.currentStock <= p.minimumStock) {
      progress = p.currentStock / p.minimumStock;
      progressColor = Colors.orange;
    }

    Widget statusBadge;
    if (p.currentStock <= 0) {
      statusBadge = const StatusBadge.out();
    } else if (p.isLowStock) {
      statusBadge = const StatusBadge.low();
    } else {
      statusBadge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'HEALTHY',
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.green.shade800,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return AppCard(
      padding: const EdgeInsets.all(AppTokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.inventory_2_outlined, color: scheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Stock Level',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              statusBadge,
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Stock',
                    style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        formatQty(p.currentStock),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'pcs',
                        style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Min Required',
                    style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        formatQty(p.minimumStock),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'pcs',
                        style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          if (hasMinStock) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: scheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildValuationCard(BuildContext context, Product p) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final totalValue = p.currentStock * p.purchasePrice;

    return AppCard(
      padding: const EdgeInsets.all(AppTokens.space16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.analytics_rounded, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Inventory Valuation',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  formatMoney(totalValue),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Based on ${formatQty(p.currentStock)} pcs @ ${formatMoney(p.purchasePrice)} purchase price',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.attach_money_rounded,
              color: Colors.green,
              size: 24,
            ),
          ),
        ],
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
