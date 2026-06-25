import 'package:drift/native.dart';
import '../../../../core/result/app_exception.dart';
import '../data/category_dao.dart';
import '../domain/category.dart';
import '../domain/category_repository.dart';
import 'category_mapper.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl(this._dao);
  final CategoryDao _dao;

  @override
  Future<List<Category>> listActive(String organizationId) async =>
      (await _dao.activeForOrg(organizationId)).map(toCategory).toList();

  @override
  Future<Category?> getById(String id) async {
    final row = await _dao.byId(id);
    return row == null ? null : toCategory(row);
  }

  @override
  Future<List<Category>> getChildren(String parentId) async =>
      (await _dao.childrenOf(parentId)).map(toCategory).toList();

  @override
  Future<Category> create(Category category) async {
    try {
      await _dao.insertRow(toCompanion(category).copyWith());
      return category;
    } on SqliteException {
      throw ConflictException('A category named "${category.name}" already exists.');
    }
  }

  @override
  Future<Category> update(Category category) async {
    try {
      await _dao.updateRow(toCompanion(category));
      return category;
    } on SqliteException {
      throw ConflictException('A category named "${category.name}" already exists.');
    }
  }

  @override
  Future<void> softDelete(String id) => _dao.softDelete(id, DateTime.now().toUtc());
}
