import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../core/result/app_exception.dart';
import '../../../../core/widgets/section_header.dart';
import '../../product/presentation/product_providers.dart';
import '../domain/stock_movement.dart';
import 'stock_providers.dart';

class RecordMovementScreen extends ConsumerStatefulWidget {
  const RecordMovementScreen({
    super.key,
    required this.productId,
    required this.productName,
  });
  final String productId;
  final String productName;

  @override
  ConsumerState<RecordMovementScreen> createState() => _State();
}

class _State extends ConsumerState<RecordMovementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _qty = TextEditingController();
  final _notes = TextEditingController();
  MovementType _type = MovementType.inbound;

  @override
  void dispose() {
    _qty.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Stock — ${widget.productName}')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppTokens.space16),
          children: [
            const SectionHeader('Movement type'),
            SegmentedButton<MovementType>(
              segments: const [
                ButtonSegment(value: MovementType.inbound, label: Text('In')),
                ButtonSegment(value: MovementType.outbound, label: Text('Out')),
                ButtonSegment(
                    value: MovementType.adjustment, label: Text('Adjust')),
              ],
              selected: {_type},
              onSelectionChanged: (s) => setState(() => _type = s.first),
            ),
            const SizedBox(height: AppTokens.space24),
            const SectionHeader('Details'),
            TextFormField(
              controller: _qty,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true, signed: true),
              decoration: InputDecoration(
                labelText: _type == MovementType.adjustment
                    ? 'Quantity (use − to reduce)'
                    : 'Quantity',
                prefixIcon: const Icon(Icons.numbers),
              ),
              validator: (v) {
                final n = double.tryParse(v ?? '');
                if (n == null) return 'Enter a number';
                if (n == 0) return 'Quantity must not be zero';
                return null;
              },
            ),
            const SizedBox(height: AppTokens.space12),
            TextFormField(
              controller: _notes,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                prefixIcon: Icon(Icons.notes),
              ),
            ),
            const SizedBox(height: AppTokens.space24),
            FilledButton(onPressed: _save, child: const Text('Record')),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await ref.read(stockServiceProvider).record(
            productId: widget.productId,
            type: _type,
            quantity: double.parse(_qty.text),
            notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
          );
      ref.invalidate(productProvider(widget.productId));
      ref.invalidate(productHistoryProvider(widget.productId));
      ref.invalidate(lowStockProductsProvider);
      ref.invalidate(stockLedgerProvider);
      ref.read(productListProvider.notifier).refresh();
      if (mounted) Navigator.of(context).pop(true);
    } on AppException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }
}
