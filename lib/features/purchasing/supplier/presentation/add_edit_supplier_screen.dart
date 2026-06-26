import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/result/app_exception.dart';
import '../domain/supplier.dart';
import 'supplier_providers.dart';

class AddEditSupplierScreen extends ConsumerStatefulWidget {
  const AddEditSupplierScreen({super.key, this.existing});
  final Supplier? existing;

  @override
  ConsumerState<AddEditSupplierScreen> createState() =>
      _AddEditSupplierScreenState();
}

class _AddEditSupplierScreenState extends ConsumerState<AddEditSupplierScreen> {
  late final TextEditingController _name =
      TextEditingController(text: widget.existing?.name ?? '');
  late final TextEditingController _contact =
      TextEditingController(text: widget.existing?.contactPerson ?? '');
  late final TextEditingController _email =
      TextEditingController(text: widget.existing?.email ?? '');
  late final TextEditingController _phone =
      TextEditingController(text: widget.existing?.phones.join(', ') ?? '');
  late final TextEditingController _address =
      TextEditingController(text: widget.existing?.address ?? '');
  late final TextEditingController _terms = TextEditingController(
      text: (widget.existing?.paymentTerms ?? 30).toString());
  late final TextEditingController _credit = TextEditingController(
      text: widget.existing?.creditLimit?.toString() ?? '');
  String? _error;

  @override
  void dispose() {
    for (final c in [_name, _contact, _email, _phone, _address, _terms, _credit]) {
      c.dispose();
    }
    super.dispose();
  }

  List<String> get _phones => _phone.text
      .split(',')
      .map((p) => p.trim())
      .where((p) => p.isNotEmpty)
      .toList();

  String? _nullable(String s) => s.trim().isEmpty ? null : s.trim();

  Future<void> _save() async {
    setState(() => _error = null);
    final service = ref.read(supplierServiceProvider);
    final terms = int.tryParse(_terms.text.trim()) ?? 30;
    final credit = double.tryParse(_credit.text.trim());
    try {
      if (widget.existing == null) {
        await service.create(
          name: _name.text,
          contactPerson: _nullable(_contact.text),
          email: _nullable(_email.text),
          phones: _phones,
          address: _nullable(_address.text),
          paymentTerms: terms,
          creditLimit: credit,
        );
      } else {
        await service.edit(widget.existing!.copyWith(
          name: _name.text,
          contactPerson: _nullable(_contact.text),
          email: _nullable(_email.text),
          phones: _phones,
          address: _nullable(_address.text),
          paymentTerms: terms,
          creditLimit: credit,
        ));
      }
      ref.invalidate(suppliersProvider);
      if (mounted) Navigator.of(context).pop(true);
    } on ValidationException catch (e) {
      setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.existing == null ? 'New Supplier' : 'Edit Supplier')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Name')),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(_error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          TextField(
              controller: _contact,
              decoration: const InputDecoration(labelText: 'Contact person')),
          TextField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'Email')),
          TextField(
              controller: _phone,
              decoration:
                  const InputDecoration(labelText: 'Phones (comma-separated)')),
          TextField(
              controller: _address,
              decoration: const InputDecoration(labelText: 'Address')),
          TextField(
              controller: _terms,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: 'Payment terms (days)')),
          TextField(
              controller: _credit,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Credit limit')),
          const SizedBox(height: 24),
          FilledButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
    );
  }
}
