import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../../core/widgets/empty_state.dart';
import 'add_edit_supplier_screen.dart';
import 'supplier_detail_screen.dart';
import 'supplier_providers.dart';

class SupplierListScreen extends ConsumerWidget {
  const SupplierListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suppliers = ref.watch(suppliersProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Suppliers')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const AddEditSupplierScreen()));
        },
        child: const Icon(Icons.add),
      ),
      body: AsyncValueView(
        value: suppliers,
        data: (list) => list.isEmpty
            ? const EmptyState(
                icon: Icons.local_shipping_outlined,
                title: 'No suppliers yet. Tap + to add one.')
            : ListView.builder(
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final s = list[i];
                  return ListTile(
                    title: Text(s.name),
                    subtitle: s.contactPerson == null
                        ? (s.email == null ? null : Text(s.email!))
                        : Text(s.contactPerson!),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) =>
                            SupplierDetailScreen(supplierId: s.id))),
                  );
                },
              ),
      ),
    );
  }
}
