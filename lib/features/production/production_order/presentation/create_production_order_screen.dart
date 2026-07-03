import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/l10n/l10n_ext.dart';
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
    final l10n = context.l10n;
    final products = ref.watch(allProductsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.productionOrderCreateTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            products.when(
              data: (list) => DropdownButtonFormField<String>(
                initialValue: _productId,
                decoration:
                    InputDecoration(labelText: l10n.productionOutputProductLabel),
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
              decoration: InputDecoration(labelText: l10n.productionQuantityLabel),
            ),
            const Spacer(),
            FilledButton(
                onPressed: _save, child: Text(l10n.productionCreateButton)),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final productId = _productId;
    final qty = double.tryParse(_qty.text.trim());
    if (productId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.productionChooseOutputProductError)));
      return;
    }
    if (qty == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.productionEnterValidQuantityError)));
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
