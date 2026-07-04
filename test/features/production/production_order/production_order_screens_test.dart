import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:inventoryhub_mobile/core/db/app_database.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/core/providers.dart';
import 'package:inventoryhub_mobile/core/seed/seed_service.dart';
import 'package:inventoryhub_mobile/features/production/production_order/presentation/production_order_detail_screen.dart';
import 'package:inventoryhub_mobile/features/production/production_order/presentation/production_order_list_screen.dart';
import 'package:inventoryhub_mobile/features/production/production_order/presentation/production_order_providers.dart';
import '../../../helpers/l10n.dart';
import '../../../helpers/test_db.dart';

void main() {
  testWidgets('order list renders a created production order', (tester) async {
    final db = newTestDb();
    final session = await SeedService(db, const IdGenerator()).ensureSeeded();
    final container = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
      sessionProvider.overrideWithValue(session),
    ]);
    addTearDown(container.dispose);

    await container
        .read(productionOrderServiceProvider)
        .createPlanned(productId: 'p1', quantity: 4);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: localizedApp(home: const ProductionOrderListScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Production orders'), findsOneWidget);
    expect(find.textContaining('PRD-'), findsOneWidget);
    await db.close();
  });

  testWidgets('detail screen renders output product and ingredients checklist',
      (tester) async {
    final db = newTestDb();
    final session = await SeedService(db, const IdGenerator()).ensureSeeded();
    final container = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
      sessionProvider.overrideWithValue(session),
    ]);
    addTearDown(container.dispose);

    final now = DateTime.now().toUtc();

    // 1. Create output product and ingredient product
    await db.into(db.products).insert(ProductsCompanion.insert(
          id: 'cake',
          organizationId: session.organizationId,
          name: 'Chocolate Cake',
          unitId: session.defaultUnitId, // seeded unit, symbol 'pc'
          currentStock: const Value(0.0),
          minimumStock: const Value(5.0),
          barcode: const Value('12345'),
          createdAt: now,
          updatedAt: now,
        ));
    await db.into(db.products).insert(ProductsCompanion.insert(
          id: 'flour',
          organizationId: session.organizationId,
          name: 'Flour Bag',
          unitId: 'kg',
          currentStock: const Value(10.0), // We need 20 for 10 cakes (2kg per cake) -> insufficient stock!
          minimumStock: const Value(2.0),
          createdAt: now,
          updatedAt: now,
        ));

    // 2. Create recipe and ingredient item
    await db.into(db.productionRecipes).insert(ProductionRecipesCompanion.insert(
          id: 'r1',
          organizationId: session.organizationId,
          productId: 'cake',
          name: 'Cake Standard Recipe',
          isActive: const Value(true),
          isDeleted: const Value(false),
          createdAt: now,
          updatedAt: now,
        ));
    await db.into(db.productionRecipeItems).insert(
        ProductionRecipeItemsCompanion.insert(
          id: 'ri1',
          recipeId: 'r1',
          ingredientProductId: 'flour',
          quantityPerUnit: 2.0,
          unit: 'kg',
          createdAt: now,
          updatedAt: now,
        ));

    // 3. Create planned production order for 10 cakes
    const orderId = 'o1';
    await db.into(db.productionOrders).insert(ProductionOrdersCompanion.insert(
          id: orderId,
          organizationId: session.organizationId,
          orderNumber: 'PRD-0001',
          productId: 'cake',
          quantity: 10.0,
          status: const Value('planned'),
          createdAt: now,
          updatedAt: now,
        ));

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: localizedApp(
        home: const ProductionOrderDetailScreen(orderId: orderId),
      ),
    ));
    await tester.pumpAndSettle();

    // Verify detail screen content
    expect(find.text('PRD-0001'), findsOneWidget);
    expect(find.text('Planned'), findsOneWidget);
    expect(find.text('Chocolate Cake'), findsOneWidget);
    expect(find.text('Barcode: 12345'), findsOneWidget);
    // Unit id is resolved to its symbol ('pc') and quantity is formatted.
    expect(find.text('10 pc'), findsOneWidget); // target qty
    expect(find.text('0 pc'), findsOneWidget); // on-hand stock

    // Verify recipe and ingredients checklist
    expect(find.text('Recipe: Cake Standard Recipe'), findsOneWidget);
    expect(find.text('Flour Bag'), findsOneWidget);
    expect(find.textContaining('Required: 20 kg'), findsOneWidget);
    expect(find.textContaining('Available: 10 kg'), findsOneWidget);
    expect(find.text('Need 10'), findsOneWidget); // shortfall warning

    await db.close();
  });
}
