import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../inventory/product/domain/product.dart';
import '../../../inventory/product/presentation/product_providers.dart';
import '../../../sales/sale_order/data/document_counter_dao.dart';
import '../../recipe/data/production_recipe_dao.dart';
import '../data/production_order_dao.dart';
import '../data/production_order_repository_impl.dart';
import '../domain/production_order.dart';
import '../domain/production_order_enums.dart';
import '../domain/production_order_usecases.dart';

/// First page of products, for output/ingredient selection dropdowns. Mirrors
/// the purchasing edit screen, which selects from `productServiceProvider.list(0)`.
final allProductsProvider = FutureProvider<List<Product>>(
    (ref) => ref.watch(productServiceProvider).list(page: 0));

final productionOrderServiceProvider =
    Provider<ProductionOrderService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final session = ref.watch(sessionProvider);
  return ProductionOrderService(
    repository: ProductionOrderRepositoryImpl(
        ProductionOrderDao(db), ProductionRecipeDao(db), DocumentCounterDao(db)),
    ids: ref.watch(idGeneratorProvider),
    organizationId: session.organizationId,
    userId: session.userId,
  );
});

class ProductionOrderFilter extends Notifier<ProductionOrderStatus?> {
  @override
  ProductionOrderStatus? build() => null;
  void set(ProductionOrderStatus? status) => state = status;
}

final productionOrderFilterProvider =
    NotifierProvider<ProductionOrderFilter, ProductionOrderStatus?>(
        ProductionOrderFilter.new);

final productionOrdersProvider =
    FutureProvider<List<ProductionOrder>>((ref) => ref
        .watch(productionOrderServiceProvider)
        .list(status: ref.watch(productionOrderFilterProvider)));

final productionOrderProvider =
    FutureProvider.family<ProductionOrder?, String>(
        (ref, id) => ref.watch(productionOrderServiceProvider).get(id));

final productionDashboardProvider = FutureProvider<ProductionKpis>(
    (ref) => ref.watch(productionOrderServiceProvider).dashboard());

String productionStatusLabel(AppLocalizations l10n, ProductionOrderStatus s) =>
    switch (s) {
      ProductionOrderStatus.planned => l10n.productionStatusPlanned,
      ProductionOrderStatus.inProgress => l10n.productionStatusInProgress,
      ProductionOrderStatus.completed => l10n.productionStatusCompleted,
      ProductionOrderStatus.cancelled => l10n.productionStatusCancelled,
    };
