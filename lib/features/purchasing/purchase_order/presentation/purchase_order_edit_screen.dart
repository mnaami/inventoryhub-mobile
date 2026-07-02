import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/format/money_format.dart';
import '../../../../core/result/app_exception.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../inventory/product/domain/product.dart';
import '../../../inventory/product/presentation/product_providers.dart';
import '../../supplier/domain/supplier.dart';
import '../../supplier/presentation/supplier_providers.dart';
import '../domain/purchase_order_usecases.dart';
import 'purchase_order_providers.dart';

class _DraftLine {
  _DraftLine(this.product, this.quantity);
  final Product product;
  double quantity;
}

class PurchaseOrderEditScreen extends ConsumerStatefulWidget {
  const PurchaseOrderEditScreen({super.key});
  @override
  ConsumerState<PurchaseOrderEditScreen> createState() =>
      _PurchaseOrderEditScreenState();
}

class _PurchaseOrderEditScreenState
    extends ConsumerState<PurchaseOrderEditScreen> {
  Supplier? _supplier;
  final List<_DraftLine> _lines = [];
  String? _error;

  double get _total =>
      _lines.fold(0, (a, l) => a + l.quantity * l.product.purchasePrice);

  Future<void> _pickSupplier() async {
    final suppliers = await ref.read(suppliersProvider.future);
    if (!mounted) return;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final chosen = await showModalBottomSheet<Supplier>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTokens.radiusLg)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                'Select Supplier',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            const Divider(),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final s in suppliers)
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                      title: Text(
                        s.name,
                        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      onTap: () => Navigator.pop(context, s),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    if (chosen != null) setState(() => _supplier = chosen);
  }

  Future<void> _addProduct() async {
    final products = await ref.read(productServiceProvider).list(page: 0);
    if (!mounted) return;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final chosen = await showModalBottomSheet<Product>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTokens.radiusLg)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                'Select Product',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            const Divider(),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final p in products)
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                      title: Text(
                        p.name,
                        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${formatMoney(p.purchasePrice)} each',
                        style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                      onTap: () => Navigator.pop(context, p),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    if (chosen != null) setState(() => _lines.add(_DraftLine(chosen, 1)));
  }

  Future<void> _save() async {
    setState(() => _error = null);
    if (_supplier == null) {
      setState(() => _error = 'Pick a supplier.');
      return;
    }
    try {
      final order = await ref.read(purchaseOrderServiceProvider).createDraft(
            supplierId: _supplier!.id,
            lines: _lines
                .map((l) => NewLine(
                      productId: l.product.id,
                      productName: l.product.name,
                      quantity: l.quantity,
                      unitPrice: l.product.purchasePrice,
                    ))
                .toList(),
          );
      ref.invalidate(purchaseOrdersProvider);
      if (mounted) Navigator.of(context).pop(order.id);
    } on AppException catch (e) {
      setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('New Purchase Order')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Supplier Picker Card
          AppCard(
            padding: const EdgeInsets.all(16),
            onTap: _pickSupplier,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: scheme.primary.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.local_shipping_outlined, color: scheme.primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Supplier',
                        style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _supplier?.name ?? 'Select supplier...',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: _supplier != null ? scheme.onSurface : scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
              ],
            ),
          ),
          const SizedBox(height: AppTokens.space24),

          // Lines List Header
          Text(
            'Order Items',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppTokens.space8),

          // Lines List
          if (_lines.isEmpty)
            AppCard(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'No products added yet.',
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                ),
              ),
            )
          else
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (int i = 0; i < _lines.length; i++) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _lines[i].product.name,
                                  style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${formatMoney(_lines[i].product.purchasePrice)} each',
                                  style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          SizedBox(
                            width: 90,
                            child: TextFormField(
                              initialValue: _lines[i].quantity.toString(),
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                labelText: 'Qty',
                                filled: true,
                                fillColor: scheme.surfaceContainerLow,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                              ),
                              onChanged: (v) => setState(
                                  () => _lines[i].quantity = double.tryParse(v) ?? _lines[i].quantity),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (i < _lines.length - 1)
                      const Divider(),
                  ],
                ],
              ),
            ),
          const SizedBox(height: AppTokens.space12),

          // Add Product Button
          OutlinedButton.icon(
            onPressed: _addProduct,
            icon: const Icon(Icons.add, size: 20),
            label: const Text('Add Product'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          const SizedBox(height: AppTokens.space24),

          // Total Summary Card
          AppCard(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Estimated Total',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  formatMoney(_total),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: scheme.primary,
                  ),
                ),
              ],
            ),
          ),

          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                _error!,
                style: TextStyle(color: scheme.error, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: AppTokens.space24),

          // Action Button
          FilledButton(
            onPressed: _save,
            child: const Text('Create draft'),
          ),
        ],
      ),
    );
  }
}
