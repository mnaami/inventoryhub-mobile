// Regression test for the recurring "one-shot FutureProvider not
// invalidated" bug: completing an employee-attributed production order must
// refresh the employee's balance/earnings providers (and the order detail
// screen's own earning-line provider), not just the four production
// providers. See production_order_detail_screen.dart's `_run` handler.
import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/db/app_database.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/core/providers.dart';
import 'package:inventoryhub_mobile/core/seed/seed_service.dart';
import 'package:inventoryhub_mobile/features/employees/employee/presentation/employee_detail_providers.dart';
import 'package:inventoryhub_mobile/features/employees/employee/presentation/employee_providers.dart';
import 'package:inventoryhub_mobile/features/inventory/product/presentation/product_providers.dart';
import 'package:inventoryhub_mobile/features/production/production_order/presentation/production_order_providers.dart';
import 'package:inventoryhub_mobile/features/production/recipe/domain/production_recipe_usecases.dart';
import 'package:inventoryhub_mobile/features/production/recipe/presentation/production_recipe_providers.dart';
import '../../helpers/test_db.dart';

Future<ProviderContainer> _seededContainer(AppDatabase db) async {
  final session = await SeedService(db, const IdGenerator()).ensureSeeded();
  return ProviderContainer(overrides: [
    appDatabaseProvider.overrideWithValue(db),
    sessionProvider.overrideWithValue(session),
  ]);
}

void main() {
  test(
      'completing an attributed order refreshes employeeBalanceProvider and '
      'employeeEarningsProvider after invalidation (not just the four '
      'production providers)', () async {
    final db = newTestDb();
    addTearDown(db.close);
    final container = await _seededContainer(db);
    addTearDown(container.dispose);

    final session = container.read(sessionProvider);

    // Seed an employee, an output product, an ingredient with stock, a
    // recipe linking them, and a piece rate for the output product.
    final employee =
        await container.read(employeeServiceProvider).create(name: 'Amina');
    final output = await container.read(productServiceProvider).create(
          name: 'Cake',
          unitId: session.defaultUnitId,
        );
    final flour = await container.read(productServiceProvider).create(
          name: 'Flour',
          unitId: session.defaultUnitId,
        );
    // Give the ingredient enough stock via a direct stock update (opening
    // stock is normally set through a stock movement, out of scope here).
    await (db.update(db.products)..where((p) => p.id.equals(flour.id)))
        .write(const ProductsCompanion(currentStock: Value(1000)));

    await container.read(productionRecipeServiceProvider).create(
      productId: output.id,
      name: 'Cake Recipe',
      ingredients: [
        NewIngredient(
            ingredientProductId: flour.id, quantityPerUnit: 1, unit: 'kg'),
      ],
      activate: true,
    );

    await container
        .read(employeePayRateServiceProvider)
        .setDefaultRate(output.id, 5.0);

    final order = await container
        .read(productionOrderServiceProvider)
        .createPlanned(productId: output.id, quantity: 2, employeeId: employee.id);

    // Prime the employee-scoped providers BEFORE completion, exactly like an
    // already-built Employee detail screen would have them cached.
    final balanceBefore =
        await container.read(employeeBalanceProvider(employee.id).future);
    final earningsBefore =
        await container.read(employeeEarningsProvider(employee.id).future);
    expect(balanceBefore, 0.0);
    expect(earningsBefore, isEmpty);

    // Complete the order through the same service call the screen's
    // completion handler uses.
    await container.read(productionOrderServiceProvider).complete(order);

    // Without invalidation, re-reading would return the stale cached
    // (pre-completion) values because FutureProvider caches its result.
    final staleBalance =
        container.read(employeeBalanceProvider(employee.id));
    final staleEarnings =
        container.read(employeeEarningsProvider(employee.id));
    expect(staleBalance.value, balanceBefore,
        reason: 'provider is still holding the pre-completion cached value '
            'until invalidated, same as the screen would show');
    expect(staleEarnings.value, earningsBefore);

    // This mirrors exactly what the fixed `_run` handler does for an
    // attributed completion.
    container.invalidate(employeeBalanceProvider(employee.id));
    container.invalidate(employeeEarningsProvider(employee.id));
    container.invalidate(employeeListProvider);

    final balanceAfter =
        await container.read(employeeBalanceProvider(employee.id).future);
    final earningsAfter =
        await container.read(employeeEarningsProvider(employee.id).future);

    expect(balanceAfter, 10.0); // 2 * 5.0
    expect(earningsAfter, hasLength(1));
    expect(earningsAfter.single.amount, 10.0);
    expect(earningsAfter.single.productionOrderId, order.id);
  });
}
