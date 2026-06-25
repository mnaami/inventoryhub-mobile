import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/result/app_exception.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../domain/unit.dart';
import 'add_edit_unit_screen.dart';
import 'unit_providers.dart';

class UnitsManagementScreen extends ConsumerWidget {
  const UnitsManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final units = ref.watch(unitsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Units')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _edit(context),
        child: const Icon(Icons.add),
      ),
      body: AsyncValueView<List<Unit>>(
        value: units,
        data: (list) => list.isEmpty
            ? const Center(child: Text('No units yet. Tap + to add one.'))
            : ListView(
                children: [
                  for (final u in list)
                    ListTile(
                      title: Text('${u.name} (${u.symbol})'),
                      subtitle: Text(u.isBaseUnit
                          ? '${u.unitType} · base'
                          : '${u.unitType} · ×${u.conversionFactor}'),
                      onTap: () => _edit(context, existing: u),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _delete(context, ref, u),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Future<void> _edit(BuildContext context, {Unit? existing}) =>
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => AddEditUnitScreen(existing: existing),
      ));

  Future<void> _delete(BuildContext context, WidgetRef ref, Unit u) async {
    if (!await confirmDialog(context,
        title: 'Delete unit', message: 'Delete "${u.name}"?')) {
      return;
    }
    try {
      await ref.read(unitServiceProvider).delete(u.id);
      ref.invalidate(unitsProvider);
    } on AppException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }
}
