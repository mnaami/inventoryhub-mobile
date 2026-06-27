import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/db/app_database.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/features/production/recipe/data/production_recipe_dao.dart';
import 'package:inventoryhub_mobile/features/production/recipe/data/production_recipe_repository_impl.dart';
import 'package:inventoryhub_mobile/features/production/recipe/domain/production_recipe.dart';
import '../../../helpers/test_db.dart';

void main() {
  late AppDatabase db;
  late ProductionRecipeRepositoryImpl repo;
  final now = DateTime.utc(2026, 6, 27);
  final ids = const IdGenerator();

  ProductionRecipe make(String id, {bool active = false}) => ProductionRecipe(
        id: id,
        organizationId: 'org1',
        productId: 'p1',
        name: 'Cake',
        isActive: active,
        isDeleted: false,
        createdAt: now,
        updatedAt: now,
      );

  ProductionRecipeItem ing(String id, String recipeId) => ProductionRecipeItem(
        id: id,
        recipeId: recipeId,
        ingredientProductId: 'flour',
        quantityPerUnit: 2,
        unit: 'kg',
        createdAt: now,
        updatedAt: now,
      );

  setUp(() {
    db = newTestDb();
    repo = ProductionRecipeRepositoryImpl(ProductionRecipeDao(db));
  });
  tearDown(() => db.close());

  test('create then load round-trips recipe and items', () async {
    await repo.create(make('r1'), [ing('i1', 'r1')]);
    final loaded = await repo.getById('r1');
    expect(loaded!.name, 'Cake');
    expect(loaded.isActive, isFalse);
    final items = await repo.itemsFor('r1');
    expect(items.single.ingredientProductId, 'flour');
    expect(items.single.quantityPerUnit, 2);
  });

  test('activate flips the active recipe for the product', () async {
    await repo.create(make('r1', active: true), []);
    await repo.create(make('r2'), []);
    await repo.activate('r2');
    expect((await repo.activeForProduct('org1', 'p1'))!.id, 'r2');
  });

  test('soft delete hides the recipe', () async {
    await repo.create(make('r1'), []);
    await repo.softDelete('r1');
    expect(await repo.getById('r1'), isNull);
  });
  // ignore: unused_local_variable
  final _ = ids;
}
