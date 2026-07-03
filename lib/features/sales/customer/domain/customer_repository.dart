import 'customer.dart';

abstract interface class CustomerRepository {
  Future<List<Customer>> listActive(String organizationId);
  Future<List<Customer>> listActivePaged(
    String organizationId, {
    String? search,
    required int limit,
    required int offset,
  });
  Future<List<Customer>> search(String organizationId, String query);
  Future<Customer?> getById(String id);
  Future<Customer> create(Customer customer);
  Future<Customer> update(Customer customer);
  Future<void> softDelete(String id);
}
