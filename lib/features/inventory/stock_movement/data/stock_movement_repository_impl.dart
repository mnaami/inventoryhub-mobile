import '../data/stock_movement_dao.dart';
import '../domain/stock_movement.dart';
import '../domain/stock_movement_repository.dart';
import 'stock_movement_mapper.dart';

class StockMovementRepositoryImpl implements StockMovementRepository {
  StockMovementRepositoryImpl(this._dao);
  final StockMovementDao _dao;

  @override
  Future<double> record(StockMovement movement, double delta) =>
      _dao.record(toCompanion(movement),
          productId: movement.productId, delta: delta);

  @override
  Future<List<StockMovement>> historyFor(String productId) async =>
      (await _dao.forProduct(productId)).map(toStockMovement).toList();

  @override
  Future<List<StockMovement>> paged(String organizationId,
          {MovementType? type, required int limit, required int offset}) async =>
      (await _dao.paged(organizationId,
              type: type?.wire, limit: limit, offset: offset))
          .map(toStockMovement)
          .toList();
}
