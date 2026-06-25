import 'package:drift/drift.dart';
import '../../../../core/db/app_database.dart';
import 'unit_table.dart';

part 'unit_dao.g.dart';

@DriftAccessor(tables: [Units])
class UnitDao extends DatabaseAccessor<AppDatabase> with _$UnitDaoMixin {
  UnitDao(super.db);

  Future<List<UnitRow>> activeForOrg(String orgId) {
    return (select(units)
          ..where((u) => u.organizationId.equals(orgId) & u.isActive.equals(true))
          ..orderBy([(u) => OrderingTerm(expression: u.name)]))
        .get();
  }

  Future<List<UnitRow>> byType(String orgId, String type) {
    return (select(units)
          ..where((u) =>
              u.organizationId.equals(orgId) &
              u.isActive.equals(true) &
              u.unitType.equals(type)))
        .get();
  }

  Future<List<UnitRow>> baseUnits(String orgId) {
    return (select(units)
          ..where((u) =>
              u.organizationId.equals(orgId) &
              u.isActive.equals(true) &
              u.isBaseUnit.equals(true)))
        .get();
  }

  Future<UnitRow?> byId(String id) =>
      (select(units)..where((u) => u.id.equals(id))).getSingleOrNull();

  Future<void> insertRow(UnitsCompanion c) => into(units).insert(c);

  Future<void> updateRow(UnitsCompanion c) =>
      (update(units)..where((t) => t.id.equals(c.id.value))).write(c);

  Future<void> softDelete(String id, DateTime now) {
    return (update(units)..where((t) => t.id.equals(id))).write(
      UnitsCompanion(isActive: const Value(false), updatedAt: Value(now)),
    );
  }
}
