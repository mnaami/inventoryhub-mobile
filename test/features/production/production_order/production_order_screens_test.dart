import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/core/providers.dart';
import 'package:inventoryhub_mobile/core/seed/seed_service.dart';
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
}
