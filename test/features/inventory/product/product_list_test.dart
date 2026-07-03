import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/core/providers.dart';
import 'package:inventoryhub_mobile/core/seed/seed_service.dart';
import 'package:inventoryhub_mobile/features/inventory/product/presentation/product_list_screen.dart';
import 'package:inventoryhub_mobile/features/inventory/product/presentation/product_providers.dart';
import 'package:inventoryhub_mobile/features/inventory/stock_movement/domain/stock_movement.dart';
import 'package:inventoryhub_mobile/features/inventory/stock_movement/presentation/stock_providers.dart';
import '../../../helpers/test_db.dart';
import '../../../helpers/l10n.dart';

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
      child: localizedApp(home: const ProductListScreen()),
    ));
    await tester.pumpAndSettle();
    expect(find.textContaining('No products yet'), findsOneWidget);

    final product = await container.read(productServiceProvider).create(
          name: 'Widget',
          unitId: session.defaultUnitId,
          minimumStock: 5,
        );
    // Record a stock-IN of +2 so stock (2) is positive but below minimum (5),
    // which triggers the Low badge rather than the Out badge.
    await container.read(stockServiceProvider).record(
          productId: product.id,
          type: MovementType.inbound,
          quantity: 2,
        );
    await container.read(productListProvider.notifier).refresh();
    await tester.pumpAndSettle();

    expect(find.text('Widget'), findsOneWidget);
    expect(find.text('Low'), findsOneWidget); // stock 2 < min 5 → Low
    await db.close();
  });
}
