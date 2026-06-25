import '../../../../core/id/id_generator.dart';
import '../../../../core/result/app_exception.dart';
import 'stock_movement.dart';
import 'stock_movement_repository.dart';

class StockService {
  StockService({
    required StockMovementRepository repository,
    required IdGenerator ids,
    required String organizationId,
    required String userId,
  })  : _repo = repository,
        _ids = ids,
        _orgId = organizationId,
        _userId = userId;

  static const int pageSize = 20;

  final StockMovementRepository _repo;
  final IdGenerator _ids;
  final String _orgId;
  final String _userId;

  Future<double> record({
    required String productId,
    required MovementType type,
    required double quantity,
    String? notes,
  }) {
    if (quantity == 0) {
      throw const ValidationException('Quantity must not be zero.');
    }
    final signed = switch (type) {
      MovementType.inbound => quantity.abs(),
      MovementType.outbound => -quantity.abs(),
      MovementType.adjustment => quantity,
    };
    final movement = StockMovement(
      id: _ids.newId(),
      organizationId: _orgId,
      productId: productId,
      type: type,
      quantity: signed,
      notes: notes,
      createdBy: _userId,
      createdAt: DateTime.now().toUtc(),
    );
    return _repo.record(movement, signed);
  }

  Future<List<StockMovement>> history(String productId) =>
      _repo.historyFor(productId);

  Future<List<StockMovement>> ledger({MovementType? type, int page = 0}) =>
      _repo.paged(_orgId, type: type, limit: pageSize, offset: page * pageSize);
}
