import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../domain/customer.dart';
import 'add_edit_customer_screen.dart';
import 'customer_providers.dart';

class CustomerDetailScreen extends ConsumerWidget {
  const CustomerDetailScreen({super.key, required this.customerId});
  final String customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customer = ref.watch(customerProvider(customerId));
    return Scaffold(
      appBar: AppBar(title: const Text('Customer')),
      body: AsyncValueView<Customer?>(
        value: customer,
        data: (c) {
          if (c == null) return const Center(child: Text('Not found'));
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(c.name, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              if (c.email != null) ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: Text(c.email!)),
              if (c.phones.isNotEmpty) ListTile(
                  leading: const Icon(Icons.phone_outlined),
                  title: Text(c.phones.join(', '))),
              if (c.address != null) ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: Text(c.address!)),
              ListTile(
                  leading: const Icon(Icons.schedule),
                  title: Text('Payment terms: ${c.paymentTerms} days')),
              if (c.creditLimit != null) ListTile(
                  leading: const Icon(Icons.credit_card),
                  title: Text('Credit limit: ${c.creditLimit}')),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text('Edit'),
                onPressed: () async {
                  await Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) =>
                          AddEditCustomerScreen(existing: c)));
                  ref.invalidate(customerProvider(customerId));
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
