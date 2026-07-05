import '../domain/employee.dart';
import '../domain/employee_repository.dart';
import 'employee_dao.dart';
import 'employee_mappers.dart';

class EmployeeRepositoryImpl implements EmployeeRepository {
  EmployeeRepositoryImpl(this._dao);
  final EmployeeDao _dao;

  @override
  Future<void> create(Employee employee) =>
      _dao.createRow(employeeInsert(employee));

  @override
  Future<Employee?> getById(String id) async {
    final r = await _dao.byId(id);
    return r == null ? null : toEmployee(r);
  }

  @override
  Future<List<Employee>> listForOrg(String orgId, {bool activeOnly = false}) async =>
      (await _dao.listForOrg(orgId, activeOnly: activeOnly)).map(toEmployee).toList();

  @override
  Future<void> update(Employee employee) =>
      _dao.updateRow(employee.id, employeeInsert(employee));
}
