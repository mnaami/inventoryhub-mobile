import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/db/app_database.dart';
import 'package:inventoryhub_mobile/features/production/recipe/data/production_recipe_dao.dart';
import '../../../helpers/test_db.dart';

void main() {
  late AppDatabase db;
  late ProductionRecipeDao dao;
  final now = DateTime.utc(2026, 6, 27);

  ProductionRecipesCompanion recipe(String id,
          {String productId = 'p1', bool active = false}) =>
      ProductionRecipesCompanion.insert(
        id: id,
        organizationId: 'org1',
        productId: productId,
        name: 'Recipe $id',
        isActive: Value(active),
        createdAt: now,
        updatedAt: now,
      );

  ProductionRecipeItemsCompanion line(String id, String recipeId,
          {String ingredient = 'flour', double qty = 1}) =>
      ProductionRecipeItemsCompanion.insert(
        id: id,
        recipeId: recipeId,
        ingredientProductId: ingredient,
        quantityPerUnit: qty,
        unit: 'kg',
        createdAt: now,
        updatedAt: now,
      );

  setUp(() {
    db = newTestDb();
    dao = db.productionRecipeDao;
  });
  tearDown(() => db.close());

  test('createWithItems persists recipe and its lines', () async {
    await dao.createWithItems(recipe('r1'), [line('l1', 'r1'), line('l2', 'r1')]);
    expect((await dao.byId('r1'))!.name, 'Recipe r1');
    expect((await dao.itemsFor('r1')).length, 2);
  });

  test('byId excludes soft-deleted recipes', () async {
    await dao.createWithItems(recipe('r1'), []);
    await dao.softDelete('r1', now);
    expect(await dao.byId('r1'), isNull);
    expect(await dao.allForOrg('org1'), isEmpty);
  });

  test('activate makes one recipe active and deactivates siblings for the product',
      () async {
    await dao.createWithItems(recipe('r1', active: true), []);
    await dao.createWithItems(recipe('r2'), []);
    await dao.createWithItems(recipe('rOther', productId: 'p2', active: true), []);

    await dao.activate('r2', now);

    expect((await dao.byId('r1'))!.isActive, isFalse);
    expect((await dao.byId('r2'))!.isActive, isTrue);
    // a recipe for a different product is untouched
    expect((await dao.byId('rOther'))!.isActive, isTrue);
    expect((await dao.activeForProduct('org1', 'p1'))!.id, 'r2');
  });

  test('forProduct returns non-deleted recipes for that product', () async {
    await dao.createWithItems(recipe('r1'), []);
    await dao.createWithItems(recipe('r2'), []);
    await dao.createWithItems(recipe('rOther', productId: 'p2'), []);
    final list = await dao.forProduct('org1', 'p1');
    expect(list.map((r) => r.id).toSet(), {'r1', 'r2'});
  });

  test('ingredient line add/update/remove', () async {
    await dao.createWithItems(recipe('r1'), [line('l1', 'r1', qty: 1)]);
    await dao.addItem(line('l2', 'r1', ingredient: 'sugar', qty: 3));
    expect((await dao.itemsFor('r1')).length, 2);

    await dao.updateItem(ProductionRecipeItemsCompanion(
      id: const Value('l1'),
      quantityPerUnit: const Value(5),
      updatedAt: Value(now),
    ));
    final l1 =
        (await dao.itemsFor('r1')).firstWhere((i) => i.id == 'l1');
    expect(l1.quantityPerUnit, 5);

    await dao.removeItem('l2');
    expect((await dao.itemsFor('r1')).length, 1);
  });
}
