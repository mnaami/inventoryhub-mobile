import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/core/providers.dart';
import 'package:inventoryhub_mobile/core/seed/seed_service.dart';
import 'package:inventoryhub_mobile/features/inventory/product/presentation/product_list_screen.dart';
import 'package:inventoryhub_mobile/features/inventory/product/presentation/product_providers.dart';
import '../../../helpers/test_db.dart';

void main() {
  testWidgets('empty state, then a low-stock product appears', (tester) async {
    final db = newTestDb();
    final session = await SeedService(db, const IdGenerator()).ensureSeeded();
    final container = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
      sessionProvider.overrideWithValue(session),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: ProductListScreen()),
    ));
    await tester.pumpAndSettle();
    expect(find.textContaining('No products yet'), findsOneWidget);

    await container.read(productServiceProvider).create(
          name: 'Widget',
          unitId: session.defaultUnitId,
          minimumStock: 5,
        );
    await container.read(productListProvider.notifier).refresh();
    await tester.pumpAndSettle();

    expect(find.text('Widget'), findsOneWidget);
    expect(find.text('Low'), findsOneWidget); // stock 0 ≤ min 5
    await db.close();
  });
}
