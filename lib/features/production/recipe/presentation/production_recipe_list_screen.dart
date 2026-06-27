import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/async_value_view.dart';
import 'add_edit_recipe_screen.dart';
import 'production_recipe_detail_screen.dart';
import 'production_recipe_providers.dart';

class ProductionRecipeListScreen extends ConsumerWidget {
  const ProductionRecipeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipes = ref.watch(recipesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Recipes')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const AddEditRecipeScreen())),
        child: const Icon(Icons.add),
      ),
      body: AsyncValueView(
        value: recipes,
        data: (list) => list.isEmpty
            ? const Center(child: Text('No recipes yet. Tap + to add one.'))
            : ListView.builder(
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final r = list[i];
                  return ListTile(
                    title: Text(r.name),
                    subtitle: Text(r.isActive ? 'Active' : 'Inactive'),
                    trailing: r.isActive
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : null,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) =>
                            ProductionRecipeDetailScreen(recipeId: r.id))),
                  );
                },
              ),
      ),
    );
  }
}
