import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/l10n/l10n_ext.dart';
import '../../../../core/result/app_exception.dart';
import '../../production_order/presentation/production_order_providers.dart'
    show allProductsProvider;
import 'production_recipe_providers.dart';

/// Minimal create form: pick an output product, name the recipe, and choose
/// whether to make it the active recipe. Ingredients are managed afterward
/// from the detail screen.
class AddEditRecipeScreen extends ConsumerStatefulWidget {
  const AddEditRecipeScreen({super.key});

  @override
  ConsumerState<AddEditRecipeScreen> createState() =>
      _AddEditRecipeScreenState();
}

class _AddEditRecipeScreenState extends ConsumerState<AddEditRecipeScreen> {
  final _name = TextEditingController();
  String? _productId;
  bool _activate = true;

  @override
  void initState() {
    super.initState();
    // allProductsProvider is a shared cache that is not invalidated when
    // products are created elsewhere; refresh it so newly added products
    // appear in the output-product picker.
    ref.invalidate(allProductsProvider);
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final products = ref.watch(allProductsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.recipeCreateTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            products.when(
              data: (list) => DropdownButtonFormField<String>(
                initialValue: _productId,
                decoration:
                    InputDecoration(labelText: l10n.productionOutputProductLabel),
                items: [
                  for (final p in list)
                    DropdownMenuItem(value: p.id, child: Text(p.name))
                ],
                onChanged: (v) => setState(() => _productId = v),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('$e'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _name,
              decoration: InputDecoration(labelText: l10n.recipeNameLabel),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: Text(l10n.recipeMakeActiveSwitchLabel),
              value: _activate,
              onChanged: (v) => setState(() => _activate = v),
            ),
            const Spacer(),
            FilledButton(
              onPressed: _save,
              child: Text(l10n.productionCreateButton),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final productId = _productId;
    if (productId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.productionChooseOutputProductError)));
      return;
    }
    try {
      await ref.read(productionRecipeServiceProvider).create(
            productId: productId,
            name: _name.text,
            activate: _activate,
          );
      ref.invalidate(recipesProvider);
      if (mounted) Navigator.of(context).pop();
    } on AppException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }
}
