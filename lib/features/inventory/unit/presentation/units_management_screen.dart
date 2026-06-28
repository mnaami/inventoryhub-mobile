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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Units')),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
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
            : ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final u = list[i];
                  return AppCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    onTap: () => _edit(context, existing: u),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: scheme.primary.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.straighten_outlined, color: scheme.primary, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${u.name} (${u.symbol})',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: scheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: scheme.onSurfaceVariant.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      u.unitType.toUpperCase(),
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: scheme.onSurfaceVariant,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (u.isBaseUnit) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Text(
                                        'BASE',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              if (!u.isBaseUnit) ...[
                                const SizedBox(height: 6),
                                Text(
                                  '× ${u.conversionFactor} conversion factor',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline_rounded, color: scheme.error),
                          onPressed: () => _delete(context, ref, u),
                        ),
                      ],
                    ),
                  );
                },
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
