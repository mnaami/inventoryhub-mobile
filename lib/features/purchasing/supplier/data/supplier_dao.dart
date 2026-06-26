import 'package:drift/drift.dart';
import '../../../../core/db/app_database.dart';
import 'supplier_table.dart';

part 'supplier_dao.g.dart';

@DriftAccessor(tables: [Suppliers])
class SupplierDao extends DatabaseAccessor<AppDatabase>
    with _$SupplierDaoMixin {
  SupplierDao(super.db);

  Future<List<SupplierRow>> listActive(String orgId) {
    return (select(suppliers)
          ..where((s) =>
              s.organizationId.equals(orgId) & s.isActive.equals(true))
          ..orderBy([(s) => OrderingTerm(expression: s.name)]))
        .get();
  }

  Future<List<SupplierRow>> search(String orgId, String query) {
    final like = '%$query%';
    return (select(suppliers)
          ..where((s) =>
              s.organizationId.equals(orgId) &
              s.isActive.equals(true) &
              (s.name.like(like) | s.email.like(like)))
          ..orderBy([(s) => OrderingTerm(expression: s.name)]))
        .get();
  }

  Future<SupplierRow?> byId(String id) =>
      (select(suppliers)..where((s) => s.id.equals(id))).getSingleOrNull();

  Future<void> insertRow(SuppliersCompanion c) => into(suppliers).insert(c);

  Future<void> updateRow(SuppliersCompanion c) =>
      (update(suppliers)..where((t) => t.id.equals(c.id.value))).write(c);

  Future<void> softDelete(String id, DateTime now) {
    return (update(suppliers)..where((t) => t.id.equals(id))).write(
      SuppliersCompanion(isActive: const Value(false), updatedAt: Value(now)),
    );
  }
}
