import 'package:drift/drift.dart';

@DataClassName('SupplierRow')
class Suppliers extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text().named('organization_id')();
  TextColumn get name => text()();
  TextColumn get contactPerson => text().named('contact_person').nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get phones => text().nullable()(); // JSON-encoded array
  TextColumn get address => text().nullable()();
  IntColumn get paymentTerms =>
      integer().named('payment_terms').withDefault(const Constant(30))();
  RealColumn get creditLimit => real().named('credit_limit').nullable()();
  BoolColumn get isActive =>
      boolean().named('is_active').withDefault(const Constant(true))();
  BoolColumn get isSample =>
      boolean().named('is_sample').withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column> get primaryKey => {id};
}
