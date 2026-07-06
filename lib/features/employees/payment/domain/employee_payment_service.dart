import '../../../../core/id/id_generator.dart';
import '../../../../core/result/app_exception.dart';
import '../../../sales/sale_order/data/document_counter_dao.dart';
import '../../earning/data/production_earning_dao.dart';
import '../data/employee_payment_dao.dart';
import '../data/employee_payment_mappers.dart';
import 'employee_payment.dart';

class EmployeePaymentService {
  EmployeePaymentService({
    required EmployeePaymentDao paymentDao,
    required ProductionEarningDao earningDao,
    required DocumentCounterDao counters,
    required IdGenerator ids,
    required String organizationId,
  })  : _paymentDao = paymentDao,
        _earningDao = earningDao,
        _counters = counters,
        _ids = ids,
        _orgId = organizationId;

  final EmployeePaymentDao _paymentDao;
  final ProductionEarningDao _earningDao;
  final DocumentCounterDao _counters;
  final IdGenerator _ids;
  final String _orgId;

  Future<EmployeePayment> record({
    required String employeeId,
    required double amount,
    required DateTime paymentDate,
    String? notes,
  }) async {
    if (amount <= 0) {
      throw const ValidationException('Payment amount must be positive.');
    }
    final now = DateTime.now().toUtc();
    final number = await _counters.next(_orgId, 'employee_payment', 'EPAY');
    final payment = EmployeePayment(
      id: _ids.newId(),
      organizationId: _orgId,
      employeeId: employeeId,
      paymentNumber: number,
      amount: amount,
      paymentDate: paymentDate,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
    await _paymentDao.createRow(employeePaymentInsert(payment));
    return payment;
  }

  Future<double> balanceFor(String employeeId) async {
    final earned = await _earningDao.totalForEmployee(_orgId, employeeId);
    final paid = await _paymentDao.paidTotalForEmployee(_orgId, employeeId);
    return earned - paid;
  }

  Future<List<EmployeePayment>> paymentsFor(String employeeId) async {
    final rows = await _paymentDao.paymentsFor(employeeId);
    return rows.map(toEmployeePayment).toList();
  }
}
