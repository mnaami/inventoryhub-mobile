// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_movement_dao.dart';

// ignore_for_file: type=lint
mixin _$StockMovementDaoMixin on DatabaseAccessor<AppDatabase> {
  $StockMovementsTable get stockMovements => attachedDatabase.stockMovements;
  $ProductsTable get products => attachedDatabase.products;
  StockMovementDaoManager get managers => StockMovementDaoManager(this);
}

class StockMovementDaoManager {
  final _$StockMovementDaoMixin _db;
  StockMovementDaoManager(this._db);
  $$StockMovementsTableTableManager get stockMovements =>
      $$StockMovementsTableTableManager(
        _db.attachedDatabase,
        _db.stockMovements,
      );
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db.attachedDatabase, _db.products);
}
