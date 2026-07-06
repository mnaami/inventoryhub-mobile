// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'production_earning_dao.dart';

// ignore_for_file: type=lint
mixin _$ProductionEarningDaoMixin on DatabaseAccessor<AppDatabase> {
  $ProductionEarningsTable get productionEarnings =>
      attachedDatabase.productionEarnings;
  ProductionEarningDaoManager get managers => ProductionEarningDaoManager(this);
}

class ProductionEarningDaoManager {
  final _$ProductionEarningDaoMixin _db;
  ProductionEarningDaoManager(this._db);
  $$ProductionEarningsTableTableManager get productionEarnings =>
      $$ProductionEarningsTableTableManager(
        _db.attachedDatabase,
        _db.productionEarnings,
      );
}
