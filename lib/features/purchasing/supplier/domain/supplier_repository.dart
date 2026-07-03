import 'supplier.dart';

abstract interface class SupplierRepository {
  Future<List<Supplier>> listActive(String organizationId);
  Future<List<Supplier>> listSuppliers(
    String organizationId, {
    String? search,
    required int limit,
    required int offset,
  });
  Future<List<Supplier>> search(String organizationId, String query);
  Future<Supplier?> getById(String id);
  Future<Supplier> create(Supplier supplier);
  Future<Supplier> update(Supplier supplier);
  Future<void> softDelete(String id);
}
