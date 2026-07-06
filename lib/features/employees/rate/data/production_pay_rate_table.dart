import 'package:drift/drift.dart';

@DataClassName('ProductionPayRateRow')
class ProductionPayRates extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text().named('organization_id')();
  TextColumn get productId => text().named('product_id')();
  // Null => the product's default rate. Set => this employee's override.
  TextColumn get employeeId => text().named('employee_id').nullable()();
  RealColumn get rate => real()();
  BoolColumn get isActive =>
      boolean().named('is_active').withDefault(const Constant(true))();
  BoolColumn get isSample =>
      boolean().named('is_sample').withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column> get primaryKey => {id};
}
