import 'production_recipe.dart';

abstract interface class ProductionRecipeRepository {
  Future<void> create(
      ProductionRecipe recipe, List<ProductionRecipeItem> items);
  Future<ProductionRecipe?> getById(String id);
  Future<List<ProductionRecipe>> allForOrg(String orgId);
  Future<List<ProductionRecipe>> forProduct(String orgId, String productId);
  Future<ProductionRecipe?> activeForProduct(String orgId, String productId);
  Future<List<ProductionRecipeItem>> itemsFor(String recipeId);
  Future<void> activate(String recipeId);
  Future<void> update(ProductionRecipe recipe);
  Future<void> softDelete(String id);
  Future<void> addItem(ProductionRecipeItem item);
  Future<void> updateItem(String itemId,
      {required double quantityPerUnit, required String unit});
  Future<void> removeItem(String itemId);
}
