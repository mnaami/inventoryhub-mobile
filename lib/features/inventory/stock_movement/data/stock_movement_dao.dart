import 'package:drift/drift.dart';
import '../../../../core/db/app_database.dart';
import '../../../../core/result/app_exception.dart';
import '../../product/data/product_table.dart';
import 'stock_movement_table.dart';

part 'stock_movement_dao.g.dart';

@DriftAccessor(tables: [StockMovements, Products])
class StockMovementDao extends DatabaseAccessor<AppDatabase>
    with _$StockMovementDaoMixin {
  StockMovementDao(super.db);

  /// Inserts the immutable ledger row and updates the product's cached
  /// current_stock in a SINGLE transaction. If the product does not exist,
  /// throws NotFoundException — which rolls back the just-inserted row.
  /// Returns the new current_stock total.
  Future<double> record(
    StockMovementsCompanion movement, {
    required String productId,
    required double delta,
  }) {
    return transaction(() async {
      await into(stockMovements).insert(movement);
      final product = await (select(products)
            ..where((p) => p.id.equals(productId)))
          .getSingleOrNull();
      if (product == null) {
        throw const NotFoundException('Product not found for stock movement.');
      }
      final newStock = product.currentStock + delta;
      await (update(products)..where((p) => p.id.equals(productId))).write(
        ProductsCompanion(
          currentStock: Value(newStock),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
      return newStock;
    });
  }

  Future<List<StockMovementRow>> forProduct(String productId) {
    return (select(stockMovements)
          ..where((m) => m.productId.equals(productId))
          ..orderBy([
            (m) => OrderingTerm(expression: m.createdAt, mode: OrderingMode.desc)
          ]))
        .get();
  }

  Future<List<StockMovementRow>> paged(
    String orgId, {
    String? type,
    required int limit,
    required int offset,
  }) {
    final q = select(stockMovements)
      ..where((m) => m.organizationId.equals(orgId));
    if (type != null) {
      q.where((m) => m.movementType.equals(type));
    }
    q
      ..orderBy([
        (m) => OrderingTerm(expression: m.createdAt, mode: OrderingMode.desc)
      ])
      ..limit(limit, offset: offset);
    return q.get();
  }
}
