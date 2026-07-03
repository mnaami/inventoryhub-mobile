import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/paging/paged_list_notifier.dart';
import '../../../../core/paging/paged_state.dart';
import '../../../../core/providers.dart';
import '../../sale_order/domain/sale_order.dart';
import '../../sale_order/presentation/sale_order_providers.dart';
import '../data/customer_dao.dart';
import '../data/customer_repository_impl.dart';
import '../domain/customer.dart';
import '../domain/customer_usecases.dart';

final customerServiceProvider = Provider<CustomerService>((ref) {
  final saleOrders = ref.watch(saleOrderServiceProvider);
  return CustomerService(
    repository:
        CustomerRepositoryImpl(CustomerDao(ref.watch(appDatabaseProvider))),
    ids: ref.watch(idGeneratorProvider),
    organizationId: ref.watch(sessionProvider).organizationId,
    liveOrdersForCustomer: saleOrders.liveOrdersForCustomer,
  );
});

final customersProvider = FutureProvider<List<Customer>>((ref) {
  return ref.watch(customerServiceProvider).list();
});

class CustomerListCriteria {
  const CustomerListCriteria({this.search = ''});
  final String search;

  CustomerListCriteria copyWith({String? search}) =>
      CustomerListCriteria(search: search ?? this.search);

  bool get hasActiveFilters => search.isNotEmpty;
}

class CustomerCriteria extends Notifier<CustomerListCriteria> {
  @override
  CustomerListCriteria build() => const CustomerListCriteria();

  void setSearch(String v) => state = state.copyWith(search: v);
  void reset() => state = const CustomerListCriteria();
}

final customerCriteriaProvider =
    NotifierProvider<CustomerCriteria, CustomerListCriteria>(
        CustomerCriteria.new);

class CustomerListNotifier extends PagedListNotifier<Customer> {
  @override
  int get pageSize => CustomerService.pageSize;

  @override
  PagedState<Customer> build() {
    ref.listen(customerCriteriaProvider, (_, __) => reload());
    return super.build();
  }

  @override
  Future<List<Customer>> fetch(int page) {
    final c = ref.read(customerCriteriaProvider);
    return ref.read(customerServiceProvider).listPaged(
          page: page,
          search: c.search.isEmpty ? null : c.search,
        );
  }
}

final customerListProvider =
    NotifierProvider<CustomerListNotifier, PagedState<Customer>>(
        CustomerListNotifier.new);

final customerProvider =
    FutureProvider.family<Customer?, String>((ref, id) {
  return ref.watch(customerServiceProvider).get(id);
});

final customerOrdersProvider =
    FutureProvider.family<List<SaleOrder>, String>((ref, id) {
  return ref.watch(saleOrderServiceProvider).ordersForCustomer(id);
});

final customerOutstandingProvider =
    FutureProvider.family<double, String>((ref, id) {
  return ref.watch(saleOrderServiceProvider).outstandingForCustomer(id);
});
