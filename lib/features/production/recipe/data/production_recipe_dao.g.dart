// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'production_recipe_dao.dart';

// ignore_for_file: type=lint
mixin _$ProductionRecipeDaoMixin on DatabaseAccessor<AppDatabase> {
  $ProductionRecipesTable get productionRecipes =>
      attachedDatabase.productionRecipes;
  $ProductionRecipeItemsTable get productionRecipeItems =>
      attachedDatabase.productionRecipeItems;
  ProductionRecipeDaoManager get managers => ProductionRecipeDaoManager(this);
}

class ProductionRecipeDaoManager {
  final _$ProductionRecipeDaoMixin _db;
  ProductionRecipeDaoManager(this._db);
  $$ProductionRecipesTableTableManager get productionRecipes =>
      $$ProductionRecipesTableTableManager(
        _db.attachedDatabase,
        _db.productionRecipes,
      );
  $$ProductionRecipeItemsTableTableManager get productionRecipeItems =>
      $$ProductionRecipeItemsTableTableManager(
        _db.attachedDatabase,
        _db.productionRecipeItems,
      );
}
