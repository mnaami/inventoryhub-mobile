// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_order_receipt_dao.dart';

// ignore_for_file: type=lint
mixin _$PurchaseOrderReceiptDaoMixin on DatabaseAccessor<AppDatabase> {
  $PurchaseOrderReceiptsTable get purchaseOrderReceipts =>
      attachedDatabase.purchaseOrderReceipts;
  $PurchaseOrderReceiptItemsTable get purchaseOrderReceiptItems =>
      attachedDatabase.purchaseOrderReceiptItems;
  $PurchaseOrderItemsTable get purchaseOrderItems =>
      attachedDatabase.purchaseOrderItems;
  $PurchaseOrdersTable get purchaseOrders => attachedDatabase.purchaseOrders;
  $ProductsTable get products => attachedDatabase.products;
  $StockMovementsTable get stockMovements => attachedDatabase.stockMovements;
  PurchaseOrderReceiptDaoManager get managers =>
      PurchaseOrderReceiptDaoManager(this);
}

class PurchaseOrderReceiptDaoManager {
  final _$PurchaseOrderReceiptDaoMixin _db;
  PurchaseOrderReceiptDaoManager(this._db);
  $$PurchaseOrderReceiptsTableTableManager get purchaseOrderReceipts =>
      $$PurchaseOrderReceiptsTableTableManager(
        _db.attachedDatabase,
        _db.purchaseOrderReceipts,
      );
  $$PurchaseOrderReceiptItemsTableTableManager get purchaseOrderReceiptItems =>
      $$PurchaseOrderReceiptItemsTableTableManager(
        _db.attachedDatabase,
        _db.purchaseOrderReceiptItems,
      );
  $$PurchaseOrderItemsTableTableManager get purchaseOrderItems =>
      $$PurchaseOrderItemsTableTableManager(
        _db.attachedDatabase,
        _db.purchaseOrderItems,
      );
  $$PurchaseOrdersTableTableManager get purchaseOrders =>
      $$PurchaseOrdersTableTableManager(
        _db.attachedDatabase,
        _db.purchaseOrders,
      );
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db.attachedDatabase, _db.products);
  $$StockMovementsTableTableManager get stockMovements =>
      $$StockMovementsTableTableManager(
        _db.attachedDatabase,
        _db.stockMovements,
      );
}
