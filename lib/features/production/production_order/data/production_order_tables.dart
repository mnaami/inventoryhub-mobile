import 'package:drift/drift.dart';

@DataClassName('ProductionOrderRow')
class ProductionOrders extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text().named('organization_id')();
  TextColumn get orderNumber => text().named('order_number')();
  TextColumn get productId => text().named('product_id')(); // output product
  TextColumn get employeeId =>
      text().named('employee_id').nullable()(); // optional attribution
  RealColumn get quantity => real()();
  TextColumn get status => text().withDefault(const Constant('planned'))();
  DateTimeColumn get startDate => dateTime().named('start_date').nullable()();
  DateTimeColumn get completionDate =>
      dateTime().named('completion_date').nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column> get primaryKey => {id};
}
