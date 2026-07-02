import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/paging/paged_list_notifier.dart';
import '../../../../core/paging/paged_state.dart';
import '../../../../core/providers.dart';
import '../data/photo_storage.dart';
import '../data/product_dao.dart';
import '../data/product_repository_impl.dart';
import '../domain/product.dart';
import '../domain/product_usecases.dart';

class ProductCriteria {
  const ProductCriteria({
    this.searchQuery,
    this.lowStock,
    this.outOfStock,
    this.categoryId,
  });

  final String? searchQuery;
  final bool? lowStock;
  final bool? outOfStock;
  final String? categoryId;

  ProductCriteria copyWith({
    String? searchQuery,
    bool? Function()? lowStock,
    bool? Function()? outOfStock,
    String? Function()? categoryId,
  }) {
    return ProductCriteria(
      searchQuery: searchQuery ?? this.searchQuery,
      lowStock: lowStock != null ? lowStock() : this.lowStock,
      outOfStock: outOfStock != null ? outOfStock() : this.outOfStock,
      categoryId: categoryId != null ? categoryId() : this.categoryId,
    );
  }

  ProductCriteria clearFilters() {
    return ProductCriteria(searchQuery: searchQuery);
  }
}

class ProductCriteriaNotifier extends Notifier<ProductCriteria> {
  @override
  ProductCriteria build() => const ProductCriteria();

  void set(ProductCriteria criteria) {
    state = criteria;
  }

  void update(ProductCriteria Function(ProductCriteria) update) {
    state = update(state);
  }
}

final productCriteriaProvider = NotifierProvider<ProductCriteriaNotifier, ProductCriteria>(
  ProductCriteriaNotifier.new,
);

class ProductSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void set(String q) => state = q;
}

final productSearchQueryProvider = NotifierProvider<ProductSearchQueryNotifier, String>(
  ProductSearchQueryNotifier.new,
);

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

class ProductDashboardData {
  ProductDashboardData({
    required this.totalProducts,
    required this.activeProducts,
    required this.totalValue,
    required this.lowStockCount,
    required this.outOfStockCount,
  });
  final int totalProducts;
  final int activeProducts;
  final double totalValue;
  final int lowStockCount;
  final int outOfStockCount;
}

final productDashboardProvider = FutureProvider<ProductDashboardData>((ref) async {
  final service = ref.watch(productServiceProvider);
  final total = await service.countProducts(onlyActive: false);
  final active = await service.countProducts(onlyActive: true);
  final value = await service.totalStockValue();
  final low = await service.lowStock();
  final out = await service.outOfStock();

  return ProductDashboardData(
    totalProducts: total,
    activeProducts: active,
    totalValue: value,
    lowStockCount: low.length,
    outOfStockCount: out.length,
  );
});

final productListProvider =
    NotifierProvider<ProductListNotifier, PagedState<Product>>(
        ProductListNotifier.new);

class ProductListNotifier extends PagedListNotifier<Product> {
  @override
  PagedState<Product> build() {
    ref.watch(productCriteriaProvider);
    return super.build();
  }

  @override
  Future<List<Product>> fetch(int page) {
    final criteria = ref.read(productCriteriaProvider);
    return ref.read(productServiceProvider).list(
      page: page,
      query: criteria.searchQuery,
      lowStock: criteria.lowStock,
      outOfStock: criteria.outOfStock,
      categoryId: criteria.categoryId,
    );
  }
}
