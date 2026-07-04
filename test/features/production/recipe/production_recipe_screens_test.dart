import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:inventoryhub_mobile/core/db/app_database.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/core/providers.dart';
import 'package:inventoryhub_mobile/core/seed/seed_service.dart';
import 'package:inventoryhub_mobile/features/production/recipe/presentation/production_recipe_detail_screen.dart';
import 'package:inventoryhub_mobile/features/production/recipe/presentation/production_recipe_list_screen.dart';
import 'package:inventoryhub_mobile/features/production/recipe/presentation/production_recipe_providers.dart';
import '../../../helpers/l10n.dart';
import '../../../helpers/test_db.dart';

void main() {
  testWidgets('recipe list shows the empty state, then a created recipe',
      (tester) async {
    final db = newTestDb();
    final session = await SeedService(db, const IdGenerator()).ensureSeeded();
    final container = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
      sessionProvider.overrideWithValue(session),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: localizedApp(home: const ProductionRecipeListScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Recipes'), findsOneWidget);
    expect(find.textContaining('No recipes yet'), findsOneWidget);

    // Create one through the service, then rebuild and confirm it lists.
    await container
        .read(productionRecipeServiceProvider)
        .create(productId: 'cake', name: 'Standard cake', activate: true);
    container.invalidate(recipesProvider);
    await tester.pumpAndSettle();

    expect(find.text('Standard cake'), findsOneWidget);
    await db.close();
  });

  testWidgets('detail screen adds, edits, and removes ingredients',
      (tester) async {
    final db = newTestDb();
    final session = await SeedService(db, const IdGenerator()).ensureSeeded();
    final container = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
      sessionProvider.overrideWithValue(session),
    ]);
    addTearDown(container.dispose);

    final now = DateTime.now().toUtc();
    // Output product + one candidate ingredient, both on the seeded unit ('pc').
    for (final (id, name) in [('cake', 'Chocolate Cake'), ('flour', 'Flour Bag')]) {
      await db.into(db.products).insert(ProductsCompanion.insert(
            id: id,
            organizationId: session.organizationId,
            name: name,
            unitId: session.defaultUnitId,
            createdAt: now,
            updatedAt: now,
          ));
    }

    final recipe = await container.read(productionRecipeServiceProvider).create(
          productId: 'cake',
          name: 'Standard cake',
          activate: true,
        );

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: localizedApp(
        home: ProductionRecipeDetailScreen(recipeId: recipe.id),
      ),
    ));
    await tester.pumpAndSettle();

    // Empty state is shown, and the output product resolves to its name.
    expect(find.textContaining('No ingredients yet'), findsOneWidget);
    expect(find.textContaining('Chocolate Cake'), findsOneWidget);

    // Add an ingredient via the FAB + bottom sheet.
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('Add ingredient'), findsOneWidget);

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Flour Bag').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '2');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Row shows the ingredient with its derived unit ('pc') and formatted qty.
    expect(find.text('Flour Bag'), findsOneWidget);
    expect(find.textContaining('2 pc / unit'), findsOneWidget);

    // Edit the quantity by tapping the row.
    await tester.tap(find.text('Flour Bag'));
    await tester.pumpAndSettle();
    expect(find.text('Edit ingredient'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '5');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.textContaining('5 pc / unit'), findsOneWidget);

    // Remove it and land back on the empty state.
    await tester.tap(find.text('Flour Bag'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();
    expect(find.text('Flour Bag'), findsNothing);
    expect(find.textContaining('No ingredients yet'), findsOneWidget);

    await db.close();
  });
}
