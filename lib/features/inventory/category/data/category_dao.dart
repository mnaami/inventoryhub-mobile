import 'package:drift/drift.dart';
import '../../../../core/db/app_database.dart';
import 'category_table.dart';

part 'category_dao.g.dart';

@DriftAccessor(tables: [Categories])
class CategoryDao extends DatabaseAccessor<AppDatabase>
    with _$CategoryDaoMixin {
  CategoryDao(super.db);

  Future<List<CategoryRow>> activeForOrg(String orgId) {
    return (select(categories)
          ..where((c) => c.organizationId.equals(orgId) & c.isActive.equals(true))
          ..orderBy([(c) => OrderingTerm(expression: c.name)]))
        .get();
  }

  Future<CategoryRow?> byId(String id) {
    return (select(categories)..where((c) => c.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<CategoryRow>> childrenOf(String parentId) {
    return (select(categories)
          ..where((c) =>
              c.parentCategoryId.equals(parentId) & c.isActive.equals(true)))
        .get();
  }

  Future<void> insertRow(CategoriesCompanion c) =>
      into(categories).insert(c);

  Future<void> updateRow(CategoriesCompanion c) =>
      (update(categories)..where((t) => t.id.equals(c.id.value))).write(c);

  Future<void> softDelete(String id, DateTime now) {
    return (update(categories)..where((t) => t.id.equals(id))).write(
      CategoriesCompanion(isActive: const Value(false), updatedAt: Value(now)),
    );
  }
}
