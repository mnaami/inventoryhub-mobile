import 'package:drift/drift.dart';

@DataClassName('UnitRow')
class Units extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text().named('organization_id')();
  TextColumn get name => text()();
  TextColumn get symbol => text()();
  TextColumn get unitType => text().named('unit_type')();
  BoolColumn get isBaseUnit =>
      boolean().named('is_base_unit').withDefault(const Constant(false))();
  TextColumn get baseUnitId => text().named('base_unit_id').nullable()();
  RealColumn get conversionFactor =>
      real().named('conversion_factor').withDefault(const Constant(1.0))();
  BoolColumn get isActive =>
      boolean().named('is_active').withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {organizationId, name},
        {organizationId, symbol},
      ];
}
