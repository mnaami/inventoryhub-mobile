import '../../../sales/sale_order/data/document_counter_dao.dart';
import '../../recipe/data/production_recipe_dao.dart';
import '../../recipe/data/production_recipe_mappers.dart';
import '../../recipe/domain/production_recipe.dart';
import '../domain/production_order.dart';
import '../domain/production_order_enums.dart';
import '../domain/production_order_repository.dart';
import 'production_order_dao.dart';
import 'production_order_mappers.dart';

class ProductionOrderRepositoryImpl implements ProductionOrderRepository {
  ProductionOrderRepositoryImpl(this._orders, this._recipes, this._counters);
  final ProductionOrderDao _orders;
  final ProductionRecipeDao _recipes;
  final DocumentCounterDao _counters;

  @override
  Future<String> nextNumber(String orgId, String entityType, String prefix) =>
      _counters.next(orgId, entityType, prefix);

  @override
  Future<void> createOrder(ProductionOrder order) =>
      _orders.createRow(productionOrderInsert(order));

  @override
  Future<ProductionOrder?> getOrder(String id) async {
    final r = await _orders.byId(id);
    return r == null ? null : toProductionOrder(r);
  }

  @override
  Future<List<ProductionOrder>> listOrders(String orgId,
          {ProductionOrderStatus? status,
          required int limit,
          required int offset}) async =>
      (await _orders.paged(orgId,
              status: status?.wire, limit: limit, offset: offset))
          .map(toProductionOrder)
          .toList();

  @override
  Future<void> setStatus(String id, ProductionOrderStatus status) =>
      _orders.setStatus(id, status.wire, DateTime.now().toUtc());

  @override
  Future<void> start(String id) => _orders.start(id, DateTime.now().toUtc());

  @override
  Future<void> cancel(String id) => _orders.cancel(id, DateTime.now().toUtc());

  @override
  Future<void> complete(
          String orderId,
          Map<String, String> consumptionMovementIdByIngredient,
          String outputMovementId,
          String createdBy) =>
      _orders.complete(
        orderId: orderId,
        consumptionMovementIdByIngredient: consumptionMovementIdByIngredient,
        outputMovementId: outputMovementId,
        createdBy: createdBy,
        now: DateTime.now().toUtc(),
      );

  @override
  Future<int> countByStatuses(
          String orgId, List<ProductionOrderStatus> s) =>
      _orders.countByStatuses(orgId, s.map((e) => e.wire).toList());

  @override
  Future<ProductionRecipe?> activeRecipeForProduct(
      String orgId, String productId) async {
    final r = await _recipes.activeForProduct(orgId, productId);
    return r == null ? null : toProductionRecipe(r);
  }

  @override
  Future<List<ProductionRecipeItem>> recipeItems(String recipeId) async =>
      (await _recipes.itemsFor(recipeId)).map(toProductionRecipeItem).toList();
}
