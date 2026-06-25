import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers.dart';
import '../data/category_dao.dart';
import '../data/category_repository_impl.dart';
import '../domain/category.dart';
import '../domain/category_usecases.dart';

final categoryServiceProvider = Provider<CategoryService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return CategoryService(
    repository: CategoryRepositoryImpl(CategoryDao(db)),
    ids: ref.watch(idGeneratorProvider),
    organizationId: ref.watch(sessionProvider).organizationId,
  );
});

final categoryTreeProvider = FutureProvider<List<CategoryNode>>((ref) {
  return ref.watch(categoryServiceProvider).tree();
});
