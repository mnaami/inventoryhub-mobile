import '../../../../core/id/id_generator.dart';
import '../../../../core/result/app_exception.dart';
import 'employee.dart';
import 'employee_repository.dart';

class EmployeeService {
  EmployeeService({
    required EmployeeRepository repository,
    required IdGenerator ids,
    required String organizationId,
  })  : _repo = repository,
        _ids = ids,
        _orgId = organizationId;

  final EmployeeRepository _repo;
  final IdGenerator _ids;
  final String _orgId;

  Future<Employee?> get(String id) => _repo.getById(id);

  Future<List<Employee>> list({bool activeOnly = false}) =>
      _repo.listForOrg(_orgId, activeOnly: activeOnly);

  Future<Employee> create({
    required String name,
    String? phone,
    String? notes,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw const ValidationException('Employee name is required.');
    }
    final now = DateTime.now().toUtc();
    final employee = Employee(
      id: _ids.newId(),
      organizationId: _orgId,
      name: trimmed,
      phone: phone,
      notes: notes,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );
    await _repo.create(employee);
    return employee;
  }

  Future<Employee> edit(Employee employee) {
    final trimmed = employee.name.trim();
    if (trimmed.isEmpty) {
      throw const ValidationException('Employee name is required.');
    }
    final updated = employee.copyWith(
      name: trimmed,
      updatedAt: DateTime.now().toUtc(),
    );
    return _repo.update(updated).then((_) => updated);
  }

  Future<void> setActive(String id, bool active) async {
    final employee = await _repo.getById(id);
    if (employee == null) {
      throw const NotFoundException('Employee not found.');
    }
    await _repo.update(employee.copyWith(
      isActive: active,
      updatedAt: DateTime.now().toUtc(),
    ));
  }
}
