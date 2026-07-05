import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../core/l10n/l10n_ext.dart';
import '../../../../core/result/app_exception.dart';
import '../../employee/presentation/employee_detail_providers.dart';
import '../../employee/presentation/employee_providers.dart';

/// Bottom sheet to record a payment for an employee. Only amount, date
/// (default today), and notes — employee payments have no method/status.
///
/// Returns `true` via [Navigator.pop] on success so callers can react, but the
/// invalidation contract (balance/payments/list) is run here regardless of
/// whether the caller checks the result.
class RecordEmployeePaymentSheet extends ConsumerStatefulWidget {
  const RecordEmployeePaymentSheet({super.key, required this.employeeId});
  final String employeeId;

  @override
  ConsumerState<RecordEmployeePaymentSheet> createState() =>
      _RecordEmployeePaymentSheetState();
}

class _RecordEmployeePaymentSheetState
    extends ConsumerState<RecordEmployeePaymentSheet> {
  final _amount = TextEditingController();
  final _notes = TextEditingController();
  DateTime _date = DateTime.now();
  String? _error;

  @override
  void dispose() {
    _amount.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    setState(() => _error = null);
    final amount = double.tryParse(_amount.text.trim());
    if (amount == null || amount <= 0) {
      setState(() => _error = l10n.employeePaymentInvalidAmountError);
      return;
    }
    try {
      await ref.read(employeePaymentServiceProvider).record(
            employeeId: widget.employeeId,
            amount: amount,
            paymentDate: _date,
            notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
          );
      ref.invalidate(employeeBalanceProvider(widget.employeeId));
      ref.invalidate(employeePaymentsProvider(widget.employeeId));
      ref.invalidate(employeeListProvider);
      if (mounted) Navigator.of(context).pop(true);
    } on AppException catch (e) {
      setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
            l10n.employeeRecordPaymentTitle,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppTokens.space16),
          TextField(
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.employeePaymentAmountLabel,
            ),
          ),
          const SizedBox(height: AppTokens.space16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.employeePaymentDateLabel),
            subtitle: Text(
                '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}'),
            trailing: const Icon(Icons.calendar_today_outlined),
            onTap: _pickDate,
          ),
          const SizedBox(height: AppTokens.space16),
          TextField(
            controller: _notes,
            decoration:
                InputDecoration(labelText: l10n.employeePaymentNotesLabel),
            maxLines: 2,
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
        ],
      ),
    );
  }
}
