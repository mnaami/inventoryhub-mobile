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

  /// Org-wide ledger of active payments joined to their order for SO number
  /// and customer id. Newest `paymentDate` first. `to` is EXCLUSIVE. Payments
  /// on cancelled orders are intentionally included.
  Future<List<({SaleOrderPaymentRow payment, String soNumber, String customerId})>>
      pagedPayments(
    String orgId, {
    String? method,
    String? status,
    DateTime? from,
    DateTime? to,
    String? search,
    required int limit,
    required int offset,
  }) async {
    final q = select(saleOrderPayments).join([
      innerJoin(
          saleOrders, saleOrders.id.equalsExp(saleOrderPayments.saleOrderId)),
    ]);
    q.where(saleOrderPayments.organizationId.equals(orgId) &
        saleOrderPayments.isActive.equals(true) &
        saleOrders.isActive.equals(true));
    if (method != null) q.where(saleOrderPayments.method.equals(method));
    if (status != null) q.where(saleOrderPayments.status.equals(status));
    if (from != null) {
      q.where(saleOrderPayments.paymentDate.isBiggerOrEqualValue(from));
    }
    if (to != null) {
      q.where(saleOrderPayments.paymentDate.isSmallerThanValue(to));
    }
    if (search != null && search.trim().isNotEmpty) {
      q.where(saleOrders.soNumber.like('%${search.trim()}%'));
    }
    q.orderBy([
      OrderingTerm(
          expression: saleOrderPayments.paymentDate, mode: OrderingMode.desc),
      OrderingTerm(
          expression: saleOrderPayments.createdAt, mode: OrderingMode.desc),
    ]);
    q.limit(limit, offset: offset);
    final rows = await q.get();
    return [
      for (final r in rows)
        (
          payment: r.readTable(saleOrderPayments),
          soNumber: r.read(saleOrders.soNumber)!,
          customerId: r.read(saleOrders.customerId)!,
        ),
    ];
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

  Future<double> completedTotalForCustomer(String orgId, String customerId) async {
    final s = saleOrderPayments.amount.sum();
    final q = selectOnly(saleOrderPayments).join([
      innerJoin(saleOrders,
          saleOrders.id.equalsExp(saleOrderPayments.saleOrderId)),
    ])
      ..addColumns([s])
      ..where(saleOrderPayments.organizationId.equals(orgId) &
          saleOrderPayments.isActive.equals(true) &
          saleOrderPayments.status.equals('completed') &
          saleOrders.customerId.equals(customerId) &
          saleOrders.status.equals('cancelled').not());
    return (await q.getSingle()).read(s) ?? 0;
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
