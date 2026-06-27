import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/result/app_exception.dart';
import 'production_order_providers.dart';

class CreateProductionOrderScreen extends ConsumerStatefulWidget {
  const CreateProductionOrderScreen({super.key});

  @override
  ConsumerState<CreateProductionOrderScreen> createState() =>
      _CreateProductionOrderScreenState();
}

class _CreateProductionOrderScreenState
    extends ConsumerState<CreateProductionOrderScreen> {
  final _qty = TextEditingController(text: '1');
  String? _productId;

  @override
  void dispose() {
    _qty.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(allProductsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('New production order')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            products.when(
              data: (list) => DropdownButtonFormField<String>(
                initialValue: _productId,
                decoration:
                    const InputDecoration(labelText: 'Output product'),
                items: [
                  for (final p in list)
                    DropdownMenuItem(value: p.id, child: Text(p.name))
                ],
                onChanged: (v) => setState(() => _productId = v),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('$e'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _qty,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Quantity'),
            ),
            const Spacer(),
            FilledButton(onPressed: _save, child: const Text('Create')),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final productId = _productId;
    final qty = double.tryParse(_qty.text.trim());
    if (productId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Choose an output product.')));
      return;
    }
    if (qty == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter a valid quantity.')));
      return;
    }
    try {
      await ref
          .read(productionOrderServiceProvider)
          .createPlanned(productId: productId, quantity: qty);
      ref.invalidate(productionOrdersProvider);
      ref.invalidate(productionDashboardProvider);
      if (mounted) Navigator.of(context).pop();
    } on AppException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }
}
