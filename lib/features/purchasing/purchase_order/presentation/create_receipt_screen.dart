import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/result/app_exception.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../app/theme/app_tokens.dart';
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Receive Goods (draft)')),
      body: AsyncValueView(
        value: items,
        data: (list) => ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // Header Context Card
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.archive_outlined, color: scheme.primary, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Receiving for order:',
                          style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.order.orderNumber,
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTokens.space24),

            // Section Header
            Text(
              'Select quantities to receive',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppTokens.space8),

            // Products list card
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (int i = 0; i < list.length; i++) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  list[i].productName,
                                  style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Remaining: ${list[i].remainingQuantity}',
                                  style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          SizedBox(
                            width: 90,
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                labelText: 'Receive',
                                filled: true,
                                fillColor: scheme.surfaceContainerLow,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                              ),
                              onChanged: (v) => _qty[list[i].id] = double.tryParse(v) ?? 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (i < list.length - 1)
                      const Divider(),
                  ],
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
              child: const Text('Save draft receipt'),
            ),
          ],
        ),
      ),
    );
  }
}
