import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/format/quantity_format.dart';
import '../../../../core/l10n/l10n_ext.dart';
import '../../../../core/result/app_exception.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../inventory/product/domain/product.dart';
import '../../../inventory/product/presentation/product_providers.dart';
import '../../../inventory/unit/presentation/unit_providers.dart';
import '../../production_order/presentation/production_order_providers.dart'
    show allProductsProvider;
import '../domain/production_recipe.dart';
import 'production_recipe_providers.dart';

class ProductionRecipeDetailScreen extends ConsumerWidget {
  const ProductionRecipeDetailScreen({super.key, required this.recipeId});
  final String recipeId;

  void _openIngredientSheet(
    BuildContext context,
    ProductionRecipe recipe, {
    ProductionRecipeItem? item,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _IngredientSheet(
        recipeId: recipe.id,
        outputProductId: recipe.productId,
        item: item,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final recipe = ref.watch(recipeProvider(recipeId));
    final items = ref.watch(recipeItemsProvider(recipeId));
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final loadedRecipe = recipe.value;

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
      floatingActionButton: loadedRecipe == null
          ? null
          : FloatingActionButton(
              tooltip: l10n.recipeAddIngredientTitle,
              onPressed: () => _openIngredientSheet(context, loadedRecipe),
              child: const Icon(Icons.add),
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
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              // Resolve and display the output product this recipe produces.
              Consumer(
                builder: (context, ref, _) {
                  final p = ref.watch(productProvider(r.productId));
                  return Text(
                    l10n.recipeForOutputProduct(
                        p.value?.name ?? r.productId),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              if (r.description != null && r.description!.isNotEmpty) ...[
                Text(
                  r.description!,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: scheme.onSurfaceVariant),
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
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              AsyncValueView(
                value: items,
                data: (lines) {
                  if (lines.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        l10n.recipeNoIngredientsYet,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    );
                  }
                  return Column(
                    children: lines
                        .map((l) => Consumer(
                              builder: (context, ref, _) {
                                final p = ref.watch(
                                    productProvider(l.ingredientProductId));
                                final product = p.value;
                                final barcode = product?.barcode;
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  onTap: () => _openIngredientSheet(context, r,
                                      item: l),
                                  title: Text(
                                    product?.name ?? l.ingredientProductId,
                                    style: theme.textTheme.bodyLarge
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: p.isLoading
                                      ? Text(l10n.recipeIngredientLoading)
                                      : (barcode != null && barcode.isNotEmpty
                                          ? Text(l10n.productionBarcodeValue(
                                              barcode))
                                          : null),
                                  trailing: Text(l10n.recipeQuantityPerUnit(
                                      formatQty(l.quantityPerUnit), l.unit)),
                                );
                              },
                            ))
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }
}

/// Add/edit an ingredient line on a recipe. In add mode it picks an ingredient
/// product (excluding the recipe's own output and already-added ingredients)
/// and derives the unit from that product's stock unit. In edit mode the
/// product and unit are fixed; only the quantity-per-unit changes.
class _IngredientSheet extends ConsumerStatefulWidget {
  const _IngredientSheet({
    required this.recipeId,
    required this.outputProductId,
    this.item,
  });

  final String recipeId;
  final String outputProductId;
  final ProductionRecipeItem? item;

  @override
  ConsumerState<_IngredientSheet> createState() => _IngredientSheetState();
}

class _IngredientSheetState extends ConsumerState<_IngredientSheet> {
  late final TextEditingController _qty;
  String? _productId;

  bool get _isEdit => widget.item != null;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _qty = TextEditingController(
        text: item != null ? formatQty(item.quantityPerUnit) : '');
    _productId = item?.ingredientProductId;
  }

  @override
  void dispose() {
    _qty.dispose();
    super.dispose();
  }

  String _unitSuffix(List<Product>? products) {
    if (_isEdit) return widget.item!.unit;
    final pid = _productId;
    if (pid == null || products == null) return '';
    final match = products.where((p) => p.id == pid);
    if (match.isEmpty) return '';
    return ref.watch(unitSymbolProvider(match.first.unitId)).value ?? '';
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final service = ref.read(productionRecipeServiceProvider);
    final qty = double.tryParse(_qty.text.trim());
    try {
      if (_isEdit) {
        if (qty == null || qty <= 0) {
          _snack(l10n.productionEnterValidQuantityError);
          return;
        }
        await service.editIngredient(widget.item!.id,
            quantityPerUnit: qty, unit: widget.item!.unit);
      } else {
        final pid = _productId;
        if (pid == null) {
          _snack(l10n.recipeSelectIngredientError);
          return;
        }
        if (qty == null || qty <= 0) {
          _snack(l10n.productionEnterValidQuantityError);
          return;
        }
        final products = await ref.read(allProductsProvider.future);
        final product = products.firstWhere((p) => p.id == pid);
        final unit = await ref.read(unitSymbolProvider(product.unitId).future);
        await service.addIngredient(widget.recipeId,
            ingredientProductId: pid, quantityPerUnit: qty, unit: unit);
      }
      ref.invalidate(recipeItemsProvider(widget.recipeId));
      if (mounted) Navigator.of(context).pop();
    } on AppException catch (e) {
      _snack(e.message);
    }
  }

  Future<void> _remove() async {
    try {
      await ref
          .read(productionRecipeServiceProvider)
          .removeIngredient(widget.item!.id);
      ref.invalidate(recipeItemsProvider(widget.recipeId));
      if (mounted) Navigator.of(context).pop();
    } on AppException catch (e) {
      _snack(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final products = ref.watch(allProductsProvider);
    final existing = ref.watch(recipeItemsProvider(widget.recipeId));
    final suffix = _unitSuffix(products.value);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _isEdit
                ? l10n.recipeEditIngredientTitle
                : l10n.recipeAddIngredientTitle,
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (_isEdit)
            Consumer(
              builder: (context, ref, _) {
                final p =
                    ref.watch(productProvider(widget.item!.ingredientProductId));
                return InputDecorator(
                  decoration: InputDecoration(
                    labelText: l10n.recipeIngredientProductLabel,
                  ),
                  child: Text(
                      p.value?.name ?? widget.item!.ingredientProductId),
                );
              },
            )
          else
            products.when(
              data: (list) {
                final existingIds = existing.value
                        ?.map((e) => e.ingredientProductId)
                        .toSet() ??
                    <String>{};
                final selectable = list
                    .where((p) =>
                        p.id != widget.outputProductId &&
                        !existingIds.contains(p.id))
                    .toList();
                if (selectable.isEmpty) {
                  return Text(l10n.recipeNoProductsToAdd);
                }
                return DropdownButtonFormField<String>(
                  initialValue: _productId,
                  decoration: InputDecoration(
                    labelText: l10n.recipeIngredientProductLabel,
                  ),
                  items: [
                    for (final p in selectable)
                      DropdownMenuItem(value: p.id, child: Text(p.name)),
                  ],
                  onChanged: (v) => setState(() => _productId = v),
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('$e'),
            ),
          const SizedBox(height: 12),
          TextField(
            controller: _qty,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.recipeIngredientQuantityLabel,
              helperText: l10n.recipeIngredientQuantityHelper,
              suffixText: suffix.isEmpty ? null : suffix,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              if (_isEdit) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.delete_outline),
                    style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.error),
                    label: Text(l10n.recipeRemoveIngredientButton),
                    onPressed: _remove,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: FilledButton(
                  onPressed: _save,
                  child: Text(l10n.recipeSaveIngredientButton),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
