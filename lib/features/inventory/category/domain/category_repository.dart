import 'category.dart';

abstract interface class CategoryRepository {
  Future<List<Category>> listActive(String organizationId);
  Future<Category?> getById(String id);
  Future<List<Category>> getChildren(String parentId);
  Future<Category> create(Category category);
  Future<Category> update(Category category);
  Future<void> softDelete(String id);
}
