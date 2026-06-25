import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/core/result/app_exception.dart';
import 'package:inventoryhub_mobile/features/inventory/category/data/category_dao.dart';
import 'package:inventoryhub_mobile/features/inventory/category/data/category_repository_impl.dart';
import 'package:inventoryhub_mobile/features/inventory/category/domain/category_usecases.dart';
import 'package:inventoryhub_mobile/features/inventory/product/data/product_dao.dart';
import 'package:inventoryhub_mobile/features/inventory/product/data/product_repository_impl.dart';
import 'package:inventoryhub_mobile/features/inventory/product/domain/product_usecases.dart';
import '../../../helpers/test_db.dart';

void main() {
  late CategoryService service;
  late dynamic db;

  setUp(() {
    db = newTestDb();
    service = CategoryService(
      repository: CategoryRepositoryImpl(CategoryDao(db)),
      ids: const IdGenerator(),
      organizationId: 'org1',
    );
  });
  tearDown(() => db.close());

  test('create then tree returns a nested structure', () async {
    final food = await service.create(name: 'Food');
    await service.create(name: 'Snacks', parentId: food.id);
    final tree = await service.tree();
    expect(tree.single.category.name, 'Food');
    expect(tree.single.children.single.category.name, 'Snacks');
  });

  test('create rejects blank names', () async {
    expect(() => service.create(name: '   '),
        throwsA(isA<ValidationException>()));
  });

  test('delete blocks a category with children', () async {
    final food = await service.create(name: 'Food');
    await service.create(name: 'Snacks', parentId: food.id);
    await expectLater(service.delete(food.id),
        throwsA(isA<ConflictException>()));
  });

  test('create surfaces duplicate names as ConflictException', () async {
    await service.create(name: 'Food');
    await expectLater(service.create(name: 'Food'),
        throwsA(isA<ConflictException>()));
  });

  test('delete blocks a category that has products', () async {
    final products = ProductRepositoryImpl(ProductDao(db));
    final guarded = CategoryService(
      repository: CategoryRepositoryImpl(CategoryDao(db)),
      ids: const IdGenerator(),
      organizationId: 'org1',
      productsInCategory: (id) => products.countActiveByCategory('org1', id),
    );
    final cat = await guarded.create(name: 'Food');
    await ProductService(
      repository: products,
      ids: const IdGenerator(),
      organizationId: 'org1',
    ).create(name: 'Apple', unitId: 'pc', categoryId: cat.id);

    await expectLater(guarded.delete(cat.id), throwsA(isA<ConflictException>()));
  });
}
