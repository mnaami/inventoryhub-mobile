import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers.dart';
import '../../product/data/product_dao.dart';
import '../../product/data/product_repository_impl.dart';
import '../data/category_dao.dart';
import '../data/category_repository_impl.dart';
import '../domain/category.dart';
import '../domain/category_usecases.dart';

final categoryServiceProvider = Provider<CategoryService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final orgId = ref.watch(sessionProvider).organizationId;
  final products = ProductRepositoryImpl(ProductDao(db));
  return CategoryService(
    repository: CategoryRepositoryImpl(CategoryDao(db)),
    ids: ref.watch(idGeneratorProvider),
    organizationId: orgId,
    productsInCategory: (categoryId) =>
        products.countActiveByCategory(orgId, categoryId),
  );
});

final categoryTreeProvider = FutureProvider<List<CategoryNode>>((ref) {
  return ref.watch(categoryServiceProvider).tree();
});

final activeCategoriesProvider = FutureProvider<List<Category>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final orgId = ref.watch(sessionProvider).organizationId;
  return CategoryRepositoryImpl(CategoryDao(db)).listActive(orgId);
});
