import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/result/app_exception.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../domain/sale_order.dart';
import '../domain/sale_order_usecases.dart';
import 'sale_order_providers.dart';

class CreateShipmentScreen extends ConsumerStatefulWidget {
  const CreateShipmentScreen({super.key, required this.order});
  final SaleOrder order;
  @override
  ConsumerState<CreateShipmentScreen> createState() => _CreateShipmentState();
}

class _CreateShipmentState extends ConsumerState<CreateShipmentScreen> {
  final Map<String, double> _qty = {}; // saleOrderItemId -> ship qty
  String? _error;

  Future<void> _save() async {
    setState(() => _error = null);
    final items = await ref.read(saleOrderItemsProvider(widget.order.id).future);
    final lines = <ShipLine>[];
    for (final item in items) {
      final q = _qty[item.id] ?? 0;
      if (q > 0) lines.add(ShipLine(item: item, quantity: q));
    }
    try {
      await ref
          .read(saleOrderServiceProvider)
          .createShipment(widget.order, lines: lines);
      if (mounted) Navigator.of(context).pop(true);
    } on AppException catch (e) {
      setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(saleOrderItemsProvider(widget.order.id));
    return Scaffold(
      appBar: AppBar(title: const Text('Create Shipment')),
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
                    decoration: const InputDecoration(labelText: 'Ship'),
                    onChanged: (v) =>
                        _qty[i.id] = double.tryParse(v) ?? 0,
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
            FilledButton(onPressed: _save, child: const Text('Ship')),
          ],
        ),
      ),
    );
  }
}
