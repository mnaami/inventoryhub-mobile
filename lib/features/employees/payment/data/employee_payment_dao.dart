import 'package:drift/drift.dart';
import '../../../../core/db/app_database.dart';
import 'employee_payment_table.dart';

part 'employee_payment_dao.g.dart';

@DriftAccessor(tables: [EmployeePayments])
class EmployeePaymentDao extends DatabaseAccessor<AppDatabase>
    with _$EmployeePaymentDaoMixin {
  EmployeePaymentDao(super.db);

  Future<void> createRow(EmployeePaymentsCompanion payment) =>
      into(employeePayments).insert(payment);

  Future<List<EmployeePaymentRow>> paymentsFor(String employeeId) =>
      (select(employeePayments)
            ..where((p) =>
                p.employeeId.equals(employeeId) & p.isActive.equals(true))
            ..orderBy([
              (p) => OrderingTerm(
                  expression: p.paymentDate, mode: OrderingMode.desc)
            ]))
          .get();

  Future<double> paidTotalForEmployee(String orgId, String employeeId) async {
    final sum = employeePayments.amount.sum();
    final q = selectOnly(employeePayments)
      ..addColumns([sum])
      ..where(employeePayments.organizationId.equals(orgId) &
          employeePayments.employeeId.equals(employeeId) &
          employeePayments.isActive.equals(true));
    return (await q.getSingle()).read(sum) ?? 0.0;
  }

  Future<void> cancel(String id, DateTime now) =>
      (update(employeePayments)..where((p) => p.id.equals(id))).write(
        EmployeePaymentsCompanion(
          isActive: const Value(false),
          updatedAt: Value(now),
        ),
      );
}
