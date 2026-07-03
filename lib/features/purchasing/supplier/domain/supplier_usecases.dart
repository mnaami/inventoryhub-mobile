import '../../../../core/id/id_generator.dart';
import '../../../../core/result/app_exception.dart';
import 'supplier.dart';
import 'supplier_repository.dart';

class SupplierService {
  SupplierService({
    required SupplierRepository repository,
    required IdGenerator ids,
    required String organizationId,
    Future<int> Function(String supplierId)? livePosForSupplier,
  })  : _repo = repository,
        _ids = ids,
        _orgId = organizationId,
        _livePos = livePosForSupplier;

  final SupplierRepository _repo;
  final IdGenerator _ids;
  final String _orgId;
  final Future<int> Function(String supplierId)? _livePos;

  static const int pageSize = 20;

  Future<List<Supplier>> listAll() => _repo.listActive(_orgId);

  Future<List<Supplier>> list({
    String? search,
    int page = 0,
  }) =>
      _repo.listSuppliers(
        _orgId,
        search: search,
        limit: pageSize,
        offset: page * pageSize,
      );

  Future<List<Supplier>> search(String query) =>
      query.trim().isEmpty ? listAll() : _repo.search(_orgId, query.trim());
  Future<Supplier?> get(String id) => _repo.getById(id);

  Future<Supplier> create({
    required String name,
    String? contactPerson,
    String? email,
    List<String> phones = const [],
    String? address,
    int paymentTerms = 30,
    double? creditLimit,
  }) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw const ValidationException('Supplier name is required.');
    }
    final now = DateTime.now().toUtc();
    return _repo.create(Supplier(
      id: _ids.newId(),
      organizationId: _orgId,
      name: trimmed,
      contactPerson: contactPerson,
      email: email,
      phones: phones,
      address: address,
      paymentTerms: paymentTerms,
      creditLimit: creditLimit,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    ));
  }

  Future<Supplier> edit(Supplier supplier) {
    if (supplier.name.trim().isEmpty) {
      throw const ValidationException('Supplier name is required.');
    }
    return _repo.update(supplier.copyWith(
      name: supplier.name.trim(),
      updatedAt: DateTime.now().toUtc(),
    ));
  }

  Future<void> delete(String id) async {
    final live = await (_livePos?.call(id) ?? Future.value(0));
    if (live > 0) {
      throw const ConflictException(
          'Cannot delete a supplier that still has active purchase orders.');
    }
    await _repo.softDelete(id);
  }
}
