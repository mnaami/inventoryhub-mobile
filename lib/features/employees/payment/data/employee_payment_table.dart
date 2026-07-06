import 'package:drift/drift.dart';

@DataClassName('EmployeePaymentRow')
class EmployeePayments extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text().named('organization_id')();
  TextColumn get employeeId => text().named('employee_id')();
  TextColumn get paymentNumber => text().named('payment_number')();
  RealColumn get amount => real()();
  DateTimeColumn get paymentDate => dateTime().named('payment_date')();
  TextColumn get notes => text().nullable()();
  BoolColumn get isActive =>
      boolean().named('is_active').withDefault(const Constant(true))();
  BoolColumn get isSample =>
      boolean().named('is_sample').withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column> get primaryKey => {id};
}
