import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/db/app_database.dart';
import '../../../../core/providers.dart';
import '../../payment/domain/employee_payment.dart';
import '../domain/employee.dart';
import 'employee_providers.dart';

/// A single employee by id — `null` if not found.
final employeeProvider = FutureProvider.family<Employee?, String>(
    (ref, id) => ref.watch(employeeServiceProvider).get(id));

/// This employee's production earnings (product/qty/rate/amount rows),
/// newest first (per the DAO's ordering).
final employeeEarningsProvider =
    FutureProvider.family<List<ProductionEarningRow>, String>((ref, id) {
  final session = ref.watch(sessionProvider);
  return ref
      .watch(productionEarningDaoProvider)
      .earningsForEmployee(session.organizationId, id);
});

/// This employee's recorded payments, newest first.
final employeePaymentsProvider =
    FutureProvider.family<List<EmployeePayment>, String>(
        (ref, id) => ref.watch(employeePaymentServiceProvider).paymentsFor(id));

/// This employee's active piece-rate overrides (excludes deactivated rows —
/// `ratesForEmployee` returns the full history including removed overrides).
final employeeRatesProvider =
    FutureProvider.family<List<ProductionPayRateRow>, String>((ref, id) async {
  final session = ref.watch(sessionProvider);
  final rows = await ref
      .watch(employeePayRateDaoProvider)
      .ratesForEmployee(session.organizationId, id);
  return rows.where((r) => r.isActive).toList();
});

/// The product's default (non-employee) piece rate, shown as a hint when
/// adding/editing an employee override. `null` if no default is set.
final productDefaultRateProvider =
    FutureProvider.family<ProductionPayRateRow?, String>((ref, productId) {
  final session = ref.watch(sessionProvider);
  return ref
      .watch(employeePayRateDaoProvider)
      .defaultForProduct(session.organizationId, productId);
});
