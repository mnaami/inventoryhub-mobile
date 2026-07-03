import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/core/providers.dart';
import 'package:inventoryhub_mobile/core/seed/seed_service.dart';
import 'package:inventoryhub_mobile/features/inventory/product/presentation/product_providers.dart';
import 'package:inventoryhub_mobile/features/inventory/stock_movement/domain/stock_movement.dart';
import 'package:inventoryhub_mobile/features/inventory/stock_movement/presentation/record_movement_screen.dart';
import 'package:inventoryhub_mobile/features/inventory/stock_movement/presentation/stock_providers.dart';
import '../../../helpers/test_db.dart';
import '../../../helpers/l10n.dart';

void main() {
  testWidgets('recording an inbound movement raises current stock',
      (tester) async {
    final db = newTestDb();
    final session = await SeedService(db, const IdGenerator()).ensureSeeded();
    final container = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
      sessionProvider.overrideWithValue(session),
    ]);
    addTearDown(container.dispose);

    final product = await container.read(productServiceProvider).create(
          name: 'Widget',
          unitId: session.defaultUnitId,
        );

    // Use a tall viewport so the FilledButton is visible in the scrollable form.
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: localizedApp(
        home: RecordMovementScreen(
            productId: product.id, productName: product.name),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, '15');
    await tester.tap(find.widgetWithText(FilledButton, 'Record'));
    await tester.pumpAndSettle();

    final reloaded = await container.read(productServiceProvider).get(product.id);
    expect(reloaded!.currentStock, 15);

    final history =
        await container.read(stockServiceProvider).history(product.id);
    expect(history.single.type, MovementType.inbound);
    await db.close();
  });
}
