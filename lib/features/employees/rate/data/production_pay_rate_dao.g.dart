// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'production_pay_rate_dao.dart';

// ignore_for_file: type=lint
mixin _$ProductionPayRateDaoMixin on DatabaseAccessor<AppDatabase> {
  $ProductionPayRatesTable get productionPayRates =>
      attachedDatabase.productionPayRates;
  ProductionPayRateDaoManager get managers => ProductionPayRateDaoManager(this);
}

class ProductionPayRateDaoManager {
  final _$ProductionPayRateDaoMixin _db;
  ProductionPayRateDaoManager(this._db);
  $$ProductionPayRatesTableTableManager get productionPayRates =>
      $$ProductionPayRatesTableTableManager(
        _db.attachedDatabase,
        _db.productionPayRates,
      );
}
