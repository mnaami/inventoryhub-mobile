import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(allProductsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('New recipe')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            products.when(
              data: (list) => DropdownButtonFormField<String>(
                initialValue: _productId,
                decoration:
                    const InputDecoration(labelText: 'Output product'),
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
              decoration: const InputDecoration(labelText: 'Recipe name'),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Make this the active recipe'),
              value: _activate,
              onChanged: (v) => setState(() => _activate = v),
            ),
            const Spacer(),
            FilledButton(
              onPressed: _save,
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final productId = _productId;
    if (productId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Choose an output product.')));
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
