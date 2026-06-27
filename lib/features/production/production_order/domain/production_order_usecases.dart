import '../../../../core/id/id_generator.dart';
import '../../../../core/result/app_exception.dart';
import 'production_order.dart';
import 'production_order_enums.dart';
import 'production_order_repository.dart';

class ProductionKpis {
  const ProductionKpis({
    required this.planned,
    required this.inProgress,
    required this.completed,
  });
  final int planned;
  final int inProgress;
  final int completed;
}

class ProductionOrderService {
  ProductionOrderService({
    required ProductionOrderRepository repository,
    required IdGenerator ids,
    required String organizationId,
    required String userId,
  })  : _repo = repository,
        _ids = ids,
        _orgId = organizationId,
        _userId = userId;

  static const int pageSize = 20;

  final ProductionOrderRepository _repo;
  final IdGenerator _ids;
  final String _orgId;
  final String _userId;

  Future<ProductionOrder?> get(String id) => _repo.getOrder(id);

  Future<List<ProductionOrder>> list(
          {ProductionOrderStatus? status, int page = 0}) =>
      _repo.listOrders(_orgId,
          status: status, limit: pageSize, offset: page * pageSize);

  Future<ProductionOrder> createPlanned({
    required String productId,
    required double quantity,
    String? notes,
  }) async {
    if (productId.trim().isEmpty) {
      throw const ValidationException('An output product is required.');
    }
    if (quantity <= 0) {
      throw const ValidationException('Quantity must be positive.');
    }
    final now = DateTime.now().toUtc();
    final number = await _repo.nextNumber(_orgId, 'production_order', 'PRD');
    final order = ProductionOrder(
      id: _ids.newId(),
      organizationId: _orgId,
      orderNumber: number,
      productId: productId,
      quantity: quantity,
      status: ProductionOrderStatus.planned,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
    await _repo.createOrder(order);
    return order;
  }

  Future<void> start(ProductionOrder order) async {
    if (!order.canStart) {
      throw const ValidationException('Only a planned order can be started.');
    }
    await _repo.start(order.id);
  }

  Future<void> cancel(ProductionOrder order) async {
    if (order.isTerminal) {
      throw const ValidationException(
          'A completed or cancelled order cannot be cancelled.');
    }
    await _repo.cancel(order.id);
  }

  Future<void> complete(ProductionOrder order) async {
    if (!order.canComplete) {
      throw const ValidationException(
          'Only a planned or in-progress order can be completed.');
    }
    final recipe =
        await _repo.activeRecipeForProduct(_orgId, order.productId);
    if (recipe == null) {
      throw const ConflictException(
          'This product has no active recipe to produce from.');
    }
    final items = await _repo.recipeItems(recipe.id);
    if (items.isEmpty) {
      throw const ConflictException('The active recipe has no ingredients.');
    }
    final movementIds = <String, String>{
      for (final i in items) i.ingredientProductId: _ids.newId()
    };
    await _repo.complete(order.id, movementIds, _ids.newId(), _userId);
  }

  Future<ProductionKpis> dashboard() async => ProductionKpis(
        planned: await _repo
            .countByStatuses(_orgId, [ProductionOrderStatus.planned]),
        inProgress: await _repo
            .countByStatuses(_orgId, [ProductionOrderStatus.inProgress]),
        completed: await _repo
            .countByStatuses(_orgId, [ProductionOrderStatus.completed]),
      );
}
