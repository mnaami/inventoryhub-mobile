import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../core/l10n/l10n_ext.dart';
import '../../../../core/result/app_exception.dart';
import '../../../../core/widgets/app_card.dart';
import '../domain/employee.dart';
import 'employee_detail_providers.dart';
import 'employee_providers.dart';

/// Add or edit an employee: name (required), phone, notes, active.
///
/// Create mode ([existing] null) calls `EmployeeService.create(...)`. Edit
/// mode mutates a full copy of [existing] via `copyWith(...)` and calls
/// `EmployeeService.edit(Employee)` — the service takes a full entity, not
/// individual fields.
class AddEditEmployeeScreen extends ConsumerStatefulWidget {
  const AddEditEmployeeScreen({super.key, this.existing});
  final Employee? existing;

  @override
  ConsumerState<AddEditEmployeeScreen> createState() =>
      _AddEditEmployeeScreenState();
}

class _AddEditEmployeeScreenState
    extends ConsumerState<AddEditEmployeeScreen> {
  late final TextEditingController _name =
      TextEditingController(text: widget.existing?.name ?? '');
  late final TextEditingController _phone =
      TextEditingController(text: widget.existing?.phone ?? '');
  late final TextEditingController _notes =
      TextEditingController(text: widget.existing?.notes ?? '');
  late bool _isActive = widget.existing?.isActive ?? true;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _error = null);
    final service = ref.read(employeeServiceProvider);
    final phone = _phone.text.trim().isEmpty ? null : _phone.text.trim();
    final notes = _notes.text.trim().isEmpty ? null : _notes.text.trim();
    try {
      if (widget.existing == null) {
        await service.create(name: _name.text, phone: phone, notes: notes);
      } else {
        await service.edit(widget.existing!.copyWith(
          name: _name.text,
          phone: phone,
          notes: notes,
          isActive: _isActive,
        ));
      }
      ref.invalidate(employeeListProvider);
      if (widget.existing != null) {
        ref.invalidate(employeeProvider(widget.existing!.id));
      }
      if (mounted) Navigator.of(context).pop(true);
    } on ValidationException catch (e) {
      setState(() => _error = e.message);
    } on AppException catch (e) {
      setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isEdit = widget.existing != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? l10n.employeeEditTitle : l10n.employeeNewTitle),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(l10n.employeeSaveButton),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _name,
                  decoration: InputDecoration(labelText: l10n.employeeNameLabel),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _error!,
                      style: TextStyle(
                        color: scheme.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                const SizedBox(height: AppTokens.space16),
                TextField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration:
                      InputDecoration(labelText: l10n.employeePhoneLabel),
                ),
                const SizedBox(height: AppTokens.space16),
                TextField(
                  controller: _notes,
                  maxLines: 3,
                  decoration:
                      InputDecoration(labelText: l10n.employeeNotesLabel),
                ),
                if (isEdit) ...[
                  const SizedBox(height: AppTokens.space16),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.employeeActiveLabel),
                    value: _isActive,
                    onChanged: (v) => setState(() => _isActive = v),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
