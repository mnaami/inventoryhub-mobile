import 'package:drift/drift.dart';

@DataClassName('DocumentCounterRow')
class DocumentCounters extends Table {
  TextColumn get organizationId => text().named('organization_id')();
  TextColumn get entityType => text().named('entity_type')();
  IntColumn get nextSeq => integer().named('next_seq').withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {organizationId, entityType};
}
