import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/l10n/l10n_ext.dart';
import '../../../../core/result/app_exception.dart';
import '../../../../core/widgets/async_value_view.dart';
import 'production_recipe_providers.dart';

class ProductionRecipeDetailScreen extends ConsumerWidget {
  const ProductionRecipeDetailScreen({super.key, required this.recipeId});
  final String recipeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final recipe = ref.watch(recipeProvider(recipeId));
    final items = ref.watch(recipeItemsProvider(recipeId));
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.recipeDetailTitle),
        actions: [
          IconButton(
            tooltip: l10n.recipeMakeActiveTooltip,
            icon: const Icon(Icons.check_circle_outline),
            onPressed: () async {
              try {
                await ref
                    .read(productionRecipeServiceProvider)
                    .activate(recipeId);
                ref.invalidate(recipeProvider(recipeId));
                ref.invalidate(recipesProvider);
              } on AppException catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(e.message)));
                }
              }
            },
          ),
        ],
      ),
      body: AsyncValueView(
        value: recipe,
        data: (r) {
          if (r == null) {
            return Center(child: Text(l10n.recipeNotFound));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(r.name,
                  style: Theme.of(context).textTheme.headlineSmall),
              if (r.description != null) Text(r.description!),
              const SizedBox(height: 8),
              Text(r.isActive ? l10n.recipeActiveLabel : l10n.recipeInactive),
              const Divider(height: 24),
              Text(l10n.recipeIngredientsHeading,
                  style: Theme.of(context).textTheme.titleMedium),
              AsyncValueView(
                value: items,
                data: (lines) => Column(
                  children: lines
                      .map((l) => ListTile(
                            dense: true,
                            title: Text(l.ingredientProductId),
                            trailing: Text(l10n.recipeQuantityPerUnit(
                                '${l.quantityPerUnit}', l.unit)),
                          ))
                      .toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
