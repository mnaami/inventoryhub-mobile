import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/result/app_exception.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/l10n/l10n_ext.dart';
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
    final l10n = context.l10n;
    final isEdit = widget.existing != null;
    final units = ref.watch(unitsProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? l10n.unitEditTitle : l10n.unitNewTitle)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // Basic Info Card
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.unitBasicInfoHeading,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _name,
                    decoration: InputDecoration(
                      labelText: l10n.unitNameLabel,
                      prefixIcon: const Icon(Icons.label_outline),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? l10n.unitFieldRequired
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _symbol,
                    decoration: InputDecoration(
                      labelText: l10n.unitSymbolLabel,
                      prefixIcon: const Icon(Icons.text_fields_outlined),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? l10n.unitFieldRequired
                        : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _type,
                    decoration: InputDecoration(labelText: l10n.unitTypeLabel),
                    items: [
                      for (final t in _unitTypes)
                        DropdownMenuItem(value: t, child: Text(t)),
                    ],
                    onChanged: (v) => setState(() => _type = v ?? 'count'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTokens.space16),

            // Conversion Card
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.unitConversionHeading,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: Text(l10n.unitBaseUnitLabel),
                    value: _isBase,
                    onChanged: (v) => setState(() => _isBase = v),
                    contentPadding: EdgeInsets.zero,
                  ),
                  if (!_isBase) ...[
                    const SizedBox(height: 16),
                    units.maybeWhen(
                      data: (list) {
                        final candidates = list
                            .where((u) => u.unitType == _type && u.isBaseUnit)
                            .toList();
                        return DropdownButtonFormField<String?>(
                          value: _baseUnitId,
                          decoration:
                              InputDecoration(labelText: l10n.unitBaseUnitLabel),
                          items: [
                            for (final u in candidates)
                              DropdownMenuItem(value: u.id, child: Text(u.name)),
                          ],
                          onChanged: (v) => setState(() => _baseUnitId = v),
                        );
                      },
                      orElse: () => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _factor,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: l10n.unitConversionFactorLabel,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppTokens.space24),

            // Save action button
            FilledButton(
              onPressed: _save,
              child: Text(l10n.unitSave),
            ),
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
