import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/db/app_database.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/core/result/app_exception.dart';
import 'package:inventoryhub_mobile/features/employees/earning/data/production_earning_dao.dart';
import 'package:inventoryhub_mobile/features/employees/payment/data/employee_payment_dao.dart';
import 'package:inventoryhub_mobile/features/employees/payment/domain/employee_payment_service.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/data/document_counter_dao.dart';
import '../../helpers/test_db.dart';

void main() {
  late AppDatabase db;
  late ProductionEarningDao earningDao;
  late EmployeePaymentDao paymentDao;
  late DocumentCounterDao counters;
  late EmployeePaymentService paymentService;
  const orgId = 'org1';
  const employeeId = 'emp1';
  final aDate = DateTime.utc(2026, 1, 1);

  setUp(() {
    db = newTestDb();
    earningDao = ProductionEarningDao(db);
    paymentDao = EmployeePaymentDao(db);
    counters = DocumentCounterDao(db);
    paymentService = EmployeePaymentService(
      paymentDao: paymentDao,
      earningDao: earningDao,
      counters: counters,
      ids: const IdGenerator(),
      organizationId: orgId,
    );
  });
  tearDown(() => db.close());

  test('balance = earned - paid; overpayment allowed (negative balance)',
      () async {
    await earningDao.into(earningDao.productionEarnings).insert(
          ProductionEarningsCompanion.insert(
            id: 'earn1',
            organizationId: orgId,
            productionOrderId: 'order1',
            employeeId: employeeId,
            productId: 'prod1',
            quantity: 4.0,
            rate: 3.0,
            amount: 12.0,
            createdAt: aDate,
            updatedAt: aDate,
          ),
        );
    expect(await paymentService.balanceFor(employeeId), 12.0);

    await paymentService.record(
      employeeId: employeeId,
      amount: 20.0,
      paymentDate: aDate,
    );
    expect(await paymentService.balanceFor(employeeId), -8.0); // overpaid, allowed
  });

  test('record rejects non-positive amount and assigns EPAY number', () async {
    expect(
      () => paymentService.record(
        employeeId: employeeId,
        amount: 0,
        paymentDate: aDate,
      ),
      throwsA(isA<ValidationException>()),
    );
    final p = await paymentService.record(
      employeeId: employeeId,
      amount: 5,
      paymentDate: aDate,
    );
    expect(p.paymentNumber, startsWith('EPAY-'));
  });
}
