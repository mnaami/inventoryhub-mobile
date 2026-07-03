import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers.dart';
import '../../../../core/paging/paged_list_notifier.dart';
import '../../../../core/paging/paged_state.dart';
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
  return ref.watch(supplierServiceProvider).listAll();
});

class SupplierListCriteria {
  const SupplierListCriteria({this.search = ''});
  final String search;

  SupplierListCriteria copyWith({String? search}) =>
      SupplierListCriteria(search: search ?? this.search);

  bool get hasActiveFilters => search.isNotEmpty;
}

class SupplierCriteria extends Notifier<SupplierListCriteria> {
  @override
  SupplierListCriteria build() => const SupplierListCriteria();

  void setSearch(String v) => state = state.copyWith(search: v);
  void reset() => state = const SupplierListCriteria();
}

final supplierCriteriaProvider =
    NotifierProvider<SupplierCriteria, SupplierListCriteria>(SupplierCriteria.new);

class SupplierListNotifier extends PagedListNotifier<Supplier> {
  @override
  int get pageSize => SupplierService.pageSize;

  @override
  PagedState<Supplier> build() {
    ref.listen(supplierCriteriaProvider, (_, __) => reload());
    return super.build();
  }

  @override
  Future<List<Supplier>> fetch(int page) {
    final c = ref.read(supplierCriteriaProvider);
    return ref.read(supplierServiceProvider).list(
          page: page,
          search: c.search.isEmpty ? null : c.search,
        );
  }
}

final supplierListProvider =
    NotifierProvider<SupplierListNotifier, PagedState<Supplier>>(
        SupplierListNotifier.new);

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
