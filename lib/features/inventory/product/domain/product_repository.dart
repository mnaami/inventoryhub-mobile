import 'product.dart';

abstract interface class ProductRepository {
  Future<List<Product>> listPaged(String organizationId,
      {required int limit, required int offset});
  Future<List<Product>> search(String organizationId, String query);
  Future<Product?> getById(String id);
  Future<Product?> findByBarcode(String organizationId, String barcode);
  Future<List<Product>> lowStock(String organizationId);
  Future<List<Product>> outOfStock(String organizationId);
  Future<int> countActiveByCategory(String organizationId, String categoryId);
  Future<Product> create(Product product);
  Future<Product> update(Product product);
  Future<void> softDelete(String id);
}
