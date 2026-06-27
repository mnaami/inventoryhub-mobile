import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/db/app_database.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/core/result/app_exception.dart';
import 'package:inventoryhub_mobile/features/production/recipe/data/production_recipe_dao.dart';
import 'package:inventoryhub_mobile/features/production/recipe/data/production_recipe_repository_impl.dart';
import 'package:inventoryhub_mobile/features/production/recipe/domain/production_recipe_usecases.dart';
import '../../../helpers/test_db.dart';

void main() {
  late AppDatabase db;
  late ProductionRecipeService service;

  setUp(() {
    db = newTestDb();
    service = ProductionRecipeService(
      repository: ProductionRecipeRepositoryImpl(ProductionRecipeDao(db)),
      ids: const IdGenerator(),
      organizationId: 'org1',
    );
  });
  tearDown(() => db.close());

  test('create with ingredients and activate flag', () async {
    final r = await service.create(
      productId: 'cake',
      name: 'Standard cake',
      ingredients: const [
        NewIngredient(ingredientProductId: 'flour', quantityPerUnit: 2, unit: 'kg'),
        NewIngredient(ingredientProductId: 'sugar', quantityPerUnit: 1, unit: 'kg'),
      ],
      activate: true,
    );
    expect(r.name, 'Standard cake');
    expect((await service.items(r.id)).length, 2);
    expect((await service.activeFor('cake'))!.id, r.id);
  });

  test('create rejects a blank name', () async {
    expect(
      () => service.create(productId: 'cake', name: '   '),
      throwsA(isA<ValidationException>()),
    );
  });

  test('addIngredient rejects non-positive quantity', () async {
    final r = await service.create(productId: 'cake', name: 'Cake');
    expect(
      () => service.addIngredient(r.id,
          ingredientProductId: 'flour', quantityPerUnit: 0, unit: 'kg'),
      throwsA(isA<ValidationException>()),
    );
  });

  test('activating one recipe deactivates the previous active one', () async {
    final a = await service.create(productId: 'cake', name: 'A', activate: true);
    final b = await service.create(productId: 'cake', name: 'B');
    await service.activate(b.id);
    expect((await service.activeFor('cake'))!.id, b.id);
    expect((await service.get(a.id))!.isActive, isFalse);
  });
}
