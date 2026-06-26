import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/result/app_exception.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../domain/purchase_order.dart';
import '../domain/purchase_order_usecases.dart';
import 'purchase_order_providers.dart';

class CreateReceiptScreen extends ConsumerStatefulWidget {
  const CreateReceiptScreen({super.key, required this.order});
  final PurchaseOrder order;
  @override
  ConsumerState<CreateReceiptScreen> createState() => _CreateReceiptState();
}

class _CreateReceiptState extends ConsumerState<CreateReceiptScreen> {
  final Map<String, double> _qty = {}; // purchaseOrderItemId -> receive qty
  String? _error;

  Future<void> _save() async {
    setState(() => _error = null);
    final items =
        await ref.read(purchaseOrderItemsProvider(widget.order.id).future);
    final lines = <ReceiveLine>[];
    for (final item in items) {
      final q = _qty[item.id] ?? 0;
      if (q > 0) lines.add(ReceiveLine(item: item, quantity: q));
    }
    try {
      await ref
          .read(purchaseOrderServiceProvider)
          .createReceipt(widget.order, lines: lines);
      if (mounted) Navigator.of(context).pop(true);
    } on AppException catch (e) {
      setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(purchaseOrderItemsProvider(widget.order.id));
    return Scaffold(
      appBar: AppBar(title: const Text('Receive Goods (draft)')),
      body: AsyncValueView(
        value: items,
        data: (list) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            for (final i in list)
              ListTile(
                title: Text(i.productName),
                subtitle: Text('Remaining ${i.remainingQuantity}'),
                trailing: SizedBox(
                  width: 80,
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Receive'),
                    onChanged: (v) => _qty[i.id] = double.tryParse(v) ?? 0,
                  ),
                ),
              ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_error!,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
            const SizedBox(height: 16),
            FilledButton(
                onPressed: _save, child: const Text('Save draft receipt')),
          ],
        ),
      ),
    );
  }
}
