import 'package:drift/drift.dart';
import '../../../../core/db/app_database.dart';
import 'production_recipe_tables.dart';

part 'production_recipe_dao.g.dart';

@DriftAccessor(tables: [ProductionRecipes, ProductionRecipeItems])
class ProductionRecipeDao extends DatabaseAccessor<AppDatabase>
    with _$ProductionRecipeDaoMixin {
  ProductionRecipeDao(super.db);

  Future<void> createWithItems(
    ProductionRecipesCompanion recipe,
    List<ProductionRecipeItemsCompanion> items,
  ) {
    return transaction(() async {
      await into(productionRecipes).insert(recipe);
      for (final it in items) {
        await into(productionRecipeItems).insert(it);
      }
    });
  }

  Future<ProductionRecipeRow?> byId(String id) =>
      (select(productionRecipes)
            ..where((r) => r.id.equals(id) & r.isDeleted.equals(false)))
          .getSingleOrNull();

  Future<List<ProductionRecipeRow>> allForOrg(String orgId) {
    return (select(productionRecipes)
          ..where((r) =>
              r.organizationId.equals(orgId) & r.isDeleted.equals(false))
          ..orderBy([(r) => OrderingTerm(expression: r.name)]))
        .get();
  }

  Future<List<ProductionRecipeRow>> forProduct(String orgId, String productId) {
    return (select(productionRecipes)
          ..where((r) =>
              r.organizationId.equals(orgId) &
              r.productId.equals(productId) &
              r.isDeleted.equals(false))
          ..orderBy([(r) => OrderingTerm(expression: r.name)]))
        .get();
  }

  Future<ProductionRecipeRow?> activeForProduct(
      String orgId, String productId) {
    return (select(productionRecipes)
          ..where((r) =>
              r.organizationId.equals(orgId) &
              r.productId.equals(productId) &
              r.isActive.equals(true) &
              r.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  Future<List<ProductionRecipeItemRow>> itemsFor(String recipeId) {
    return (select(productionRecipeItems)
          ..where((i) => i.recipeId.equals(recipeId))
          ..orderBy([(i) => OrderingTerm(expression: i.createdAt)]))
        .get();
  }

  /// Activates [recipeId] and deactivates every other non-deleted recipe for
  /// the same product, in one transaction.
  Future<void> activate(String recipeId, DateTime now) {
    return transaction(() async {
      final recipe = await (select(productionRecipes)
            ..where((r) => r.id.equals(recipeId)))
          .getSingle();
      await (update(productionRecipes)
            ..where((r) =>
                r.organizationId.equals(recipe.organizationId) &
                r.productId.equals(recipe.productId)))
          .write(ProductionRecipesCompanion(
              isActive: const Value(false), updatedAt: Value(now)));
      await (update(productionRecipes)..where((r) => r.id.equals(recipeId)))
          .write(ProductionRecipesCompanion(
              isActive: const Value(true), updatedAt: Value(now)));
    });
  }

  Future<void> updateRow(ProductionRecipesCompanion c) =>
      (update(productionRecipes)..where((r) => r.id.equals(c.id.value)))
          .write(c);

  Future<void> softDelete(String id, DateTime now) {
    return (update(productionRecipes)..where((r) => r.id.equals(id))).write(
      ProductionRecipesCompanion(
        isActive: const Value(false),
        isDeleted: const Value(true),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> addItem(ProductionRecipeItemsCompanion c) =>
      into(productionRecipeItems).insert(c);

  Future<void> updateItem(ProductionRecipeItemsCompanion c) =>
      (update(productionRecipeItems)..where((i) => i.id.equals(c.id.value)))
          .write(c);

  Future<void> removeItem(String id) =>
      (delete(productionRecipeItems)..where((i) => i.id.equals(id))).go();
}
