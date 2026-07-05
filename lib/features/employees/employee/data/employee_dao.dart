import 'package:drift/drift.dart';
import '../../../../core/db/app_database.dart';
import 'employee_table.dart';

part 'employee_dao.g.dart';

@DriftAccessor(tables: [Employees])
class EmployeeDao extends DatabaseAccessor<AppDatabase>
    with _$EmployeeDaoMixin {
  EmployeeDao(super.db);

  Future<void> createRow(EmployeesCompanion employee) =>
      into(employees).insert(employee);

  Future<EmployeeRow?> byId(String id) =>
      (select(employees)..where((e) => e.id.equals(id))).getSingleOrNull();

  Future<List<EmployeeRow>> listForOrg(String orgId, {bool activeOnly = false}) {
    final q = select(employees)..where((e) => e.organizationId.equals(orgId));
    if (activeOnly) {
      q.where((e) => e.isActive.equals(true));
    }
    q.orderBy([(e) => OrderingTerm(expression: e.name)]);
    return q.get();
  }

  Future<void> updateRow(String id, EmployeesCompanion employee) =>
      (update(employees)..where((e) => e.id.equals(id))).write(employee);
}
