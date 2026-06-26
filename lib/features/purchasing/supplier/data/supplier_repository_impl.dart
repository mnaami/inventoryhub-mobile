import '../domain/supplier.dart';
import '../domain/supplier_repository.dart';
import 'supplier_dao.dart';
import 'supplier_mapper.dart';

class SupplierRepositoryImpl implements SupplierRepository {
  SupplierRepositoryImpl(this._dao);
  final SupplierDao _dao;

  @override
  Future<List<Supplier>> listActive(String organizationId) async =>
      (await _dao.listActive(organizationId)).map(toSupplier).toList();

  @override
  Future<List<Supplier>> search(String organizationId, String query) async =>
      (await _dao.search(organizationId, query)).map(toSupplier).toList();

  @override
  Future<Supplier?> getById(String id) async {
    final r = await _dao.byId(id);
    return r == null ? null : toSupplier(r);
  }

  @override
  Future<Supplier> create(Supplier supplier) async {
    await _dao.insertRow(toInsertCompanion(supplier));
    return supplier;
  }

  @override
  Future<Supplier> update(Supplier supplier) async {
    await _dao.updateRow(toUpdateCompanion(supplier));
    return supplier;
  }

  @override
  Future<void> softDelete(String id) =>
      _dao.softDelete(id, DateTime.now().toUtc());
}
