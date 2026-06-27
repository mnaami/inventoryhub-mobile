import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/db/app_database.dart';
import '../../helpers/test_db.dart';

void main() {
  final now = DateTime.utc(2026, 6, 27);

  test('v4 tables exist and accept rows', () async {
    final db = newTestDb();
    await db.into(db.productionRecipes).insert(ProductionRecipesCompanion.insert(
          id: 'r1',
          organizationId: 'org1',
          productId: 'p1',
          name: 'Cake recipe',
          createdAt: now,
          updatedAt: now,
        ));
    final r = await db.select(db.productionRecipes).getSingle();
    expect(r.name, 'Cake recipe');
    expect(r.isActive, isFalse); // default
    expect(r.isDeleted, isFalse); // default

    await db.into(db.productionRecipeItems).insert(
        ProductionRecipeItemsCompanion.insert(
          id: 'ri1',
          recipeId: 'r1',
          ingredientProductId: 'flour',
          quantityPerUnit: 2.5,
          unit: 'kg',
          createdAt: now,
          updatedAt: now,
        ));
    final item = await db.select(db.productionRecipeItems).getSingle();
    expect(item.quantityPerUnit, 2.5);

    await db.into(db.productionOrders).insert(ProductionOrdersCompanion.insert(
          id: 'o1',
          organizationId: 'org1',
          orderNumber: 'PRD-0001',
          productId: 'p1',
          quantity: 10,
          createdAt: now,
          updatedAt: now,
        ));
    final o = await db.select(db.productionOrders).getSingle();
    expect(o.status, 'planned'); // default
    expect(o.startDate, isNull);
    expect(o.completionDate, isNull);
    await db.close();
  });

  test('schemaVersion is 5', () {
    final db = newTestDb();
    expect(db.schemaVersion, 5);
    db.close();
  });
}
