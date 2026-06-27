import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/stat_tile.dart';
import '../production_order/presentation/production_order_list_screen.dart';
import '../production_order/presentation/production_order_providers.dart';
import '../recipe/presentation/production_recipe_list_screen.dart';

class ProductionHomeScreen extends ConsumerWidget {
  const ProductionHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kpis = ref.watch(productionDashboardProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Production')),
      body: AsyncValueView(
        value: kpis,
        data: (k) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                    child: StatTile(label: 'Planned', value: '${k.planned}')),
                const SizedBox(width: 12),
                Expanded(
                    child: StatTile(
                        label: 'In progress', value: '${k.inProgress}')),
              ],
            ),
            const SizedBox(height: 12),
            StatTile(label: 'Completed', value: '${k.completed}'),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.receipt_long),
              label: const Text('Production orders'),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const ProductionOrderListScreen())),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.menu_book),
              label: const Text('Recipes'),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const ProductionRecipeListScreen())),
            ),
          ],
        ),
      ),
    );
  }
}
