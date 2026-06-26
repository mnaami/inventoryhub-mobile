// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_order_dao.dart';

// ignore_for_file: type=lint
mixin _$SaleOrderDaoMixin on DatabaseAccessor<AppDatabase> {
  $SaleOrdersTable get saleOrders => attachedDatabase.saleOrders;
  $SaleOrderItemsTable get saleOrderItems => attachedDatabase.saleOrderItems;
  SaleOrderDaoManager get managers => SaleOrderDaoManager(this);
}

class SaleOrderDaoManager {
  final _$SaleOrderDaoMixin _db;
  SaleOrderDaoManager(this._db);
  $$SaleOrdersTableTableManager get saleOrders =>
      $$SaleOrdersTableTableManager(_db.attachedDatabase, _db.saleOrders);
  $$SaleOrderItemsTableTableManager get saleOrderItems =>
      $$SaleOrderItemsTableTableManager(
        _db.attachedDatabase,
        _db.saleOrderItems,
      );
}
