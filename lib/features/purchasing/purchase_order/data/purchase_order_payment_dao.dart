import 'package:drift/drift.dart';
import '../../../../core/db/app_database.dart';
import 'purchase_order_tables.dart';

part 'purchase_order_payment_dao.g.dart';

@DriftAccessor(tables: [PurchaseOrderPayments, PurchaseOrders])
class PurchaseOrderPaymentDao extends DatabaseAccessor<AppDatabase>
    with _$PurchaseOrderPaymentDaoMixin {
  PurchaseOrderPaymentDao(super.db);

  Future<List<PurchaseOrderPaymentRow>> paymentsFor(String purchaseOrderId) {
    return (select(purchaseOrderPayments)
          ..where((p) =>
              p.purchaseOrderId.equals(purchaseOrderId) &
              p.isActive.equals(true))
          ..orderBy([(p) => OrderingTerm(expression: p.createdAt)]))
        .get();
  }

  Future<double> postedTotal(String purchaseOrderId) async {
    final sum = purchaseOrderPayments.amount.sum();
    final q = selectOnly(purchaseOrderPayments)
      ..addColumns([sum])
      ..where(purchaseOrderPayments.purchaseOrderId.equals(purchaseOrderId) &
          purchaseOrderPayments.isActive.equals(true) &
          purchaseOrderPayments.status.equals('posted'));
    final row = await q.getSingle();
    return row.read(sum) ?? 0;
  }

  Future<double> postedTotalForOrg(String orgId) async {
    final s = purchaseOrderPayments.amount.sum();
    final q = selectOnly(purchaseOrderPayments)
      ..addColumns([s])
      ..where(purchaseOrderPayments.organizationId.equals(orgId) &
          purchaseOrderPayments.isActive.equals(true) &
          purchaseOrderPayments.status.equals('posted'));
    return (await q.getSingle()).read(s) ?? 0;
  }

  Future<double> postedTotalForSupplier(String orgId, String supplierId) async {
    final s = purchaseOrderPayments.amount.sum();
    final q = selectOnly(purchaseOrderPayments).join([
      innerJoin(purchaseOrders,
          purchaseOrders.id.equalsExp(purchaseOrderPayments.purchaseOrderId)),
    ])
      ..addColumns([s])
      ..where(purchaseOrderPayments.organizationId.equals(orgId) &
          purchaseOrderPayments.isActive.equals(true) &
          purchaseOrderPayments.status.equals('posted') &
          purchaseOrders.supplierId.equals(supplierId) &
          purchaseOrders.status.equals('cancelled').not());
    return (await q.getSingle()).read(s) ?? 0;
  }

  Future<void> createDraft(PurchaseOrderPaymentsCompanion payment) =>
      into(purchaseOrderPayments).insert(payment);

  Future<void> editDraft(
    String paymentId, {
    required double amount,
    required String method,
    required DateTime paymentDate,
    required DateTime now,
  }) {
    return (update(purchaseOrderPayments)..where((p) => p.id.equals(paymentId)))
        .write(PurchaseOrderPaymentsCompanion(
      amount: Value(amount),
      method: Value(method),
      paymentDate: Value(paymentDate),
      updatedAt: Value(now),
    ));
  }

  Future<void> cancelDraft(String paymentId, DateTime now) {
    return transaction(() async {
      final existing = await (select(purchaseOrderPayments)
            ..where((p) => p.id.equals(paymentId)))
          .getSingle();
      await (update(purchaseOrderPayments)..where((p) => p.id.equals(paymentId)))
          .write(PurchaseOrderPaymentsCompanion(
        status: const Value('cancelled'),
        isActive: const Value(false),
        updatedAt: Value(now),
      ));
      await _recalc(existing.purchaseOrderId, now);
    });
  }

  Future<void> post(String paymentId, DateTime now) {
    return transaction(() async {
      final existing = await (select(purchaseOrderPayments)
            ..where((p) => p.id.equals(paymentId)))
          .getSingle();
      await (update(purchaseOrderPayments)..where((p) => p.id.equals(paymentId)))
          .write(PurchaseOrderPaymentsCompanion(
              status: const Value('posted'), updatedAt: Value(now)));
      await _recalc(existing.purchaseOrderId, now);
    });
  }

  /// Recomputes payment_status from the sum of active posted payments.
  Future<void> _recalc(String purchaseOrderId, DateTime now) async {
    final order = await (select(purchaseOrders)
          ..where((o) => o.id.equals(purchaseOrderId)))
        .getSingle();
    final paid = await postedTotal(purchaseOrderId);
    final status = paid <= 0
        ? 'not_paid'
        : (paid >= order.totalAmount ? 'paid' : 'partial');
    await (update(purchaseOrders)..where((o) => o.id.equals(purchaseOrderId)))
        .write(PurchaseOrdersCompanion(
            paymentStatus: Value(status), updatedAt: Value(now)));
  }
}
