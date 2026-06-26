import 'package:flutter_riverpod/flutter_riverpod.dart';
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
