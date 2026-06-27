// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'production_order_dao.dart';

// ignore_for_file: type=lint
mixin _$ProductionOrderDaoMixin on DatabaseAccessor<AppDatabase> {
  $ProductionOrdersTable get productionOrders =>
      attachedDatabase.productionOrders;
  $ProductionRecipesTable get productionRecipes =>
      attachedDatabase.productionRecipes;
  $ProductionRecipeItemsTable get productionRecipeItems =>
      attachedDatabase.productionRecipeItems;
  $ProductsTable get products => attachedDatabase.products;
  $StockMovementsTable get stockMovements => attachedDatabase.stockMovements;
  ProductionOrderDaoManager get managers => ProductionOrderDaoManager(this);
}

class ProductionOrderDaoManager {
  final _$ProductionOrderDaoMixin _db;
  ProductionOrderDaoManager(this._db);
  $$ProductionOrdersTableTableManager get productionOrders =>
      $$ProductionOrdersTableTableManager(
        _db.attachedDatabase,
        _db.productionOrders,
      );
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
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db.attachedDatabase, _db.products);
  $$StockMovementsTableTableManager get stockMovements =>
      $$StockMovementsTableTableManager(
        _db.attachedDatabase,
        _db.stockMovements,
      );
}
