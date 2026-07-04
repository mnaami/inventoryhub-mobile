import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inventoryhub_mobile/app/theme/theme_controller.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/core/providers.dart';
import 'package:inventoryhub_mobile/core/seed/seed_service.dart';
import 'package:inventoryhub_mobile/features/inventory/product/presentation/product_dashboard_screen.dart';
import 'package:inventoryhub_mobile/features/inventory/product/presentation/widgets/product_swipeable_statistics_section.dart';
import '../../../helpers/test_db.dart';
import '../../../helpers/l10n.dart';

void main() {
  testWidgets('quick actions appear above the swipeable statistics on the product dashboard', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final db = newTestDb();
    final session = await SeedService(db, const IdGenerator()).ensureSeeded();
    final container = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
      sessionProvider.overrideWithValue(session),
      sharedPrefsProvider.overrideWithValue(prefs),
    ]);
    addTearDown(() async {
      container.dispose();
      await db.close();
    });

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: localizedApp(home: const ProductDashboardScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Quick Actions'), findsOneWidget);
    expect(find.byType(ProductSwipeableStatisticsSection), findsOneWidget);

    final quickActionsY = tester.getTopLeft(find.text('Quick Actions')).dy;
    final statsY = tester.getTopLeft(find.byType(ProductSwipeableStatisticsSection)).dy;

    expect(quickActionsY, lessThan(statsY));
  });
}
