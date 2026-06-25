import 'package:drift/drift.dart';

@DataClassName('StockMovementRow')
class StockMovements extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text().named('organization_id')();
  TextColumn get productId => text().named('product_id')();
  TextColumn get movementType => text().named('movement_type')();
  RealColumn get quantity => real()(); // signed
  TextColumn get referenceType => text().named('reference_type').nullable()();
  TextColumn get referenceId => text().named('reference_id').nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get createdBy => text().named('created_by')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();

  @override
  Set<Column> get primaryKey => {id};
}
