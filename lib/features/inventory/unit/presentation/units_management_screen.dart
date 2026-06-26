import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/result/app_exception.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../app/theme/app_tokens.dart';
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
            ? EmptyState(
                icon: Icons.straighten,
                title: 'No units yet',
                subtitle: 'Define units like piece, kg, or litre.',
                actionLabel: 'Add unit',
                onAction: () => _edit(context),
              )
            : ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTokens.space16,
                  vertical: AppTokens.space8,
                ),
                children: [
                  for (final u in list) ...[
                    AppCard(
                      onTap: () => _edit(context, existing: u),
                      child: Row(
                        children: [
                          const Icon(Icons.straighten),
                          const SizedBox(width: AppTokens.space12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${u.name} (${u.symbol})',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                const SizedBox(height: AppTokens.space4),
                                Wrap(
                                  spacing: AppTokens.space4,
                                  children: [
                                    Chip(label: Text(u.unitType)),
                                    if (u.isBaseUnit)
                                      const Chip(label: Text('base')),
                                  ],
                                ),
                                if (!u.isBaseUnit) ...[
                                  const SizedBox(height: AppTokens.space4),
                                  Text(
                                    '× ${u.conversionFactor}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _delete(context, ref, u),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTokens.space8),
                  ],
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
