import '../data/product_dao.dart';
import '../domain/product.dart';
import '../domain/product_repository.dart';
import 'product_mapper.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(this._dao);
  final ProductDao _dao;

  @override
  Future<List<Product>> listPaged(
    String organizationId, {
    required int limit,
    required int offset,
    String? query,
    bool? lowStock,
    bool? outOfStock,
    String? categoryId,
  }) async =>
      (await _dao.paged(
        organizationId,
        limit: limit,
        offset: offset,
        query: query,
        lowStock: lowStock,
        outOfStock: outOfStock,
        categoryId: categoryId,
      ))
          .map(toProduct)
          .toList();

  @override
  Future<List<Product>> search(String organizationId, String query) async =>
      (await _dao.search(organizationId, query)).map(toProduct).toList();

  @override
  Future<Product?> getById(String id) async {
    final r = await _dao.byId(id);
    return r == null ? null : toProduct(r);
  }

  @override
  Future<Product?> findByBarcode(String organizationId, String barcode) async {
    final r = await _dao.byBarcode(organizationId, barcode);
    return r == null ? null : toProduct(r);
  }

  @override
  Future<List<Product>> lowStock(String organizationId) async =>
      (await _dao.lowStock(organizationId)).map(toProduct).toList();

  @override
  Future<List<Product>> outOfStock(String organizationId) async =>
      (await _dao.outOfStock(organizationId)).map(toProduct).toList();

  @override
  Future<int> countActiveByCategory(String organizationId, String categoryId) =>
      _dao.countActiveByCategory(organizationId, categoryId);

  @override
  Future<Product> create(Product product) async {
    await _dao.insertRow(toInsertCompanion(product));
    return product;
  }

  @override
  Future<Product> update(Product product) async {
    await _dao.updateRow(toUpdateCompanion(product));
    return product;
  }

  @override
  Future<void> softDelete(String id) =>
      _dao.softDelete(id, DateTime.now().toUtc());

  @override
  Future<int> countProducts(String organizationId, {required bool onlyActive}) =>
      _dao.countProducts(organizationId, onlyActive: onlyActive);

  @override
  Future<double> totalStockValue(String organizationId) =>
      _dao.totalStockValue(organizationId);
}
