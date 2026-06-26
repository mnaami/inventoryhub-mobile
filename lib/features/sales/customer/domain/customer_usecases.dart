import '../../../../core/id/id_generator.dart';
import '../../../../core/result/app_exception.dart';
import 'customer.dart';
import 'customer_repository.dart';

class CustomerService {
  CustomerService({
    required CustomerRepository repository,
    required IdGenerator ids,
    required String organizationId,
    Future<int> Function(String customerId)? liveOrdersForCustomer,
  })  : _repo = repository,
        _ids = ids,
        _orgId = organizationId,
        _liveOrders = liveOrdersForCustomer;

  final CustomerRepository _repo;
  final IdGenerator _ids;
  final String _orgId;
  final Future<int> Function(String customerId)? _liveOrders;

  Future<List<Customer>> list() => _repo.listActive(_orgId);
  Future<List<Customer>> search(String query) =>
      query.trim().isEmpty ? list() : _repo.search(_orgId, query.trim());
  Future<Customer?> get(String id) => _repo.getById(id);

  Future<Customer> create({
    required String name,
    String? email,
    List<String> phones = const [],
    String? address,
    int paymentTerms = 30,
    double? creditLimit,
    String? imagePath,
  }) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw const ValidationException('Customer name is required.');
    }
    final now = DateTime.now().toUtc();
    return _repo.create(Customer(
      id: _ids.newId(),
      organizationId: _orgId,
      name: trimmed,
      email: email,
      phones: phones,
      address: address,
      paymentTerms: paymentTerms,
      creditLimit: creditLimit,
      imagePath: imagePath,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    ));
  }

  Future<Customer> edit(Customer customer) {
    if (customer.name.trim().isEmpty) {
      throw const ValidationException('Customer name is required.');
    }
    return _repo.update(customer.copyWith(
      name: customer.name.trim(),
      updatedAt: DateTime.now().toUtc(),
    ));
  }

  Future<void> delete(String id) async {
    final live = await (_liveOrders?.call(id) ?? Future.value(0));
    if (live > 0) {
      throw const ConflictException(
          'Cannot delete a customer that still has active orders.');
    }
    await _repo.softDelete(id);
  }
}
