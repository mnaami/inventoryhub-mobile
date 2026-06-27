import 'package:drift/drift.dart';
import '../../../../core/db/app_database.dart';
import '../../../inventory/product/data/product_table.dart';
import '../../../inventory/stock_movement/data/stock_movement_table.dart';
import '../../recipe/data/production_recipe_tables.dart';
import 'production_order_tables.dart';

part 'production_order_dao.g.dart';

@DriftAccessor(tables: [
  ProductionOrders,
  ProductionRecipes,
  ProductionRecipeItems,
  Products,
  StockMovements,
])
class ProductionOrderDao extends DatabaseAccessor<AppDatabase>
    with _$ProductionOrderDaoMixin {
  ProductionOrderDao(super.db);

  Future<void> createRow(ProductionOrdersCompanion order) =>
      into(productionOrders).insert(order);

  Future<ProductionOrderRow?> byId(String id) =>
      (select(productionOrders)..where((o) => o.id.equals(id)))
          .getSingleOrNull();

  Future<List<ProductionOrderRow>> paged(
    String orgId, {
    String? status,
    required int limit,
    required int offset,
  }) {
    final q = select(productionOrders)
      ..where((o) => o.organizationId.equals(orgId));
    if (status != null) q.where((o) => o.status.equals(status));
    q
      ..orderBy([
        (o) => OrderingTerm(expression: o.createdAt, mode: OrderingMode.desc)
      ])
      ..limit(limit, offset: offset);
    return q.get();
  }

  Future<void> start(String id, DateTime now) {
    return (update(productionOrders)..where((o) => o.id.equals(id))).write(
      ProductionOrdersCompanion(
        status: const Value('in_progress'),
        startDate: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> cancel(String id, DateTime now) {
    return (update(productionOrders)..where((o) => o.id.equals(id))).write(
      ProductionOrdersCompanion(
          status: const Value('cancelled'), updatedAt: Value(now)),
    );
  }

  Future<void> setStatus(String id, String status, DateTime now) {
    return (update(productionOrders)..where((o) => o.id.equals(id))).write(
      ProductionOrdersCompanion(status: Value(status), updatedAt: Value(now)),
    );
  }

  Future<int> countByStatuses(String orgId, List<String> statuses) async {
    final c = countAll();
    final q = selectOnly(productionOrders)
      ..addColumns([c])
      ..where(productionOrders.organizationId.equals(orgId) &
          productionOrders.status.isIn(statuses));
    return (await q.getSingle()).read(c) ?? 0;
  }
}
