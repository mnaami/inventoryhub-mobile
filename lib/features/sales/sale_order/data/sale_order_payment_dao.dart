import 'package:drift/drift.dart';
import '../../../../core/db/app_database.dart';
import 'sale_order_tables.dart';

part 'sale_order_payment_dao.g.dart';

@DriftAccessor(tables: [SaleOrderPayments, SaleOrders])
class SaleOrderPaymentDao extends DatabaseAccessor<AppDatabase>
    with _$SaleOrderPaymentDaoMixin {
  SaleOrderPaymentDao(super.db);

  Future<List<SaleOrderPaymentRow>> paymentsFor(String saleOrderId) {
    return (select(saleOrderPayments)
          ..where((p) =>
              p.saleOrderId.equals(saleOrderId) & p.isActive.equals(true))
          ..orderBy([(p) => OrderingTerm(expression: p.createdAt)]))
        .get();
  }

  Future<double> completedTotal(String saleOrderId) async {
    final sum = saleOrderPayments.amount.sum();
    final q = selectOnly(saleOrderPayments)
      ..addColumns([sum])
      ..where(saleOrderPayments.saleOrderId.equals(saleOrderId) &
          saleOrderPayments.isActive.equals(true) &
          saleOrderPayments.status.equals('completed'));
    final row = await q.getSingle();
    return row.read(sum) ?? 0;
  }

  Future<double> completedTotalForOrg(String orgId) async {
    final s = saleOrderPayments.amount.sum();
    final q = selectOnly(saleOrderPayments)
      ..addColumns([s])
      ..where(saleOrderPayments.organizationId.equals(orgId) &
          saleOrderPayments.isActive.equals(true) &
          saleOrderPayments.status.equals('completed'));
    return (await q.getSingle()).read(s) ?? 0;
  }

  Future<void> recordPayment(SaleOrderPaymentsCompanion payment) {
    return transaction(() async {
      await into(saleOrderPayments).insert(payment);
      await _recalc(payment.saleOrderId.value, payment.createdAt.value);
    });
  }

  Future<void> editPayment(
    String paymentId, {
    required double amount,
    required String method,
    required String status,
    required DateTime paymentDate,
    required DateTime now,
  }) {
    return transaction(() async {
      final existing = await (select(saleOrderPayments)
            ..where((p) => p.id.equals(paymentId)))
          .getSingle();
      await (update(saleOrderPayments)..where((p) => p.id.equals(paymentId)))
          .write(SaleOrderPaymentsCompanion(
        amount: Value(amount),
        method: Value(method),
        status: Value(status),
        paymentDate: Value(paymentDate),
        updatedAt: Value(now),
      ));
      await _recalc(existing.saleOrderId, now);
    });
  }

  Future<void> deletePayment(String paymentId, DateTime now) {
    return transaction(() async {
      final existing = await (select(saleOrderPayments)
            ..where((p) => p.id.equals(paymentId)))
          .getSingle();
      await (update(saleOrderPayments)..where((p) => p.id.equals(paymentId)))
          .write(SaleOrderPaymentsCompanion(
              isActive: const Value(false), updatedAt: Value(now)));
      await _recalc(existing.saleOrderId, now);
    });
  }

  /// Recomputes payment_status from the sum of active completed payments.
  Future<void> _recalc(String saleOrderId, DateTime now) async {
    final order = await (select(saleOrders)
          ..where((o) => o.id.equals(saleOrderId)))
        .getSingle();
    final paid = await completedTotal(saleOrderId);
    final status = paid <= 0
        ? 'not_paid'
        : (paid >= order.totalAmount ? 'paid' : 'partial');
    await (update(saleOrders)..where((o) => o.id.equals(saleOrderId))).write(
      SaleOrdersCompanion(paymentStatus: Value(status), updatedAt: Value(now)),
    );
  }
}
