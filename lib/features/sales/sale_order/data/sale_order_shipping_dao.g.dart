// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_order_shipping_dao.dart';

// ignore_for_file: type=lint
mixin _$SaleOrderShippingDaoMixin on DatabaseAccessor<AppDatabase> {
  $SaleOrderShippingsTable get saleOrderShippings =>
      attachedDatabase.saleOrderShippings;
  $SaleOrderShippingItemsTable get saleOrderShippingItems =>
      attachedDatabase.saleOrderShippingItems;
  $SaleOrderItemsTable get saleOrderItems => attachedDatabase.saleOrderItems;
  $SaleOrdersTable get saleOrders => attachedDatabase.saleOrders;
  $ProductsTable get products => attachedDatabase.products;
  $StockMovementsTable get stockMovements => attachedDatabase.stockMovements;
  SaleOrderShippingDaoManager get managers => SaleOrderShippingDaoManager(this);
}

class SaleOrderShippingDaoManager {
  final _$SaleOrderShippingDaoMixin _db;
  SaleOrderShippingDaoManager(this._db);
  $$SaleOrderShippingsTableTableManager get saleOrderShippings =>
      $$SaleOrderShippingsTableTableManager(
        _db.attachedDatabase,
        _db.saleOrderShippings,
      );
  $$SaleOrderShippingItemsTableTableManager get saleOrderShippingItems =>
      $$SaleOrderShippingItemsTableTableManager(
        _db.attachedDatabase,
        _db.saleOrderShippingItems,
      );
  $$SaleOrderItemsTableTableManager get saleOrderItems =>
      $$SaleOrderItemsTableTableManager(
        _db.attachedDatabase,
        _db.saleOrderItems,
      );
  $$SaleOrdersTableTableManager get saleOrders =>
      $$SaleOrdersTableTableManager(_db.attachedDatabase, _db.saleOrders);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db.attachedDatabase, _db.products);
  $$StockMovementsTableTableManager get stockMovements =>
      $$StockMovementsTableTableManager(
        _db.attachedDatabase,
        _db.stockMovements,
      );
}
