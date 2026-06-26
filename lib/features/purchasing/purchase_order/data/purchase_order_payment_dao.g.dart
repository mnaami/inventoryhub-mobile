// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_order_payment_dao.dart';

// ignore_for_file: type=lint
mixin _$PurchaseOrderPaymentDaoMixin on DatabaseAccessor<AppDatabase> {
  $PurchaseOrderPaymentsTable get purchaseOrderPayments =>
      attachedDatabase.purchaseOrderPayments;
  $PurchaseOrdersTable get purchaseOrders => attachedDatabase.purchaseOrders;
  PurchaseOrderPaymentDaoManager get managers =>
      PurchaseOrderPaymentDaoManager(this);
}

class PurchaseOrderPaymentDaoManager {
  final _$PurchaseOrderPaymentDaoMixin _db;
  PurchaseOrderPaymentDaoManager(this._db);
  $$PurchaseOrderPaymentsTableTableManager get purchaseOrderPayments =>
      $$PurchaseOrderPaymentsTableTableManager(
        _db.attachedDatabase,
        _db.purchaseOrderPayments,
      );
  $$PurchaseOrdersTableTableManager get purchaseOrders =>
      $$PurchaseOrdersTableTableManager(
        _db.attachedDatabase,
        _db.purchaseOrders,
      );
}
