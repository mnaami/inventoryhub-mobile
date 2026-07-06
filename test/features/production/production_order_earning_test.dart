import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/db/app_database.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/features/employees/earning/data/production_earning_dao.dart';
import 'package:inventoryhub_mobile/features/employees/rate/data/production_pay_rate_dao.dart';
import 'package:inventoryhub_mobile/features/employees/rate/domain/production_pay_rate_service.dart';
import 'package:inventoryhub_mobile/features/production/production_order/data/production_order_dao.dart';
import 'package:inventoryhub_mobile/features/production/production_order/data/production_order_repository_impl.dart';
import 'package:inventoryhub_mobile/features/production/production_order/domain/production_order_usecases.dart';
import 'package:inventoryhub_mobile/features/production/recipe/data/production_recipe_dao.dart';
import 'package:inventoryhub_mobile/features/production/recipe/data/production_recipe_repository_impl.dart';
import 'package:inventoryhub_mobile/features/production/recipe/domain/production_recipe_usecases.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/data/document_counter_dao.dart';
import '../../helpers/test_db.dart';

class _Employee {
  const _Employee(this.id);
  final String id;
}

void main() {
  late AppDatabase db;
  late ProductionOrderService orderService;
  late ProductionRecipeService recipes;
  late ProductionPayRateService rateService;
  late ProductionEarningDao earningDao;
  final now = DateTime.utc(2026, 6, 27);
  const outputProductId = 'cake';
  const emp = _Employee('emp1');

  Future<void> product(String id, double stock) =>
      db.into(db.products).insert(ProductsCompanion.insert(
            id: id, organizationId: 'org1', name: id, unitId: 'pc',
            currentStock: Value(stock), createdAt: now, updatedAt: now,
          ));

  setUp(() async {
    db = newTestDb();
    const ids = IdGenerator();
    earningDao = ProductionEarningDao(db);
    rateService = ProductionPayRateService(
      dao: ProductionPayRateDao(db),
      ids: ids,
      organizationId: 'org1',
    );
    orderService = ProductionOrderService(
      repository: ProductionOrderRepositoryImpl(ProductionOrderDao(db),
          ProductionRecipeDao(db), DocumentCounterDao(db)),
      ids: ids,
      organizationId: 'org1',
      userId: 'u1',
      rateService: rateService,
    );
    recipes = ProductionRecipeService(
      repository: ProductionRecipeRepositoryImpl(ProductionRecipeDao(db)),
      ids: ids,
      organizationId: 'org1',
    );

    await db.into(db.employees).insert(EmployeesCompanion.insert(
          id: emp.id, organizationId: 'org1', name: 'Employee One',
          createdAt: now, updatedAt: now,
        ));
    await product(outputProductId, 0);
    await product('flour', 1000);
    await recipes.create(
      productId: outputProductId,
      name: 'R',
      ingredients: const [
        NewIngredient(
            ingredientProductId: 'flour', quantityPerUnit: 1, unit: 'kg')
      ],
      activate: true,
    );
  });
  tearDown(() => db.close());

  test('completing an attributed order creates a frozen-rate earning',
      () async {
    await rateService.setDefaultRate(outputProductId, 4.0);
    final order = await orderService.createPlanned(
        productId: outputProductId, quantity: 3, employeeId: emp.id);
    await orderService.complete(order);

    final earning = await earningDao.earningForOrder(order.id);
    expect(earning, isNotNull);
    expect(earning!.amount, 12.0); // 3 * 4
    expect(earning.rate, 4.0);
    expect(earning.employeeId, emp.id);

    // Changing the rate afterwards does NOT change the past earning.
    await rateService.setDefaultRate(outputProductId, 99.0);
    expect((await earningDao.earningForOrder(order.id))!.amount, 12.0);
  });

  test('no rate -> earning with amount 0, completion still succeeds',
      () async {
    final order = await orderService.createPlanned(
        productId: outputProductId, quantity: 3, employeeId: emp.id);
    await orderService.complete(order);
    expect((await earningDao.earningForOrder(order.id))!.amount, 0.0);
  });

  test('unattributed order creates no earning (unchanged behavior)',
      () async {
    final order = await orderService.createPlanned(
        productId: outputProductId, quantity: 3);
    await orderService.complete(order);
    expect(await earningDao.earningForOrder(order.id), isNull);
  });
}
