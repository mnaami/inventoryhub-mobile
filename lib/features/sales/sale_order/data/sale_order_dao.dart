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
    String? search,
    String? paymentStatus,
    String? shippingStatus,
    DateTime? from,
    DateTime? to,
    required int limit,
    required int offset,
  }) {
    final q = select(saleOrders)
      ..where((o) => o.organizationId.equals(orgId) & o.isActive.equals(true));
    if (status != null) q.where((o) => o.status.equals(status));
    if (customerId != null) q.where((o) => o.customerId.equals(customerId));
    if (paymentStatus != null) {
      q.where((o) => o.paymentStatus.equals(paymentStatus));
    }
    if (shippingStatus != null) {
      q.where((o) => o.shippingStatus.equals(shippingStatus));
    }
    if (search != null && search.trim().isNotEmpty) {
      final like = '%${search.trim()}%';
      q.where((o) => o.soNumber.like(like));
    }
    if (from != null) q.where((o) => o.orderDate.isBiggerOrEqualValue(from));
    if (to != null) q.where((o) => o.orderDate.isSmallerThanValue(to));
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

  Future<int> countByStatuses(String orgId, List<String> statuses) async {
    final c = countAll();
    final q = selectOnly(saleOrders)
      ..addColumns([c])
      ..where(saleOrders.organizationId.equals(orgId) &
          saleOrders.isActive.equals(true) &
          saleOrders.status.isIn(statuses));
    return (await q.getSingle()).read(c) ?? 0;
  }

  Future<int> countUnshipped(String orgId) async {
    final c = countAll();
    final q = selectOnly(saleOrders)
      ..addColumns([c])
      ..where(saleOrders.organizationId.equals(orgId) &
          saleOrders.isActive.equals(true) &
          saleOrders.status.equals('cancelled').not() &
          saleOrders.shippingStatus.equals('fully_shipped').not());
    return (await q.getSingle()).read(c) ?? 0;
  }

  Future<double> ordersTotal(String orgId) async {
    final s = saleOrders.totalAmount.sum();
    final q = selectOnly(saleOrders)
      ..addColumns([s])
      ..where(saleOrders.organizationId.equals(orgId) &
          saleOrders.isActive.equals(true) &
          saleOrders.status.equals('cancelled').not());
    return (await q.getSingle()).read(s) ?? 0;
  }

  Future<List<SaleOrderRow>> forCustomer(String orgId, String customerId) {
    return (select(saleOrders)
          ..where((o) =>
              o.organizationId.equals(orgId) &
              o.isActive.equals(true) &
              o.customerId.equals(customerId))
          ..orderBy([
            (o) => OrderingTerm(expression: o.createdAt, mode: OrderingMode.desc)
          ]))
        .get();
  }

  Future<double> ordersTotalForCustomer(String orgId, String customerId) async {
    final s = saleOrders.totalAmount.sum();
    final q = selectOnly(saleOrders)
      ..addColumns([s])
      ..where(saleOrders.organizationId.equals(orgId) &
          saleOrders.isActive.equals(true) &
          saleOrders.customerId.equals(customerId) &
          saleOrders.status.equals('cancelled').not());
    return (await q.getSingle()).read(s) ?? 0;
  }

  Future<int> countByDateRange(String orgId, DateTime from, DateTime to) async {
    final c = countAll();
    final q = selectOnly(saleOrders)
      ..addColumns([c])
      ..where(saleOrders.organizationId.equals(orgId) &
          saleOrders.isActive.equals(true) &
          saleOrders.status.equals('cancelled').not() &
          saleOrders.orderDate.isBiggerOrEqualValue(from) &
          saleOrders.orderDate.isSmallerThanValue(to));
    return (await q.getSingle()).read(c) ?? 0;
  }

  Future<double> totalAmountByDateRange(String orgId, DateTime from, DateTime to) async {
    final s = saleOrders.totalAmount.sum();
    final q = selectOnly(saleOrders)
      ..addColumns([s])
      ..where(saleOrders.organizationId.equals(orgId) &
          saleOrders.isActive.equals(true) &
          saleOrders.status.equals('cancelled').not() &
          saleOrders.orderDate.isBiggerOrEqualValue(from) &
          saleOrders.orderDate.isSmallerThanValue(to));
    return (await q.getSingle()).read(s) ?? 0;
  }

  Future<List<SaleOrderRow>> allActive(String orgId) {
    return (select(saleOrders)
          ..where((o) => o.organizationId.equals(orgId) & o.isActive.equals(true))
          ..orderBy([
            (o) => OrderingTerm(expression: o.createdAt, mode: OrderingMode.desc)
          ]))
        .get();
  }
}

