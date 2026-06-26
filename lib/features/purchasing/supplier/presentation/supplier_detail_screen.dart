import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../domain/supplier.dart';
import 'add_edit_supplier_screen.dart';
import 'supplier_providers.dart';

class SupplierDetailScreen extends ConsumerWidget {
  const SupplierDetailScreen({super.key, required this.supplierId});
  final String supplierId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supplier = ref.watch(supplierProvider(supplierId));
    return Scaffold(
      appBar: AppBar(title: const Text('Supplier')),
      body: AsyncValueView<Supplier?>(
        value: supplier,
        data: (s) {
          if (s == null) return const Center(child: Text('Not found'));
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(s.name, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              if (s.contactPerson != null) ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(s.contactPerson!)),
              if (s.email != null) ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: Text(s.email!)),
              if (s.phones.isNotEmpty) ListTile(
                  leading: const Icon(Icons.phone_outlined),
                  title: Text(s.phones.join(', '))),
              if (s.address != null) ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: Text(s.address!)),
              ListTile(
                  leading: const Icon(Icons.schedule),
                  title: Text('Payment terms: ${s.paymentTerms} days')),
              if (s.creditLimit != null) ListTile(
                  leading: const Icon(Icons.credit_card),
                  title: Text('Credit limit: ${s.creditLimit}')),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text('Edit'),
                onPressed: () async {
                  await Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => AddEditSupplierScreen(existing: s)));
                  ref.invalidate(supplierProvider(supplierId));
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
