import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventoryhub_mobile/app/currency/currency_controller.dart';
import '../../../../core/l10n/l10n_ext.dart';
import '../../../../core/result/app_exception.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../app/theme/app_tokens.dart';
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
      setState(() => _error = context.l10n.poInvalidAmountError);
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
    final l10n = context.l10n;
    final money = ref.watch(moneyFormatterProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final paymentsAsync =
        ref.watch(saleOrderPaymentsProvider(widget.order.id));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.soRecordPaymentTitle)),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Subtitle / Context Card
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
                        l10n.poRecordingPaymentFor,
                        style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.poOrderTotalLine(
                            widget.order.soNumber, money(widget.order.totalAmount)),
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      paymentsAsync.maybeWhen(
                        data: (list) {
                          final paid = list
                              .where((p) =>
                                  p.status == PaymentRecordStatus.completed &&
                                  p.isActive)
                              .fold<double>(0, (sum, p) => sum + p.amount);
                          final remaining =
                              widget.order.totalAmount - paid;
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '${l10n.soRemainingLabel}: ${money(remaining)}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: scheme.primary,
                              ),
                            ),
                          );
                        },
                        orElse: () => const SizedBox.shrink(),
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
                  l10n.poPaymentInfoHeading,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _amount,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: l10n.soAmountPaidLabel,
                    prefixText: '\$ ',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<PaymentMethod>(
                  value: _method,
                  decoration: InputDecoration(labelText: l10n.soPaymentMethodLabel),
                  items: [
                    for (final m in PaymentMethod.values)
                      DropdownMenuItem(
                        value: m,
                        child: Text(m.wire.toUpperCase().replaceAll('_', ' ')),
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

          // Submit button
          FilledButton(
            onPressed: _save,
            child: Text(l10n.soSavePaymentButton),
          ),
        ],
      ),
    );
  }
}
