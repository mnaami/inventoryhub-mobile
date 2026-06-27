import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers.dart';
import '../data/production_recipe_dao.dart';
import '../data/production_recipe_repository_impl.dart';
import '../domain/production_recipe.dart';
import '../domain/production_recipe_usecases.dart';

final productionRecipeServiceProvider =
    Provider<ProductionRecipeService>((ref) {
  return ProductionRecipeService(
    repository: ProductionRecipeRepositoryImpl(
        ProductionRecipeDao(ref.watch(appDatabaseProvider))),
    ids: ref.watch(idGeneratorProvider),
    organizationId: ref.watch(sessionProvider).organizationId,
  );
});

final recipesProvider = FutureProvider<List<ProductionRecipe>>(
    (ref) => ref.watch(productionRecipeServiceProvider).listAll());

final recipeProvider = FutureProvider.family<ProductionRecipe?, String>(
    (ref, id) => ref.watch(productionRecipeServiceProvider).get(id));

final recipeItemsProvider =
    FutureProvider.family<List<ProductionRecipeItem>, String>(
        (ref, recipeId) =>
            ref.watch(productionRecipeServiceProvider).items(recipeId));

final recipesForProductProvider =
    FutureProvider.family<List<ProductionRecipe>, String>((ref, productId) =>
        ref.watch(productionRecipeServiceProvider).forProduct(productId));
