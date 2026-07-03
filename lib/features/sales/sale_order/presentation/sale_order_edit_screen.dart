import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventoryhub_mobile/app/currency/currency_controller.dart';
import '../../../../core/l10n/l10n_ext.dart';
import '../../../../core/result/app_exception.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../inventory/product/domain/product.dart';
import '../../../inventory/product/presentation/product_providers.dart';
import '../../customer/domain/customer.dart';
import '../../customer/presentation/customer_providers.dart';
import '../domain/sale_order_usecases.dart';
import 'sale_order_providers.dart';

class _DraftLine {
  _DraftLine(this.product, this.quantity);
  final Product product;
  double quantity;
}

class SaleOrderEditScreen extends ConsumerStatefulWidget {
  const SaleOrderEditScreen({super.key});
  @override
  ConsumerState<SaleOrderEditScreen> createState() =>
      _SaleOrderEditScreenState();
}

class _SaleOrderEditScreenState extends ConsumerState<SaleOrderEditScreen> {
  Customer? _customer;
  final List<_DraftLine> _lines = [];
  String? _error;

  double get _total =>
      _lines.fold(0, (a, l) => a + l.quantity * l.product.sellingPrice);

  Future<void> _pickCustomer() async {
    final customers = await ref.read(customersProvider.future);
    if (!mounted) return;
    final l10n = context.l10n;
    final chosen = await showModalBottomSheet<Customer>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                l10n.soSelectCustomerTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            for (final c in customers)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
                ),
                title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                onTap: () => Navigator.pop(context, c),
              ),
          ],
        ),
      ),
    );
    if (chosen != null) setState(() => _customer = chosen);
  }

  Future<void> _addProduct() async {
    final money = ref.watch(moneyFormatterProvider);
    final products = await ref.read(productServiceProvider).list(page: 0);
    if (!mounted) return;
    final l10n = context.l10n;
    final chosen = await showModalBottomSheet<Product>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                l10n.poAddProductButton,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            for (final p in products)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(money(p.sellingPrice)),
                trailing: const Icon(Icons.add_circle_outline),
                onTap: () => Navigator.pop(context, p),
              ),
          ],
        ),
      ),
    );
    if (chosen != null) setState(() => _lines.add(_DraftLine(chosen, 1)));
  }

  Future<void> _save() async {
    setState(() => _error = null);
    if (_customer == null) {
      setState(() => _error = context.l10n.soPickCustomerError);
      return;
    }
    try {
      final order = await ref.read(saleOrderServiceProvider).createDraft(
            customerId: _customer!.id,
            lines: _lines
                .map((l) => NewLine(
                      productId: l.product.id,
                      productName: l.product.name,
                      quantity: l.quantity,
                      unitPrice: l.product.sellingPrice,
                    ))
                .toList(),
          );
      ref.invalidate(saleOrdersProvider);
      if (mounted) Navigator.of(context).pop(order.id);
    } on AppException catch (e) {
      setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final money = ref.watch(moneyFormatterProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.soCreateTitle)),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Customer Select Card
          AppCard(
            onTap: _pickCustomer,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: scheme.primary.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person_outline, color: scheme.primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.soCustomerLabel,
                        style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _customer?.name ?? l10n.soSelectCustomerPlaceholder,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: _customer != null ? scheme.onSurface : scheme.onSurfaceVariant,
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
            l10n.poOrderItemsHeading,
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
                    l10n.poNoProductsAdded,
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
                                  l10n.poPriceEach(money(_lines[i].product.sellingPrice)),
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
                                labelText: l10n.poQtyLabel,
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
            label: Text(l10n.poAddProductButton),
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
                  l10n.poEstimatedTotal,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  money(_total),
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
            child: Text(l10n.poCreateDraftButton),
          ),
        ],
      ),
    );
  }
}
