import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/result/app_exception.dart';
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
    final chosen = await showModalBottomSheet<Customer>(
      context: context,
      builder: (_) => ListView(
        children: [
          for (final c in customers)
            ListTile(title: Text(c.name), onTap: () => Navigator.pop(context, c)),
        ],
      ),
    );
    if (chosen != null) setState(() => _customer = chosen);
  }

  Future<void> _addProduct() async {
    final products = await ref.read(productServiceProvider).list(0);
    if (!mounted) return;
    final chosen = await showModalBottomSheet<Product>(
      context: context,
      builder: (_) => ListView(
        children: [
          for (final p in products)
            ListTile(
                title: Text(p.name),
                subtitle: Text(p.sellingPrice.toStringAsFixed(2)),
                onTap: () => Navigator.pop(context, p)),
        ],
      ),
    );
    if (chosen != null) setState(() => _lines.add(_DraftLine(chosen, 1)));
  }

  Future<void> _save() async {
    setState(() => _error = null);
    if (_customer == null) {
      setState(() => _error = 'Pick a customer.');
      return;
    }
    try {
      await ref.read(saleOrderServiceProvider).createDraft(
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
      if (mounted) Navigator.of(context).pop(true);
    } on AppException catch (e) {
      setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Sale Order')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: Text(_customer?.name ?? 'Select customer'),
            leading: const Icon(Icons.person_outline),
            trailing: const Icon(Icons.chevron_right),
            onTap: _pickCustomer,
          ),
          const Divider(),
          for (final line in _lines)
            ListTile(
              title: Text(line.product.name),
              subtitle: Text(
                  '${line.product.sellingPrice.toStringAsFixed(2)} each'),
              trailing: SizedBox(
                width: 80,
                child: TextFormField(
                  initialValue: line.quantity.toString(),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Qty'),
                  onChanged: (v) => setState(
                      () => line.quantity = double.tryParse(v) ?? line.quantity),
                ),
              ),
            ),
          OutlinedButton.icon(
              onPressed: _addProduct,
              icon: const Icon(Icons.add),
              label: const Text('Add product')),
          const SizedBox(height: 16),
          Text('Total: ${_total.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleMedium),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(_error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          const SizedBox(height: 16),
          FilledButton(onPressed: _save, child: const Text('Create draft')),
        ],
      ),
    );
  }
}
