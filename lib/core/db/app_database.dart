import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'core_tables.dart';
import '../../features/inventory/category/data/category_table.dart';
import '../../features/inventory/category/data/category_dao.dart';
import '../../features/inventory/unit/data/unit_table.dart';
import '../../features/inventory/unit/data/unit_dao.dart';
import '../../features/inventory/product/data/product_table.dart';
import '../../features/inventory/product/data/product_dao.dart';
import '../../features/inventory/stock_movement/data/stock_movement_table.dart';
import '../../features/inventory/stock_movement/data/stock_movement_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Organizations, Users, Categories, Units, Products, StockMovements],
  daos: [CategoryDao, UnitDao, ProductDao, StockMovementDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// In-memory database for tests.
  AppDatabase.forTesting() : super(NativeDatabase.memory());

  /// On-device database for the running app.
  factory AppDatabase.open() =>
      AppDatabase(driftDatabase(name: 'inventoryhub'));

  @override
  int get schemaVersion => 1;
}
