import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/db/app_database.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/core/result/app_exception.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:inventoryhub_mobile/features/employees/rate/data/production_pay_rate_dao.dart';
import 'package:inventoryhub_mobile/features/employees/rate/domain/production_pay_rate_service.dart';
import 'package:inventoryhub_mobile/features/production/production_order/data/production_order_dao.dart';
import 'package:inventoryhub_mobile/features/production/production_order/data/production_order_repository_impl.dart';
import 'package:inventoryhub_mobile/features/production/production_order/domain/production_order_enums.dart';
import 'package:inventoryhub_mobile/features/production/production_order/domain/production_order_usecases.dart';
import 'package:inventoryhub_mobile/features/production/recipe/data/production_recipe_dao.dart';
import 'package:inventoryhub_mobile/features/production/recipe/data/production_recipe_repository_impl.dart';
import 'package:inventoryhub_mobile/features/production/recipe/domain/production_recipe_usecases.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/data/document_counter_dao.dart';
import '../../../helpers/test_db.dart';

void main() {
  late AppDatabase db;
  late ProductionOrderService orders;
  late ProductionRecipeService recipes;
  final now = DateTime.utc(2026, 6, 27);

  Future<void> product(String id, double stock) =>
      db.into(db.products).insert(ProductsCompanion.insert(
            id: id, organizationId: 'org1', name: id, unitId: 'pc',
            currentStock: Value(stock), createdAt: now, updatedAt: now,
          ));

  setUp(() {
    db = newTestDb();
    const ids = IdGenerator();
    orders = ProductionOrderService(
      repository: ProductionOrderRepositoryImpl(ProductionOrderDao(db),
          ProductionRecipeDao(db), DocumentCounterDao(db)),
      ids: ids,
      organizationId: 'org1',
      userId: 'u1',
      rateService: ProductionPayRateService(
        dao: ProductionPayRateDao(db),
        ids: ids,
        organizationId: 'org1',
      ),
    );
    recipes = ProductionRecipeService(
      repository: ProductionRecipeRepositoryImpl(ProductionRecipeDao(db)),
      ids: ids,
      organizationId: 'org1',
    );
  });
  tearDown(() => db.close());

  test('createPlanned assigns a PRD number and planned status', () async {
    final o = await orders.createPlanned(productId: 'cake', quantity: 3);
    expect(o.orderNumber, startsWith('PRD-'));
    expect(o.status, ProductionOrderStatus.planned);
  });

  test('createPlanned rejects non-positive quantity', () async {
    expect(
      () => orders.createPlanned(productId: 'cake', quantity: 0),
      throwsA(isA<ValidationException>()),
    );
  });

  test('complete drives the flagship: stock moves and order completes',
      () async {
    await product('cake', 0);
    await product('flour', 100);
    await recipes.create(
      productId: 'cake',
      name: 'R',
      ingredients: const [
        NewIngredient(ingredientProductId: 'flour', quantityPerUnit: 2, unit: 'kg')
      ],
      activate: true,
    );
    final o = await orders.createPlanned(productId: 'cake', quantity: 10);
    await orders.complete(o);

    final cake = await (db.select(db.products)..where((p) => p.id.equals('cake'))).getSingle();
    final flour = await (db.select(db.products)..where((p) => p.id.equals('flour'))).getSingle();
    expect(cake.currentStock, 10);
    expect(flour.currentStock, 80);
    expect((await orders.get(o.id))!.status, ProductionOrderStatus.completed);
  });

  test('complete on a product without an active recipe throws', () async {
    await product('cake', 0);
    final o = await orders.createPlanned(productId: 'cake', quantity: 1);
    expect(() => orders.complete(o), throwsA(isA<ConflictException>()));
  });

  test('dashboard counts by status', () async {
    await orders.createPlanned(productId: 'cake', quantity: 1);
    await orders.createPlanned(productId: 'cake', quantity: 1);
    final k = await orders.dashboard();
    expect(k.planned, 2);
    expect(k.inProgress, 0);
    expect(k.completed, 0);
  });
}
