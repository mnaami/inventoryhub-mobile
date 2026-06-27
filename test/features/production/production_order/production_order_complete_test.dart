import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/result/app_exception.dart';
import 'package:inventoryhub_mobile/core/db/app_database.dart';
import '../../../helpers/test_db.dart';

void main() {
  late AppDatabase db;
  final now = DateTime.utc(2026, 6, 27);

  Future<void> product(String id, double stock) =>
      db.into(db.products).insert(ProductsCompanion.insert(
            id: id, organizationId: 'org1', name: id, unitId: 'pc',
            currentStock: Value(stock), createdAt: now, updatedAt: now,
          ));

  Future<void> recipe(String id, String productId,
      {bool active = true, bool deleted = false}) =>
      db.into(db.productionRecipes).insert(ProductionRecipesCompanion.insert(
            id: id, organizationId: 'org1', productId: productId,
            name: 'R', isActive: Value(active), isDeleted: Value(deleted),
            createdAt: now, updatedAt: now,
          ));

  Future<void> ingredient(String id, String recipeId, String ing, double qpu) =>
      db.into(db.productionRecipeItems).insert(
          ProductionRecipeItemsCompanion.insert(
            id: id, recipeId: recipeId, ingredientProductId: ing,
            quantityPerUnit: qpu, unit: 'kg', createdAt: now, updatedAt: now,
          ));

  Future<void> order(String id, String productId, double qty,
      {String status = 'planned'}) =>
      db.into(db.productionOrders).insert(ProductionOrdersCompanion.insert(
            id: id, organizationId: 'org1', orderNumber: 'PRD-000$id',
            productId: productId, quantity: qty, status: Value(status),
            createdAt: now, updatedAt: now,
          ));

  setUp(() => db = newTestDb());
  tearDown(() => db.close());

  test('completing consumes ingredients (out) and produces output (in)',
      () async {
    await product('cake', 0);
    await product('flour', 100);
    await product('sugar', 100);
    await recipe('r1', 'cake');
    await ingredient('i1', 'r1', 'flour', 2); // 2 per cake
    await ingredient('i2', 'r1', 'sugar', 1);
    await order('o1', 'cake', 10); // -> needs 20 flour, 10 sugar, +10 cake

    await db.productionOrderDao.complete(
      orderId: 'o1',
      consumptionMovementIdByIngredient: {'flour': 'mf', 'sugar': 'ms'},
      outputMovementId: 'mo',
      createdBy: 'u1',
      now: now,
    );

    final flour =
        await (db.select(db.products)..where((p) => p.id.equals('flour'))).getSingle();
    final sugar =
        await (db.select(db.products)..where((p) => p.id.equals('sugar'))).getSingle();
    final cake =
        await (db.select(db.products)..where((p) => p.id.equals('cake'))).getSingle();
    expect(flour.currentStock, 80);
    expect(sugar.currentStock, 90);
    expect(cake.currentStock, 10);

    final moves = await db.select(db.stockMovements).get();
    expect(moves.length, 3);
    final out = moves.where((m) => m.movementType == 'out').toList();
    final inn = moves.where((m) => m.movementType == 'in').single;
    expect(out.length, 2);
    expect(out.every((m) => m.quantity < 0), isTrue);
    expect(inn.quantity, 10);
    expect(inn.referenceType, 'production_order');
    expect(inn.referenceId, 'o1');

    final o = await (db.select(db.productionOrders)..where((x) => x.id.equals('o1'))).getSingle();
    expect(o.status, 'completed');
    expect(o.completionDate!.millisecondsSinceEpoch, now.millisecondsSinceEpoch);
  });

  test('insufficient ingredient stock blocks and records nothing', () async {
    await product('cake', 0);
    await product('flour', 5); // need 20
    await recipe('r1', 'cake');
    await ingredient('i1', 'r1', 'flour', 2);
    await order('o1', 'cake', 10);

    await expectLater(
      db.productionOrderDao.complete(
        orderId: 'o1',
        consumptionMovementIdByIngredient: {'flour': 'mf'},
        outputMovementId: 'mo',
        createdBy: 'u1',
        now: now,
      ),
      throwsA(isA<ConflictException>()),
    );
    expect(await db.select(db.stockMovements).get(), isEmpty);
    final flour =
        await (db.select(db.products)..where((p) => p.id.equals('flour'))).getSingle();
    expect(flour.currentStock, 5); // unchanged
    final o = await (db.select(db.productionOrders)..where((x) => x.id.equals('o1'))).getSingle();
    expect(o.status, 'planned'); // unchanged
  });

  test('no active recipe blocks completion', () async {
    await product('cake', 0);
    await recipe('r1', 'cake', active: false); // not active
    await order('o1', 'cake', 1);
    await expectLater(
      db.productionOrderDao.complete(
        orderId: 'o1',
        consumptionMovementIdByIngredient: const {},
        outputMovementId: 'mo',
        createdBy: 'u1',
        now: now,
      ),
      throwsA(isA<ConflictException>()),
    );
    expect(await db.select(db.stockMovements).get(), isEmpty);
  });

  test('empty active recipe blocks completion', () async {
    await product('cake', 0);
    await recipe('r1', 'cake'); // active, no ingredients
    await order('o1', 'cake', 1);
    await expectLater(
      db.productionOrderDao.complete(
        orderId: 'o1',
        consumptionMovementIdByIngredient: const {},
        outputMovementId: 'mo',
        createdBy: 'u1',
        now: now,
      ),
      throwsA(isA<ConflictException>()),
    );
    expect(await db.select(db.stockMovements).get(), isEmpty);
  });

  test('duplicate ingredient lines are aggregated for the stock check', () async {
    await product('cake', 0);
    await product('flour', 15); // two lines of 1/unit * 10 = 20 needed > 15
    await recipe('r1', 'cake');
    await ingredient('i1', 'r1', 'flour', 1);
    await ingredient('i2', 'r1', 'flour', 1); // same ingredient again
    await order('o1', 'cake', 10);
    await expectLater(
      db.productionOrderDao.complete(
        orderId: 'o1',
        consumptionMovementIdByIngredient: {'flour': 'mf'},
        outputMovementId: 'mo',
        createdBy: 'u1',
        now: now,
      ),
      throwsA(isA<ConflictException>()),
    );
    expect(await db.select(db.stockMovements).get(), isEmpty);
  });

  test('completing a terminal order is rejected', () async {
    await product('cake', 0);
    await recipe('r1', 'cake');
    await ingredient('i1', 'r1', 'flour', 1);
    await product('flour', 100);
    await order('o1', 'cake', 1, status: 'completed');
    await expectLater(
      db.productionOrderDao.complete(
        orderId: 'o1',
        consumptionMovementIdByIngredient: {'flour': 'mf'},
        outputMovementId: 'mo',
        createdBy: 'u1',
        now: now,
      ),
      throwsA(isA<ConflictException>()),
    );
  });
}
