import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers.dart';
import '../../../sales/sale_order/data/document_counter_dao.dart';
import '../../earning/data/production_earning_dao.dart';
import '../../payment/data/employee_payment_dao.dart';
import '../../payment/domain/employee_payment_service.dart';
import '../../rate/data/production_pay_rate_dao.dart';
import '../../rate/domain/production_pay_rate_service.dart';
import '../data/employee_dao.dart';
import '../data/employee_repository_impl.dart';
import '../domain/employee.dart';
import '../domain/employee_service.dart';

final employeeServiceProvider = Provider<EmployeeService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final session = ref.watch(sessionProvider);
  return EmployeeService(
    repository: EmployeeRepositoryImpl(EmployeeDao(db)),
    ids: ref.watch(idGeneratorProvider),
    organizationId: session.organizationId,
  );
});

final productionEarningDaoProvider = Provider<ProductionEarningDao>(
    (ref) => ProductionEarningDao(ref.watch(appDatabaseProvider)));

final employeePayRateDaoProvider = Provider<ProductionPayRateDao>(
    (ref) => ProductionPayRateDao(ref.watch(appDatabaseProvider)));

final employeePayRateServiceProvider =
    Provider<ProductionPayRateService>((ref) {
  final session = ref.watch(sessionProvider);
  return ProductionPayRateService(
    dao: ref.watch(employeePayRateDaoProvider),
    ids: ref.watch(idGeneratorProvider),
    organizationId: session.organizationId,
  );
});

final employeePaymentServiceProvider = Provider<EmployeePaymentService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final session = ref.watch(sessionProvider);
  return EmployeePaymentService(
    paymentDao: EmployeePaymentDao(db),
    earningDao: ref.watch(productionEarningDaoProvider),
    counters: DocumentCounterDao(db),
    ids: ref.watch(idGeneratorProvider),
    organizationId: session.organizationId,
  );
});

/// All employees (active + inactive), name-sorted — the service's `list()`
/// default already returns both and the DAO orders by name.
final employeeListProvider = FutureProvider<List<Employee>>(
    (ref) => ref.watch(employeeServiceProvider).list());

final employeeBalanceProvider = FutureProvider.family<double, String>(
    (ref, employeeId) =>
        ref.watch(employeePaymentServiceProvider).balanceFor(employeeId));
