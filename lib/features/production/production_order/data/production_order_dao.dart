import 'package:drift/drift.dart';
import '../../../../core/db/app_database.dart';
import '../../../../core/result/app_exception.dart';
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
    String? search,
    required int limit,
    required int offset,
  }) {
    final q = select(productionOrders)
      ..where((o) => o.organizationId.equals(orgId));
    if (status != null) q.where((o) => o.status.equals(status));
    if (search != null && search.trim().isNotEmpty) {
      final like = '%${search.trim()}%';
      q.where((o) => o.orderNumber.like(like));
    }
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

  /// Completes a planned/in-progress order: validates an active recipe exists,
  /// validates sufficient stock for every ingredient (aggregated per
  /// ingredient) BEFORE recording anything, consumes each ingredient (`out`,
  /// negative) and produces the output (`in`, positive) through the slice-1
  /// ledger, then marks the order completed. One transaction — any throw rolls
  /// back all stock movement.
  Future<void> complete({
    required String orderId,
    required Map<String, String> consumptionMovementIdByIngredient,
    required String outputMovementId,
    required String createdBy,
    required DateTime now,
  }) {
    return transaction(() async {
      final order = await (select(productionOrders)
            ..where((o) => o.id.equals(orderId)))
          .getSingle();
      if (order.status != 'planned' && order.status != 'in_progress') {
        throw const ConflictException(
            'Only planned or in-progress orders can be completed.');
      }

      final recipe = await (select(productionRecipes)
            ..where((r) =>
                r.organizationId.equals(order.organizationId) &
                r.productId.equals(order.productId) &
                r.isActive.equals(true) &
                r.isDeleted.equals(false)))
          .getSingleOrNull();
      if (recipe == null) {
        throw const ConflictException(
            'This product has no active recipe to produce from.');
      }

      final lines = await (select(productionRecipeItems)
            ..where((i) => i.recipeId.equals(recipe.id)))
          .get();
      if (lines.isEmpty) {
        throw const ConflictException(
            'The active recipe has no ingredients.');
      }

      // Aggregate required quantity per ingredient.
      final required = <String, double>{};
      for (final l in lines) {
        required[l.ingredientProductId] =
            (required[l.ingredientProductId] ?? 0) +
                l.quantityPerUnit * order.quantity;
      }

      // Validate ALL ingredients before recording ANY movement.
      for (final entry in required.entries) {
        final p = await (select(products)
              ..where((x) => x.id.equals(entry.key)))
            .getSingleOrNull();
        if (p == null) {
          throw NotFoundException(
              'Ingredient product ${entry.key} not found.');
        }
        if (p.currentStock < entry.value) {
          throw ConflictException(
              'Insufficient stock for ${p.name}: need ${entry.value}, have ${p.currentStock}.');
        }
      }

      // Consume each ingredient (out, negative).
      for (final entry in required.entries) {
        await attachedDatabase.stockMovementDao.record(
          StockMovementsCompanion.insert(
            id: consumptionMovementIdByIngredient[entry.key]!,
            organizationId: order.organizationId,
            productId: entry.key,
            movementType: 'out',
            quantity: -entry.value,
            referenceType: const Value('production_order'),
            referenceId: Value(orderId),
            createdBy: createdBy,
            createdAt: now,
          ),
          productId: entry.key,
          delta: -entry.value,
        );
      }

      // Produce the output (in, positive).
      await attachedDatabase.stockMovementDao.record(
        StockMovementsCompanion.insert(
          id: outputMovementId,
          organizationId: order.organizationId,
          productId: order.productId,
          movementType: 'in',
          quantity: order.quantity,
          referenceType: const Value('production_order'),
          referenceId: Value(orderId),
          createdBy: createdBy,
          createdAt: now,
        ),
        productId: order.productId,
        delta: order.quantity,
      );

      // Mark completed.
      await (update(productionOrders)..where((o) => o.id.equals(orderId)))
          .write(ProductionOrdersCompanion(
        status: const Value('completed'),
        completionDate: Value(now),
        updatedAt: Value(now),
      ));
    });
  }
}
