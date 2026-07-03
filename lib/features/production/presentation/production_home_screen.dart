import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/l10n/l10n_ext.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/stat_tile.dart';
import '../production_order/presentation/production_order_list_screen.dart';
import '../production_order/presentation/production_order_providers.dart';
import '../recipe/presentation/production_recipe_list_screen.dart';

class ProductionHomeScreen extends ConsumerWidget {
  const ProductionHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final kpis = ref.watch(productionDashboardProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.productionHomeTitle)),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(productionDashboardProvider);
          await ref.read(productionDashboardProvider.future);
        },
        child: AsyncValueView(
          value: kpis,
          data: (k) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(
                      child: StatTile(
                          label: l10n.productionStatusPlanned,
                          value: '${k.planned}')),
                  const SizedBox(width: 12),
                  Expanded(
                      child: StatTile(
                          label: l10n.productionStatusInProgress,
                          value: '${k.inProgress}')),
                ],
              ),
              const SizedBox(height: 12),
              StatTile(
                  label: l10n.productionStatusCompleted,
                  value: '${k.completed}'),
              const SizedBox(height: 24),
              FilledButton.icon(
                icon: const Icon(Icons.receipt_long),
                label: Text(l10n.productionOrdersButton),
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const ProductionOrderListScreen())),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.menu_book),
                label: Text(l10n.recipesButton),
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const ProductionRecipeListScreen())),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
