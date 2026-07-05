import 'package:drift/drift.dart';
import '../../../../core/db/app_database.dart';
import '../domain/employee_payment.dart';

EmployeePayment toEmployeePayment(EmployeePaymentRow r) => EmployeePayment(
      id: r.id,
      organizationId: r.organizationId,
      employeeId: r.employeeId,
      paymentNumber: r.paymentNumber,
      amount: r.amount,
      paymentDate: r.paymentDate,
      notes: r.notes,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
    );

EmployeePaymentsCompanion employeePaymentInsert(EmployeePayment p) =>
    EmployeePaymentsCompanion.insert(
      id: p.id,
      organizationId: p.organizationId,
      employeeId: p.employeeId,
      paymentNumber: p.paymentNumber,
      amount: p.amount,
      paymentDate: p.paymentDate,
      notes: Value(p.notes),
      createdAt: p.createdAt,
      updatedAt: p.updatedAt,
    );
