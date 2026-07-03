import '../../recipe/domain/production_recipe.dart';
import 'production_order.dart';
import 'production_order_enums.dart';

abstract interface class ProductionOrderRepository {
  Future<String> nextNumber(String orgId, String entityType, String prefix);
  Future<void> createOrder(ProductionOrder order);
  Future<ProductionOrder?> getOrder(String id);
  Future<List<ProductionOrder>> listOrders(String orgId,
      {ProductionOrderStatus? status,
      String? search,
      required int limit,
      required int offset});
  Future<void> setStatus(String id, ProductionOrderStatus status);
  Future<void> start(String id);
  Future<void> cancel(String id);
  Future<void> complete(
      String orderId,
      Map<String, String> consumptionMovementIdByIngredient,
      String outputMovementId,
      String createdBy);
  Future<int> countByStatuses(String orgId, List<ProductionOrderStatus> s);

  // Recipe access needed to drive completion.
  Future<ProductionRecipe?> activeRecipeForProduct(
      String orgId, String productId);
  Future<List<ProductionRecipeItem>> recipeItems(String recipeId);
}
