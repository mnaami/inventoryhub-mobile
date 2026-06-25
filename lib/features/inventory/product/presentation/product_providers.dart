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

final productListProvider =
    NotifierProvider<ProductListNotifier, AsyncValue<List<Product>>>(
        ProductListNotifier.new);

class ProductListNotifier extends Notifier<AsyncValue<List<Product>>> {
  int _page = 0;
  bool _hasMore = true;
  bool _loading = false;
  String _query = '';
  final List<Product> _items = [];

  @override
  AsyncValue<List<Product>> build() {
    _loadInitial();
    return const AsyncValue.loading();
  }

  ProductService get _service => ref.read(productServiceProvider);

  Future<List<Product>> _fetch(int page) =>
      _query.trim().isEmpty ? _service.list(page) : _service.search(_query);

  Future<void> _loadInitial() async {
    _page = 0;
    _hasMore = true;
    _items.clear();
    state = const AsyncValue.loading();
    try {
      final first = await _fetch(0);
      _items.addAll(first);
      if (_query.trim().isNotEmpty || first.length < ProductService.pageSize) {
        _hasMore = false;
      }
      state = AsyncValue.data(List.unmodifiable(_items));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> search(String query) async {
    _query = query;
    await _loadInitial();
  }

  Future<void> loadMore() async {
    if (_loading || !_hasMore || _query.trim().isNotEmpty) return;
    _loading = true;
    final next = await _fetch(_page + 1);
    if (next.length < ProductService.pageSize) _hasMore = false;
    if (next.isNotEmpty) {
      _page += 1;
      _items.addAll(next);
      state = AsyncValue.data(List.unmodifiable(_items));
    }
    _loading = false;
  }

  Future<void> refresh() => _loadInitial();
}
