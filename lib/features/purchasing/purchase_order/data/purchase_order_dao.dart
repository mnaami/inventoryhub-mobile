import 'package:drift/drift.dart';
import '../../../../core/db/app_database.dart';
import 'purchase_order_tables.dart';

part 'purchase_order_dao.g.dart';

@DriftAccessor(tables: [PurchaseOrders, PurchaseOrderItems])
class PurchaseOrderDao extends DatabaseAccessor<AppDatabase>
    with _$PurchaseOrderDaoMixin {
  PurchaseOrderDao(super.db);

  Future<void> createWithItems(
      PurchaseOrdersCompanion order, List<PurchaseOrderItemsCompanion> items) {
    return transaction(() async {
      await into(purchaseOrders).insert(order);
      for (final it in items) {
        await into(purchaseOrderItems).insert(it);
      }
    });
  }

  Future<void> replaceItems(
    String purchaseOrderId,
    List<PurchaseOrderItemsCompanion> items, {
    required double totalAmount,
    required DateTime now,
  }) {
    return transaction(() async {
      await (delete(purchaseOrderItems)
            ..where((i) => i.purchaseOrderId.equals(purchaseOrderId)))
          .go();
      for (final it in items) {
        await into(purchaseOrderItems).insert(it);
      }
      await (update(purchaseOrders)..where((o) => o.id.equals(purchaseOrderId)))
          .write(PurchaseOrdersCompanion(
              totalAmount: Value(totalAmount), updatedAt: Value(now)));
    });
  }

  Future<PurchaseOrderRow?> byId(String id) =>
      (select(purchaseOrders)..where((o) => o.id.equals(id))).getSingleOrNull();

  Future<List<PurchaseOrderItemRow>> itemsFor(String purchaseOrderId) {
    return (select(purchaseOrderItems)
          ..where((i) => i.purchaseOrderId.equals(purchaseOrderId))
          ..orderBy([(i) => OrderingTerm(expression: i.createdAt)]))
        .get();
  }

  Future<List<PurchaseOrderRow>> paged(
    String orgId, {
    String? status,
    String? supplierId,
    required int limit,
    required int offset,
  }) {
    final q = select(purchaseOrders)
      ..where((o) => o.organizationId.equals(orgId) & o.isActive.equals(true));
    if (status != null) q.where((o) => o.status.equals(status));
    if (supplierId != null) q.where((o) => o.supplierId.equals(supplierId));
    q
      ..orderBy([
        (o) => OrderingTerm(expression: o.createdAt, mode: OrderingMode.desc)
      ])
      ..limit(limit, offset: offset);
    return q.get();
  }

  Future<void> setStatus(String id, String status, DateTime now) {
    return (update(purchaseOrders)..where((o) => o.id.equals(id))).write(
      PurchaseOrdersCompanion(status: Value(status), updatedAt: Value(now)),
    );
  }

  Future<void> setPaymentStatus(String id, String status, DateTime now) {
    return (update(purchaseOrders)..where((o) => o.id.equals(id))).write(
      PurchaseOrdersCompanion(
          paymentStatus: Value(status), updatedAt: Value(now)),
    );
  }

  Future<void> setReceiptStatus(String id, String status, DateTime now) {
    return (update(purchaseOrders)..where((o) => o.id.equals(id))).write(
      PurchaseOrdersCompanion(
          receiptStatus: Value(status), updatedAt: Value(now)),
    );
  }

  Future<void> softDelete(String id, DateTime now) {
    return (update(purchaseOrders)..where((o) => o.id.equals(id))).write(
      PurchaseOrdersCompanion(isActive: const Value(false), updatedAt: Value(now)),
    );
  }

  Future<int> countLiveForSupplier(String orgId, String supplierId) async {
    final c = countAll();
    final q = selectOnly(purchaseOrders)
      ..addColumns([c])
      ..where(purchaseOrders.organizationId.equals(orgId) &
          purchaseOrders.supplierId.equals(supplierId) &
          purchaseOrders.isActive.equals(true) &
          purchaseOrders.status.equals('cancelled').not());
    final row = await q.getSingle();
    return row.read(c) ?? 0;
  }

  Future<int> countByStatuses(String orgId, List<String> statuses) async {
    final c = countAll();
    final q = selectOnly(purchaseOrders)
      ..addColumns([c])
      ..where(purchaseOrders.organizationId.equals(orgId) &
          purchaseOrders.isActive.equals(true) &
          purchaseOrders.status.isIn(statuses));
    return (await q.getSingle()).read(c) ?? 0;
  }

  Future<int> countUnreceived(String orgId) async {
    final c = countAll();
    final q = selectOnly(purchaseOrders)
      ..addColumns([c])
      ..where(purchaseOrders.organizationId.equals(orgId) &
          purchaseOrders.isActive.equals(true) &
          purchaseOrders.status.equals('cancelled').not() &
          purchaseOrders.receiptStatus.equals('fully_received').not());
    return (await q.getSingle()).read(c) ?? 0;
  }

  Future<double> ordersTotal(String orgId) async {
    final s = purchaseOrders.totalAmount.sum();
    final q = selectOnly(purchaseOrders)
      ..addColumns([s])
      ..where(purchaseOrders.organizationId.equals(orgId) &
          purchaseOrders.isActive.equals(true) &
          purchaseOrders.status.equals('cancelled').not());
    return (await q.getSingle()).read(s) ?? 0;
  }
}
