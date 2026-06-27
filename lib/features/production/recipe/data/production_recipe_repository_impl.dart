import 'package:drift/drift.dart';
import '../../../../core/db/app_database.dart';
import '../domain/production_recipe.dart';
import '../domain/production_recipe_repository.dart';
import 'production_recipe_dao.dart';
import 'production_recipe_mappers.dart';

class ProductionRecipeRepositoryImpl implements ProductionRecipeRepository {
  ProductionRecipeRepositoryImpl(this._dao);
  final ProductionRecipeDao _dao;

  @override
  Future<void> create(
          ProductionRecipe recipe, List<ProductionRecipeItem> items) =>
      _dao.createWithItems(
          recipeInsert(recipe), items.map(recipeItemInsert).toList());

  @override
  Future<ProductionRecipe?> getById(String id) async {
    final r = await _dao.byId(id);
    return r == null ? null : toProductionRecipe(r);
  }

  @override
  Future<List<ProductionRecipe>> allForOrg(String orgId) async =>
      (await _dao.allForOrg(orgId)).map(toProductionRecipe).toList();

  @override
  Future<List<ProductionRecipe>> forProduct(
          String orgId, String productId) async =>
      (await _dao.forProduct(orgId, productId))
          .map(toProductionRecipe)
          .toList();

  @override
  Future<ProductionRecipe?> activeForProduct(
      String orgId, String productId) async {
    final r = await _dao.activeForProduct(orgId, productId);
    return r == null ? null : toProductionRecipe(r);
  }

  @override
  Future<List<ProductionRecipeItem>> itemsFor(String recipeId) async =>
      (await _dao.itemsFor(recipeId)).map(toProductionRecipeItem).toList();

  @override
  Future<void> activate(String recipeId) =>
      _dao.activate(recipeId, DateTime.now().toUtc());

  @override
  Future<void> update(ProductionRecipe recipe) =>
      _dao.updateRow(recipeUpdate(recipe));

  @override
  Future<void> softDelete(String id) =>
      _dao.softDelete(id, DateTime.now().toUtc());

  @override
  Future<void> addItem(ProductionRecipeItem item) =>
      _dao.addItem(recipeItemInsert(item));

  @override
  Future<void> updateItem(String itemId,
          {required double quantityPerUnit, required String unit}) =>
      _dao.updateItem(ProductionRecipeItemsCompanion(
        id: Value(itemId),
        quantityPerUnit: Value(quantityPerUnit),
        unit: Value(unit),
        updatedAt: Value(DateTime.now().toUtc()),
      ));

  @override
  Future<void> removeItem(String itemId) => _dao.removeItem(itemId);
}
