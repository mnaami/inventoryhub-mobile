import 'stock_movement.dart';

abstract interface class StockMovementRepository {
  /// Persists [movement] and applies [delta] to the product's current_stock
  /// atomically. Returns the new current_stock.
  Future<double> record(StockMovement movement, double delta);
  Future<List<StockMovement>> historyFor(String productId);
  Future<List<StockMovement>> paged(String organizationId,
      {MovementType? type, required int limit, required int offset});
}
