import '../domain/customer.dart';
import '../domain/customer_repository.dart';
import 'customer_dao.dart';
import 'customer_mapper.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  CustomerRepositoryImpl(this._dao);
  final CustomerDao _dao;

  @override
  Future<List<Customer>> listActive(String organizationId) async =>
      (await _dao.listActive(organizationId)).map(toCustomer).toList();

  @override
  Future<List<Customer>> search(String organizationId, String query) async =>
      (await _dao.search(organizationId, query)).map(toCustomer).toList();

  @override
  Future<Customer?> getById(String id) async {
    final r = await _dao.byId(id);
    return r == null ? null : toCustomer(r);
  }

  @override
  Future<Customer> create(Customer customer) async {
    await _dao.insertRow(toInsertCompanion(customer));
    return customer;
  }

  @override
  Future<Customer> update(Customer customer) async {
    await _dao.updateRow(toUpdateCompanion(customer));
    return customer;
  }

  @override
  Future<void> softDelete(String id) =>
      _dao.softDelete(id, DateTime.now().toUtc());
}
