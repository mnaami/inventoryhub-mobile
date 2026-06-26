// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_order_payment_dao.dart';

// ignore_for_file: type=lint
mixin _$SaleOrderPaymentDaoMixin on DatabaseAccessor<AppDatabase> {
  $SaleOrderPaymentsTable get saleOrderPayments =>
      attachedDatabase.saleOrderPayments;
  $SaleOrdersTable get saleOrders => attachedDatabase.saleOrders;
  SaleOrderPaymentDaoManager get managers => SaleOrderPaymentDaoManager(this);
}

class SaleOrderPaymentDaoManager {
  final _$SaleOrderPaymentDaoMixin _db;
  SaleOrderPaymentDaoManager(this._db);
  $$SaleOrderPaymentsTableTableManager get saleOrderPayments =>
      $$SaleOrderPaymentsTableTableManager(
        _db.attachedDatabase,
        _db.saleOrderPayments,
      );
  $$SaleOrdersTableTableManager get saleOrders =>
      $$SaleOrdersTableTableManager(_db.attachedDatabase, _db.saleOrders);
}
