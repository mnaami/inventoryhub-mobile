import 'package:drift/drift.dart';

@DataClassName('ProductionEarningRow')
class ProductionEarnings extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text().named('organization_id')();
  TextColumn get productionOrderId => text().named('production_order_id')();
  TextColumn get employeeId => text().named('employee_id')();
  TextColumn get productId => text().named('product_id')();
  RealColumn get quantity => real()();
  RealColumn get rate => real()(); // snapshot at completion
  RealColumn get amount => real()(); // quantity * rate (may be 0)
  BoolColumn get isSample =>
      boolean().named('is_sample').withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column> get primaryKey => {id};
}
