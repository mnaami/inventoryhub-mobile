import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/result/app_exception.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../app/theme/app_tokens.dart';
import '../domain/unit.dart';
import 'unit_providers.dart';

const _unitTypes = ['count', 'weight', 'volume', 'length', 'area', 'time'];

class AddEditUnitScreen extends ConsumerStatefulWidget {
  const AddEditUnitScreen({super.key, this.existing});
  final Unit? existing;
  @override
  ConsumerState<AddEditUnitScreen> createState() => _State();
}

class _State extends ConsumerState<AddEditUnitScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.existing?.name ?? '');
  late final _symbol = TextEditingController(text: widget.existing?.symbol ?? '');
  late final _factor = TextEditingController(
      text: (widget.existing?.conversionFactor ?? 1.0).toString());
  late String _type = widget.existing?.unitType ?? 'count';
  late bool _isBase = widget.existing?.isBaseUnit ?? true;
  String? _baseUnitId;

  @override
  void initState() {
    super.initState();
    _baseUnitId = widget.existing?.baseUnitId;
  }

  @override
  void dispose() {
    _name.dispose();
    _symbol.dispose();
    _factor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    final units = ref.watch(unitsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit unit' : 'New unit')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppTokens.space16),
          children: [
            // ── Basic info ──────────────────────────────────────────────
            const SectionHeader('Basic info'),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(Icons.label_outline),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: AppTokens.space12),
            TextFormField(
              controller: _symbol,
              decoration: const InputDecoration(
                labelText: 'Symbol',
                prefixIcon: Icon(Icons.text_fields),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: AppTokens.space12),
            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Type'),
              items: [
                for (final t in _unitTypes)
                  DropdownMenuItem(value: t, child: Text(t)),
              ],
              onChanged: (v) => setState(() => _type = v ?? 'count'),
            ),

            // ── Conversion ──────────────────────────────────────────────
            const SizedBox(height: AppTokens.space24),
            const SectionHeader('Conversion'),
            SwitchListTile(
              title: const Text('Base unit'),
              value: _isBase,
              onChanged: (v) => setState(() => _isBase = v),
              contentPadding: EdgeInsets.zero,
            ),
            if (!_isBase) ...[
              const SizedBox(height: AppTokens.space12),
              units.maybeWhen(
                data: (list) {
                  final candidates = list
                      .where((u) => u.unitType == _type && u.isBaseUnit)
                      .toList();
                  return DropdownButtonFormField<String?>(
                    initialValue: _baseUnitId,
                    decoration:
                        const InputDecoration(labelText: 'Base unit'),
                    items: [
                      for (final u in candidates)
                        DropdownMenuItem(value: u.id, child: Text(u.name)),
                    ],
                    onChanged: (v) => setState(() => _baseUnitId = v),
                  );
                },
                orElse: () => const SizedBox.shrink(),
              ),
              const SizedBox(height: AppTokens.space12),
              TextFormField(
                controller: _factor,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Conversion factor (to base)'),
              ),
            ],

            const SizedBox(height: AppTokens.space24),
            FilledButton(onPressed: _save, child: const Text('Save')),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final service = ref.read(unitServiceProvider);
    try {
      if (widget.existing == null) {
        await service.create(
          name: _name.text,
          symbol: _symbol.text,
          unitType: _type,
          isBase: _isBase,
          baseUnitId: _baseUnitId,
          conversionFactor: double.tryParse(_factor.text) ?? 1.0,
        );
      } else {
        await service.edit(widget.existing!.copyWith(
          name: _name.text.trim(),
          symbol: _symbol.text.trim(),
          unitType: _type,
          isBaseUnit: _isBase,
          baseUnitId: _isBase ? null : _baseUnitId,
          conversionFactor:
              _isBase ? 1.0 : (double.tryParse(_factor.text) ?? 1.0),
        ));
      }
      ref.invalidate(unitsProvider);
      if (mounted) Navigator.of(context).pop();
    } on AppException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }
}
