import '../../../../core/id/id_generator.dart';
import '../../../../core/result/app_exception.dart';
import 'product.dart';
import 'product_repository.dart';

class ProductService {
  ProductService({
    required ProductRepository repository,
    required IdGenerator ids,
    required String organizationId,
  })  : _repo = repository,
        _ids = ids,
        _orgId = organizationId;

  static const int pageSize = 20;

  final ProductRepository _repo;
  final IdGenerator _ids;
  final String _orgId;

  Future<List<Product>> list(int page) =>
      _repo.listPaged(_orgId, limit: pageSize, offset: page * pageSize);

  Future<List<Product>> search(String query) =>
      query.trim().isEmpty ? list(0) : _repo.search(_orgId, query.trim());

  Future<Product?> get(String id) => _repo.getById(id);
  Future<Product?> findByBarcode(String code) =>
      _repo.findByBarcode(_orgId, code);
  Future<List<Product>> lowStock() => _repo.lowStock(_orgId);
  Future<List<Product>> outOfStock() => _repo.outOfStock(_orgId);

  Future<Product> create({
    required String name,
    required String unitId,
    String? description,
    String? categoryId,
    double purchasePrice = 0,
    double sellingPrice = 0,
    double minimumStock = 0,
    String? barcode,
    String? imagePath,
  }) {
    if (name.trim().isEmpty) {
      throw const ValidationException('Product name is required.');
    }
    if (unitId.trim().isEmpty) {
      throw const ValidationException('A unit is required.');
    }
    final now = DateTime.now().toUtc();
    return _repo.create(Product(
      id: _ids.newId(),
      organizationId: _orgId,
      name: name.trim(),
      description: description,
      categoryId: categoryId,
      unitId: unitId,
      purchasePrice: purchasePrice,
      sellingPrice: sellingPrice,
      currentStock: 0, // opening stock is set via a stock movement, never here
      minimumStock: minimumStock,
      barcode: barcode,
      imagePath: imagePath,
      supplierId: null,
      isActive: true,
      isSample: false,
      createdAt: now,
      updatedAt: now,
    ));
  }

  Future<Product> edit(Product product) {
    if (product.name.trim().isEmpty) {
      throw const ValidationException('Product name is required.');
    }
    return _repo.update(product.copyWith(
      name: product.name.trim(),
      updatedAt: DateTime.now().toUtc(),
    ));
  }

  Future<void> delete(String id) => _repo.softDelete(id);
}
