import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers.dart';
import '../data/customer_dao.dart';
import '../data/customer_repository_impl.dart';
import '../domain/customer.dart';
import '../domain/customer_usecases.dart';

final customerServiceProvider = Provider<CustomerService>((ref) {
  return CustomerService(
    repository:
        CustomerRepositoryImpl(CustomerDao(ref.watch(appDatabaseProvider))),
    ids: ref.watch(idGeneratorProvider),
    organizationId: ref.watch(sessionProvider).organizationId,
  );
});

final customersProvider = FutureProvider<List<Customer>>((ref) {
  return ref.watch(customerServiceProvider).list();
});

final customerProvider =
    FutureProvider.family<Customer?, String>((ref, id) {
  return ref.watch(customerServiceProvider).get(id);
});
