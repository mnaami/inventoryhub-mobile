import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/l10n/l10n_ext.dart';
import '../../../core/result/app_exception.dart';
import '../../../core/widgets/empty_state.dart';
import '../../employees/employee/presentation/employee_detail_providers.dart';
import '../../employees/employee/presentation/employee_providers.dart';
import '../../inventory/product/domain/product.dart';
import '../../inventory/product/presentation/product_providers.dart';

/// Lists every product with its current default (non-employee) piece rate,
/// each editable inline. Saving calls `setDefaultRate`, the same rate the
/// order-completion flow falls back to when an order has no per-employee
/// override (see `ProductionPayRateService.resolveRate`).
class PieceRatesScreen extends ConsumerWidget {
  const PieceRatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(productListProvider);

    if (state.isLoadingInitial) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.pieceRatesTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (state.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.pieceRatesTitle)),
        body: EmptyState(
          icon: Icons.payments_outlined,
          title: l10n.pieceRatesEmpty,
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(l10n.pieceRatesTitle)),
      body: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: state.items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) => _PieceRateTile(product: state.items[i]),
      ),
    );
  }
}

class _PieceRateTile extends ConsumerStatefulWidget {
  const _PieceRateTile({required this.product});
  final Product product;

  @override
  ConsumerState<_PieceRateTile> createState() => _PieceRateTileState();
}

class _PieceRateTileState extends ConsumerState<_PieceRateTile> {
  final _rate = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _rate.dispose();
    super.dispose();
  }

  String _formatRate(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  Future<void> _save() async {
    final l10n = context.l10n;
    final rate = double.tryParse(_rate.text.trim());
    if (rate == null || rate < 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.pieceRateInvalidError)));
      return;
    }
    try {
      await ref
          .read(employeePayRateServiceProvider)
          .setDefaultRate(widget.product.id, rate);
      ref.invalidate(productDefaultRateProvider(widget.product.id));
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.pieceRateSavedMessage)));
      }
    } on AppException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final defaultRate = ref.watch(productDefaultRateProvider(widget.product.id));

    // Seed the field once from the resolved default rate (0 if none set).
    defaultRate.whenData((row) {
      if (!_initialized) {
        _initialized = true;
        _rate.text = _formatRate(row?.rate ?? 0);
      }
    });

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                widget.product.name,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 100,
              child: TextField(
                key: Key('piece_rate_field_${widget.product.id}'),
                controller: _rate,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: l10n.pieceRateFieldLabel,
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              key: Key('piece_rate_save_${widget.product.id}'),
              icon: const Icon(Icons.check),
              tooltip: l10n.pieceRateSaveAction,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
