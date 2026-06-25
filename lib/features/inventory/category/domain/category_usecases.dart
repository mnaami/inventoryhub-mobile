import '../../../../core/id/id_generator.dart';
import '../../../../core/result/app_exception.dart';
import 'category.dart';
import 'category_repository.dart';

class CategoryService {
  CategoryService({
    required CategoryRepository repository,
    required IdGenerator ids,
    required String organizationId,
  })  : _repo = repository,
        _ids = ids,
        _orgId = organizationId;

  final CategoryRepository _repo;
  final IdGenerator _ids;
  final String _orgId;

  Future<List<CategoryNode>> tree() async {
    final all = await _repo.listActive(_orgId);
    final byParent = <String?, List<Category>>{};
    for (final c in all) {
      byParent.putIfAbsent(c.parentCategoryId, () => []).add(c);
    }
    List<CategoryNode> build(String? parentId) =>
        (byParent[parentId] ?? const [])
            .map((c) => CategoryNode(category: c, children: build(c.id)))
            .toList();
    return build(null);
  }

  Future<Category> create({
    required String name,
    String? parentId,
    String? color,
    String? icon,
  }) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw const ValidationException('Category name is required.');
    }
    final now = DateTime.now().toUtc();
    return _repo.create(Category(
      id: _ids.newId(),
      organizationId: _orgId,
      name: trimmed,
      parentCategoryId: parentId,
      color: color,
      icon: icon,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    ));
  }

  Future<Category> rename(Category updated) {
    if (updated.name.trim().isEmpty) {
      throw const ValidationException('Category name is required.');
    }
    return _repo.update(updated.copyWith(
      name: updated.name.trim(),
      updatedAt: DateTime.now().toUtc(),
    ));
  }

  Future<void> delete(String id) async {
    final children = await _repo.getChildren(id);
    if (children.isNotEmpty) {
      throw const ConflictException(
          'Cannot delete a category that still has sub-categories.');
    }
    // NOTE: Task 14 extends this to also block deletion when products
    // reference the category.
    await _repo.softDelete(id);
  }
}
