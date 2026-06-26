import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/result/app_exception.dart';
import '../domain/sale_order.dart';
import '../domain/sale_order_enums.dart';
import 'sale_order_providers.dart';

class RecordPaymentScreen extends ConsumerStatefulWidget {
  const RecordPaymentScreen({super.key, required this.order});
  final SaleOrder order;
  @override
  ConsumerState<RecordPaymentScreen> createState() => _RecordPaymentState();
}

class _RecordPaymentState extends ConsumerState<RecordPaymentScreen> {
  final _amount = TextEditingController();
  PaymentMethod _method = PaymentMethod.cash;
  String? _error;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _error = null);
    final amount = double.tryParse(_amount.text.trim());
    if (amount == null) {
      setState(() => _error = 'Enter a valid amount.');
      return;
    }
    try {
      await ref
          .read(saleOrderServiceProvider)
          .addPayment(widget.order, amount: amount, method: _method);
      if (mounted) Navigator.of(context).pop(true);
    } on AppException catch (e) {
      setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Record Payment')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
              controller: _amount,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount')),
          const SizedBox(height: 12),
          DropdownButtonFormField<PaymentMethod>(
            initialValue: _method,
            decoration: const InputDecoration(labelText: 'Method'),
            items: [
              for (final m in PaymentMethod.values)
                DropdownMenuItem(value: m, child: Text(m.wire)),
            ],
            onChanged: (m) => setState(() => _method = m ?? _method),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(_error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          const SizedBox(height: 16),
          FilledButton(onPressed: _save, child: const Text('Save payment')),
        ],
      ),
    );
  }
}
