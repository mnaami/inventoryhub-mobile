import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../../core/widgets/empty_state.dart';
import 'add_edit_customer_screen.dart';
import 'customer_detail_screen.dart';
import 'customer_providers.dart';

class CustomerListScreen extends ConsumerWidget {
  const CustomerListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customers = ref.watch(customersProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Customers')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const AddEditCustomerScreen()));
        },
        child: const Icon(Icons.add),
      ),
      body: AsyncValueView(
        value: customers,
        data: (list) => list.isEmpty
            ? const EmptyState(
                icon: Icons.people_outline,
                title: 'No customers yet. Tap + to add one.')
            : ListView.builder(
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final c = list[i];
                  return ListTile(
                    title: Text(c.name),
                    subtitle: c.email == null ? null : Text(c.email!),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) =>
                            CustomerDetailScreen(customerId: c.id))),
                  );
                },
              ),
      ),
    );
  }
}
