import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/result/app_exception.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../app/theme/app_tokens.dart';
import '../domain/customer.dart';
import 'customer_providers.dart';

class AddEditCustomerScreen extends ConsumerStatefulWidget {
  const AddEditCustomerScreen({super.key, this.existing});
  final Customer? existing;

  @override
  ConsumerState<AddEditCustomerScreen> createState() =>
      _AddEditCustomerScreenState();
}

class _AddEditCustomerScreenState extends ConsumerState<AddEditCustomerScreen> {
  late final TextEditingController _name =
      TextEditingController(text: widget.existing?.name ?? '');
  late final TextEditingController _email =
      TextEditingController(text: widget.existing?.email ?? '');
  late final TextEditingController _phone = TextEditingController(
      text: widget.existing?.phones.join(', ') ?? '');
  late final TextEditingController _address =
      TextEditingController(text: widget.existing?.address ?? '');
  late final TextEditingController _terms = TextEditingController(
      text: (widget.existing?.paymentTerms ?? 30).toString());
  late final TextEditingController _credit = TextEditingController(
      text: widget.existing?.creditLimit?.toString() ?? '');
  String? _error;

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _address, _terms, _credit]) {
      c.dispose();
    }
    super.dispose();
  }

  List<String> get _phones => _phone.text
      .split(',')
      .map((p) => p.trim())
      .where((p) => p.isNotEmpty)
      .toList();

  Future<void> _save() async {
    setState(() => _error = null);
    final service = ref.read(customerServiceProvider);
    final terms = int.tryParse(_terms.text.trim()) ?? 30;
    final credit = double.tryParse(_credit.text.trim());
    try {
      if (widget.existing == null) {
        await service.create(
          name: _name.text,
          email: _email.text.trim().isEmpty ? null : _email.text.trim(),
          phones: _phones,
          address: _address.text.trim().isEmpty ? null : _address.text.trim(),
          paymentTerms: terms,
          creditLimit: credit,
        );
      } else {
        await service.edit(widget.existing!.copyWith(
          name: _name.text,
          email: _email.text.trim().isEmpty ? null : _email.text.trim(),
          phones: _phones,
          address: _address.text.trim().isEmpty ? null : _address.text.trim(),
          paymentTerms: terms,
          creditLimit: credit,
        ));
      }
      ref.invalidate(customersProvider);
      if (mounted) Navigator.of(context).pop(true);
    } on ValidationException catch (e) {
      setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
          title: Text(widget.existing == null ? 'New Customer' : 'Edit Customer')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Form card
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Customer Details',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _name,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                  ),
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
                const SizedBox(height: 16),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phones (comma-separated)',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _address,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _terms,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Payment terms (days)',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _credit,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Credit limit',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTokens.space24),

          // Action Button
          FilledButton(
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
