import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/currency/currency_controller.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../core/db/app_database.dart';
import '../../../../core/l10n/l10n_ext.dart';
import '../../../../core/result/app_exception.dart';
import '../../../inventory/product/domain/product.dart';
import '../../../inventory/product/presentation/product_providers.dart';
import '../../employee/presentation/employee_detail_providers.dart';
import '../../employee/presentation/employee_providers.dart';

/// Add/edit/remove a single piece-rate override for one employee.
///
/// Add mode ([existing] null): pick a product (excluding products this
/// employee already has an override for), enter a rate, `setOverride(...)`.
/// Edit mode ([existing] set): the product is fixed, rate is editable, and a
/// destructive Remove action calls `removeOverride(id)`.
class EmployeeRateSheet extends ConsumerStatefulWidget {
  const EmployeeRateSheet({
    super.key,
    required this.employeeId,
    this.existing,
    this.existingProductIds = const [],
  });

  final String employeeId;
  final ProductionPayRateRow? existing;
  /// Product ids this employee already has an active override for — excluded
  /// from the picker in add mode.
  final List<String> existingProductIds;

  @override
  ConsumerState<EmployeeRateSheet> createState() => _EmployeeRateSheetState();
}

class _EmployeeRateSheetState extends ConsumerState<EmployeeRateSheet> {
  String? _productId;
  final _rate = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();
    _productId = widget.existing?.productId;
    if (widget.existing != null) {
      _rate.text = _formatRate(widget.existing!.rate);
    }
  }

  @override
  void dispose() {
    _rate.dispose();
    super.dispose();
  }

  String _formatRate(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  Future<void> _save() async {
    final l10n = context.l10n;
    setState(() => _error = null);
    final rate = double.tryParse(_rate.text.trim());
    if (_productId == null || rate == null || rate <= 0) {
      setState(() => _error = l10n.employeeRateInvalidError);
      return;
    }
    try {
      await ref.read(employeePayRateServiceProvider).setOverride(
            employeeId: widget.employeeId,
            productId: _productId!,
            rate: rate,
          );
      ref.invalidate(employeeRatesProvider(widget.employeeId));
      if (mounted) Navigator.of(context).pop(true);
    } on AppException catch (e) {
      setState(() => _error = e.message);
    }
  }

  Future<void> _remove() async {
    final existing = widget.existing;
    if (existing == null) return;
    try {
      await ref.read(employeePayRateServiceProvider).removeOverride(existing.id);
      ref.invalidate(employeeRatesProvider(widget.employeeId));
      if (mounted) Navigator.of(context).pop(true);
    } on AppException catch (e) {
      setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isEdit = widget.existing != null;
    final money = ref.watch(moneyFormatterProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEdit
                ? l10n.employeeRateSheetEditTitle
                : l10n.employeeRateSheetAddTitle,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppTokens.space16),
          if (isEdit)
            Consumer(builder: (context, ref, _) {
              final product =
                  ref.watch(productProvider(widget.existing!.productId));
              return Text(
                product.asData?.value?.name ?? '',
                style: Theme.of(context).textTheme.titleMedium,
              );
            })
          else
            Consumer(builder: (context, ref, _) {
              final products = ref.watch(productPickerListProvider);
              return products.when(
                data: (list) {
                  final available = list
                      .where((p) =>
                          !widget.existingProductIds.contains(p.id))
                      .toList();
                  if (available.isEmpty) {
                    return Text(l10n.employeeRateNoProductsAvailable);
                  }
                  return DropdownButtonFormField<String>(
                    value: _productId,
                    decoration:
                        InputDecoration(labelText: l10n.employeeRateProductLabel),
                    items: [
                      for (final p in available)
                        DropdownMenuItem(value: p.id, child: Text(p.name)),
                    ],
                    onChanged: (id) => setState(() => _productId = id),
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (_, __) => const SizedBox.shrink(),
              );
            }),
          if (_productId != null)
            Consumer(builder: (context, ref, _) {
              final fallback = ref.watch(productDefaultRateProvider(_productId!));
              return fallback.maybeWhen(
                data: (row) => row == null
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          l10n.employeeRateDefaultHint(money(row.rate)),
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant),
                        ),
                      ),
                orElse: () => const SizedBox.shrink(),
              );
            }),
          const SizedBox(height: AppTokens.space16),
          TextField(
            controller: _rate,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: l10n.employeeRateRateLabel),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          const SizedBox(height: AppTokens.space24),
          FilledButton(
            onPressed: _save,
            child: Text(l10n.employeeSaveButton),
          ),
          if (isEdit) ...[
            const SizedBox(height: AppTokens.space8),
            TextButton(
              onPressed: _remove,
              style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error),
              child: Text(l10n.employeeRateRemoveAction),
            ),
          ],
        ],
      ),
    );
  }
}

/// Products for the override picker. Reuses the paged product list-usecase's
/// first page (small businesses; matches the employee list's own no-pagination
/// simplicity) rather than introducing new paging machinery for a picker.
final productPickerListProvider = FutureProvider<List<Product>>(
    (ref) => ref.watch(productServiceProvider).list(page: 0));
