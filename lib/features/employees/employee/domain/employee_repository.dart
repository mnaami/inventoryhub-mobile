import 'employee.dart';

abstract interface class EmployeeRepository {
  Future<void> create(Employee employee);
  Future<Employee?> getById(String id);
  Future<List<Employee>> listForOrg(String orgId, {bool activeOnly});
  Future<void> update(Employee employee);
}
