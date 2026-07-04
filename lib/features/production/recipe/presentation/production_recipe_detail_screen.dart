import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/l10n/l10n_ext.dart';
import '../../../../core/result/app_exception.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../inventory/product/presentation/product_providers.dart';
import 'production_recipe_providers.dart';

class ProductionRecipeDetailScreen extends ConsumerWidget {
  const ProductionRecipeDetailScreen({super.key, required this.recipeId});
  final String recipeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final recipe = ref.watch(recipeProvider(recipeId));
    final items = ref.watch(recipeItemsProvider(recipeId));
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

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
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              
              // Resolve and display Output Product
              Consumer(
                builder: (context, ref, _) {
                  final p = ref.watch(productProvider(r.productId));
                  return p.when(
                    data: (product) => Text(
                      'For Output Product: ${product?.name ?? r.productId}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    loading: () => const Text('For Output Product: Loading...'),
                    error: (err, _) => Text('For Output Product: ${r.productId}'),
                  );
                },
              ),
              const SizedBox(height: 8),
              if (r.description != null && r.description!.isNotEmpty) ...[
                Text(
                  r.description!,
                  style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 8),
              ],
              Text(
                r.isActive ? l10n.recipeActiveLabel : l10n.recipeInactive,
                style: TextStyle(
                  color: r.isActive ? Colors.green : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(height: 32),
              Text(l10n.recipeIngredientsHeading,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              AsyncValueView(
                value: items,
                data: (lines) => Column(
                  children: lines
                      .map((l) => Consumer(
                            builder: (context, ref, _) {
                              final p = ref.watch(productProvider(l.ingredientProductId));
                              return p.when(
                                data: (product) => ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    product?.name ?? l.ingredientProductId,
                                    style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: product?.barcode != null
                                      ? Text('Barcode: ${product?.barcode}')
                                      : null,
                                  trailing: Text(l10n.recipeQuantityPerUnit(
                                      '${l.quantityPerUnit}', l.unit)),
                                ),
                                loading: () => ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text('Loading ingredient...'),
                                  trailing: Text(l10n.recipeQuantityPerUnit(
                                      '${l.quantityPerUnit}', l.unit)),
                                ),
                                error: (err, _) => ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(l.ingredientProductId),
                                  trailing: Text(l10n.recipeQuantityPerUnit(
                                      '${l.quantityPerUnit}', l.unit)),
                                ),
                              );
                            },
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
