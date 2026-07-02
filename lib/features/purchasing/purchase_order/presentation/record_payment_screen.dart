import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/format/money_format.dart';
import '../../../../core/result/app_exception.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../app/theme/app_tokens.dart';
import '../domain/purchase_order.dart';
import '../domain/purchase_order_enums.dart';
import 'purchase_order_providers.dart';

class RecordPaymentScreen extends ConsumerStatefulWidget {
  const RecordPaymentScreen({super.key, required this.order});
  final PurchaseOrder order;
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
          .read(purchaseOrderServiceProvider)
          .addPayment(widget.order, amount: amount, method: _method);
      if (mounted) Navigator.of(context).pop(true);
    } on AppException catch (e) {
      setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Record Payment (draft)')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Subtitle context card
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.payment_rounded, color: scheme.primary, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recording payment for:',
                        style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${widget.order.orderNumber} · Order Total: ${formatMoney(widget.order.totalAmount)}',
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTokens.space24),

          // Input Form Card
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment Information',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _amount,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<PaymentMethod>(
                  value: _method,
                  decoration: const InputDecoration(labelText: 'Method'),
                  items: [
                    for (final m in PaymentMethod.values)
                      DropdownMenuItem(
                        value: m,
                        child: Text(m.wire),
                      ),
                  ],
                  onChanged: (m) => setState(() => _method = m ?? _method),
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
            child: const Text('Save draft payment'),
          ),
        ],
      ),
    );
  }
}
