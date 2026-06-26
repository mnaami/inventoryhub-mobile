import 'package:drift/drift.dart';
import '../../../../core/db/app_database.dart';
import 'sale_order_tables.dart';

part 'sale_order_dao.g.dart';

@DriftAccessor(tables: [SaleOrders, SaleOrderItems])
class SaleOrderDao extends DatabaseAccessor<AppDatabase>
    with _$SaleOrderDaoMixin {
  SaleOrderDao(super.db);

  Future<void> createWithItems(
      SaleOrdersCompanion order, List<SaleOrderItemsCompanion> items) {
    return transaction(() async {
      await into(saleOrders).insert(order);
      for (final it in items) {
        await into(saleOrderItems).insert(it);
      }
    });
  }

  Future<void> replaceItems(
    String saleOrderId,
    List<SaleOrderItemsCompanion> items, {
    required double totalAmount,
    required DateTime now,
  }) {
    return transaction(() async {
      await (delete(saleOrderItems)
            ..where((i) => i.saleOrderId.equals(saleOrderId)))
          .go();
      for (final it in items) {
        await into(saleOrderItems).insert(it);
      }
      await (update(saleOrders)..where((o) => o.id.equals(saleOrderId))).write(
        SaleOrdersCompanion(
            totalAmount: Value(totalAmount), updatedAt: Value(now)),
      );
    });
  }

  Future<SaleOrderRow?> byId(String id) =>
      (select(saleOrders)..where((o) => o.id.equals(id))).getSingleOrNull();

  Future<List<SaleOrderItemRow>> itemsFor(String saleOrderId) {
    return (select(saleOrderItems)
          ..where((i) => i.saleOrderId.equals(saleOrderId))
          ..orderBy([(i) => OrderingTerm(expression: i.createdAt)]))
        .get();
  }

  Future<List<SaleOrderRow>> paged(
    String orgId, {
    String? status,
    String? customerId,
    required int limit,
    required int offset,
  }) {
    final q = select(saleOrders)
      ..where((o) => o.organizationId.equals(orgId) & o.isActive.equals(true));
    if (status != null) q.where((o) => o.status.equals(status));
    if (customerId != null) q.where((o) => o.customerId.equals(customerId));
    q
      ..orderBy([
        (o) => OrderingTerm(expression: o.createdAt, mode: OrderingMode.desc)
      ])
      ..limit(limit, offset: offset);
    return q.get();
  }

  Future<void> setStatus(String id, String status, DateTime now) {
    return (update(saleOrders)..where((o) => o.id.equals(id))).write(
      SaleOrdersCompanion(status: Value(status), updatedAt: Value(now)),
    );
  }

  Future<void> setPaymentStatus(String id, String status, DateTime now) {
    return (update(saleOrders)..where((o) => o.id.equals(id))).write(
      SaleOrdersCompanion(paymentStatus: Value(status), updatedAt: Value(now)),
    );
  }

  Future<void> softDelete(String id, DateTime now) {
    return (update(saleOrders)..where((o) => o.id.equals(id))).write(
      SaleOrdersCompanion(isActive: const Value(false), updatedAt: Value(now)),
    );
  }

  Future<int> countLiveForCustomer(String orgId, String customerId) async {
    final c = countAll();
    final q = selectOnly(saleOrders)
      ..addColumns([c])
      ..where(saleOrders.organizationId.equals(orgId) &
          saleOrders.customerId.equals(customerId) &
          saleOrders.isActive.equals(true) &
          saleOrders.status.equals('cancelled').not());
    final row = await q.getSingle();
    return row.read(c) ?? 0;
  }
}
