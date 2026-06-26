import 'package:drift/drift.dart';

@DataClassName('CustomerRow')
class Customers extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text().named('organization_id')();
  TextColumn get name => text()();
  TextColumn get email => text().nullable()();
  TextColumn get phones => text().nullable()(); // JSON-encoded array
  TextColumn get address => text().nullable()();
  IntColumn get paymentTerms =>
      integer().named('payment_terms').withDefault(const Constant(30))();
  RealColumn get creditLimit => real().named('credit_limit').nullable()();
  TextColumn get imagePath => text().named('image_path').nullable()();
  BoolColumn get isActive =>
      boolean().named('is_active').withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column> get primaryKey => {id};
}
