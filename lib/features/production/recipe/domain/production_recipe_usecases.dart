import '../../../../core/id/id_generator.dart';
import '../../../../core/result/app_exception.dart';
import 'production_recipe.dart';
import 'production_recipe_repository.dart';

class NewIngredient {
  const NewIngredient({
    required this.ingredientProductId,
    required this.quantityPerUnit,
    required this.unit,
  });
  final String ingredientProductId;
  final double quantityPerUnit;
  final String unit;
}

class ProductionRecipeService {
  ProductionRecipeService({
    required ProductionRecipeRepository repository,
    required IdGenerator ids,
    required String organizationId,
  })  : _repo = repository,
        _ids = ids,
        _orgId = organizationId;

  final ProductionRecipeRepository _repo;
  final IdGenerator _ids;
  final String _orgId;

  Future<List<ProductionRecipe>> listAll() => _repo.allForOrg(_orgId);
  Future<List<ProductionRecipe>> forProduct(String productId) =>
      _repo.forProduct(_orgId, productId);
  Future<ProductionRecipe?> get(String id) => _repo.getById(id);
  Future<List<ProductionRecipeItem>> items(String recipeId) =>
      _repo.itemsFor(recipeId);
  Future<ProductionRecipe?> activeFor(String productId) =>
      _repo.activeForProduct(_orgId, productId);

  Future<ProductionRecipe> create({
    required String productId,
    required String name,
    String? description,
    List<NewIngredient> ingredients = const [],
    bool activate = false,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw const ValidationException('Recipe name is required.');
    }
    if (productId.trim().isEmpty) {
      throw const ValidationException('An output product is required.');
    }
    for (final ing in ingredients) {
      if (ing.quantityPerUnit <= 0) {
        throw const ValidationException(
            'Ingredient quantity must be positive.');
      }
    }
    final now = DateTime.now().toUtc();
    final recipeId = _ids.newId();
    final recipe = ProductionRecipe(
      id: recipeId,
      organizationId: _orgId,
      productId: productId,
      name: trimmed,
      description: description,
      isActive: activate,
      isDeleted: false,
      createdAt: now,
      updatedAt: now,
    );
    final items = ingredients
        .map((ing) => ProductionRecipeItem(
              id: _ids.newId(),
              recipeId: recipeId,
              ingredientProductId: ing.ingredientProductId,
              quantityPerUnit: ing.quantityPerUnit,
              unit: ing.unit,
              createdAt: now,
              updatedAt: now,
            ))
        .toList();
    await _repo.create(recipe, items);
    if (activate) {
      // Enforce single-active even if other recipes already existed.
      await _repo.activate(recipeId);
    }
    return recipe;
  }

  Future<void> edit(ProductionRecipe recipe) {
    if (recipe.name.trim().isEmpty) {
      throw const ValidationException('Recipe name is required.');
    }
    return _repo.update(recipe.copyWith(
      name: recipe.name.trim(),
      updatedAt: DateTime.now().toUtc(),
    ));
  }

  Future<void> activate(String recipeId) => _repo.activate(recipeId);

  Future<void> delete(String recipeId) => _repo.softDelete(recipeId);

  Future<void> addIngredient(
    String recipeId, {
    required String ingredientProductId,
    required double quantityPerUnit,
    required String unit,
  }) {
    if (quantityPerUnit <= 0) {
      throw const ValidationException('Ingredient quantity must be positive.');
    }
    final now = DateTime.now().toUtc();
    return _repo.addItem(ProductionRecipeItem(
      id: _ids.newId(),
      recipeId: recipeId,
      ingredientProductId: ingredientProductId,
      quantityPerUnit: quantityPerUnit,
      unit: unit,
      createdAt: now,
      updatedAt: now,
    ));
  }

  Future<void> editIngredient(
    String itemId, {
    required double quantityPerUnit,
    required String unit,
  }) {
    if (quantityPerUnit <= 0) {
      throw const ValidationException('Ingredient quantity must be positive.');
    }
    return _repo.updateItem(itemId,
        quantityPerUnit: quantityPerUnit, unit: unit);
  }

  Future<void> removeIngredient(String itemId) => _repo.removeItem(itemId);
}
