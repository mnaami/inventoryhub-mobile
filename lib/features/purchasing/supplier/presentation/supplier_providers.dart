import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers.dart';
import '../../purchase_order/domain/purchase_order.dart';
import '../../purchase_order/presentation/purchase_order_providers.dart';
import '../data/supplier_dao.dart';
import '../data/supplier_repository_impl.dart';
import '../domain/supplier.dart';
import '../domain/supplier_usecases.dart';

final supplierServiceProvider = Provider<SupplierService>((ref) {
  final purchaseOrders = ref.watch(purchaseOrderServiceProvider);
  return SupplierService(
    repository:
        SupplierRepositoryImpl(SupplierDao(ref.watch(appDatabaseProvider))),
    ids: ref.watch(idGeneratorProvider),
    organizationId: ref.watch(sessionProvider).organizationId,
    livePosForSupplier: purchaseOrders.livePosForSupplier,
  );
});

final suppliersProvider = FutureProvider<List<Supplier>>((ref) {
  return ref.watch(supplierServiceProvider).list();
});

final supplierProvider =
    FutureProvider.family<Supplier?, String>((ref, id) {
  return ref.watch(supplierServiceProvider).get(id);
});

final supplierOrdersProvider =
    FutureProvider.family<List<PurchaseOrder>, String>((ref, id) {
  return ref.watch(purchaseOrderServiceProvider).ordersForSupplier(id);
});

final supplierOutstandingProvider =
    FutureProvider.family<double, String>((ref, id) {
  return ref.watch(purchaseOrderServiceProvider).outstandingForSupplier(id);
});
