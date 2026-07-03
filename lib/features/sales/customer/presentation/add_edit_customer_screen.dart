import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/result/app_exception.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../app/theme/app_tokens.dart';
import '../domain/customer.dart';
import 'contact_selection_screen.dart';
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
  late final List<TextEditingController> _phoneControllers;
  late final TextEditingController _address =
      TextEditingController(text: widget.existing?.address ?? '');
  late final TextEditingController _terms = TextEditingController(
      text: (widget.existing?.paymentTerms ?? 30).toString());
  late final TextEditingController _credit = TextEditingController(
      text: widget.existing?.creditLimit?.toString() ?? '');
  String? _error;

  @override
  void initState() {
    super.initState();
    final existingPhones = widget.existing?.phones ?? [];
    if (existingPhones.isEmpty) {
      _phoneControllers = [TextEditingController()];
    } else {
      _phoneControllers = existingPhones
          .map((phone) => TextEditingController(text: phone))
          .toList();
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    for (final c in _phoneControllers) {
      c.dispose();
    }
    _address.dispose();
    _terms.dispose();
    _credit.dispose();
    super.dispose();
  }

  Future<void> _showContactImportDialog() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ContactSelectionScreen(
          onContactSelected: (name, phone, email) {
            setState(() {
              if (_name.text.trim().isEmpty) {
                _name.text = name;
              }
              
              if (email.isNotEmpty && _email.text.trim().isEmpty) {
                _email.text = email;
              }

              if (phone.isNotEmpty) {
                final newPhones = phone
                    .split(',')
                    .map((p) => p.trim())
                    .where((p) => p.isNotEmpty)
                    .toList();

                final currentPhones = _phoneControllers.map((c) => c.text.trim()).toList();

                for (final newPhone in newPhones) {
                  if (!currentPhones.contains(newPhone)) {
                    if (_phoneControllers.length == 1 && _phoneControllers[0].text.trim().isEmpty) {
                      _phoneControllers[0].text = newPhone;
                      currentPhones[0] = newPhone;
                    } else {
                      _phoneControllers.add(TextEditingController(text: newPhone));
                      currentPhones.add(newPhone);
                    }
                  }
                }
              }
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Contact information imported successfully!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<String> get _phones => _phoneControllers
      .map((c) => c.text.trim())
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
        title: Text(widget.existing == null ? 'New Customer' : 'Edit Customer'),
        actions: [
          if (Platform.isAndroid)
            IconButton(
              icon: const Icon(Icons.contact_phone),
              tooltip: 'Import Contact',
              onPressed: _showContactImportDialog,
            ),
          TextButton(
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      ),
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
                Text(
                  'Phone Numbers',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                ...List.generate(_phoneControllers.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _phoneControllers[index],
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: 'Phone #${index + 1}',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.delete_outline, color: scheme.error),
                          onPressed: () {
                            setState(() {
                              final controller = _phoneControllers.removeAt(index);
                              controller.dispose();
                              if (_phoneControllers.isEmpty) {
                                _phoneControllers.add(TextEditingController());
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  );
                }),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _phoneControllers.add(TextEditingController());
                    });
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Phone Number'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 36),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
        ],
      ),
    );
  }
}
