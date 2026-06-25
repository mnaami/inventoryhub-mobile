import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/providers.dart';
import '../data/photo_storage.dart';
import '../data/product_dao.dart';
import '../data/product_repository_impl.dart';
import '../domain/product.dart';
import '../domain/product_usecases.dart';

final productServiceProvider = Provider<ProductService>((ref) {
  return ProductService(
    repository: ProductRepositoryImpl(ProductDao(ref.watch(appDatabaseProvider))),
    ids: ref.watch(idGeneratorProvider),
    organizationId: ref.watch(sessionProvider).organizationId,
  );
});

final productProvider =
    FutureProvider.family<Product?, String>((ref, id) {
  return ref.watch(productServiceProvider).get(id);
});

final lowStockProductsProvider = FutureProvider<List<Product>>((ref) {
  return ref.watch(productServiceProvider).lowStock();
});

final photoStorageProvider = FutureProvider<PhotoStorage>((ref) async {
  final dir = await getApplicationDocumentsDirectory();
  return PhotoStorage(dir, ref.watch(idGeneratorProvider));
});
