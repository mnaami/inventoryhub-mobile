import 'package:drift/drift.dart';
import '../../../../core/db/app_database.dart';
import 'customer_table.dart';

part 'customer_dao.g.dart';

@DriftAccessor(tables: [Customers])
class CustomerDao extends DatabaseAccessor<AppDatabase>
    with _$CustomerDaoMixin {
  CustomerDao(super.db);

  Future<List<CustomerRow>> listActive(String orgId) {
    return (select(customers)
          ..where((c) =>
              c.organizationId.equals(orgId) & c.isActive.equals(true))
          ..orderBy([(c) => OrderingTerm(expression: c.name)]))
        .get();
  }

  Future<List<CustomerRow>> search(String orgId, String query) {
    final like = '%$query%';
    return (select(customers)
          ..where((c) =>
              c.organizationId.equals(orgId) &
              c.isActive.equals(true) &
              (c.name.like(like) | c.email.like(like)))
          ..orderBy([(c) => OrderingTerm(expression: c.name)]))
        .get();
  }

  Future<CustomerRow?> byId(String id) =>
      (select(customers)..where((c) => c.id.equals(id))).getSingleOrNull();

  Future<void> insertRow(CustomersCompanion c) => into(customers).insert(c);

  Future<void> updateRow(CustomersCompanion c) =>
      (update(customers)..where((t) => t.id.equals(c.id.value))).write(c);

  Future<void> softDelete(String id, DateTime now) {
    return (update(customers)..where((t) => t.id.equals(id))).write(
      CustomersCompanion(isActive: const Value(false), updatedAt: Value(now)),
    );
  }
}
