import 'package:drift/drift.dart';
import '../../../../core/db/app_database.dart';
import '../domain/employee.dart';

Employee toEmployee(EmployeeRow r) => Employee(
      id: r.id,
      organizationId: r.organizationId,
      name: r.name,
      phone: r.phone,
      notes: r.notes,
      isActive: r.isActive,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
    );

EmployeesCompanion employeeInsert(Employee e) => EmployeesCompanion.insert(
      id: e.id,
      organizationId: e.organizationId,
      name: e.name,
      phone: Value(e.phone),
      notes: Value(e.notes),
      isActive: Value(e.isActive),
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
    );
