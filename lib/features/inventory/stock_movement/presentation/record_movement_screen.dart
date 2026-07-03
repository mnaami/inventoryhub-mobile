import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../core/result/app_exception.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/l10n/l10n_ext.dart';
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
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
          title: Text(l10n.stockMovementScreenTitle(widget.productName))),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // Movement Type Card
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.stockMovementTypeHeading,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<MovementType>(
                      showSelectedIcon: false,
                      segments: [
                        ButtonSegment(
                            value: MovementType.inbound,
                            label: Text(l10n.stockMovementTypeIn)),
                        ButtonSegment(
                            value: MovementType.outbound,
                            label: Text(l10n.stockMovementTypeOut)),
                        ButtonSegment(
                            value: MovementType.adjustment,
                            label: Text(l10n.stockMovementTypeAdjust)),
                      ],
                      selected: {_type},
                      onSelectionChanged: (s) => setState(() => _type = s.first),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTokens.space16),

            // Form Inputs Card
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.stockMovementDetailsHeading,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _qty,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true, signed: true),
                    decoration: InputDecoration(
                      labelText: _type == MovementType.adjustment
                          ? l10n.stockMovementQuantityAdjustLabel
                          : l10n.stockMovementQuantityLabel,
                      prefixIcon: const Icon(Icons.numbers_outlined),
                    ),
                    validator: (v) {
                      final n = double.tryParse(v ?? '');
                      if (n == null) return l10n.stockMovementQuantityInvalid;
                      if (n == 0) return l10n.stockMovementQuantityZero;
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notes,
                    decoration: InputDecoration(
                      labelText: l10n.stockMovementNotesLabel,
                      prefixIcon: const Icon(Icons.notes_outlined),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTokens.space24),

            // Record action button
            FilledButton(
              onPressed: _save,
              child: Text(l10n.stockMovementRecordButton),
            ),
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
