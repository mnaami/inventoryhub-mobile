import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/core/providers.dart';
import 'package:inventoryhub_mobile/core/seed/seed_service.dart';
import 'package:inventoryhub_mobile/features/sales/customer/presentation/add_edit_customer_screen.dart';
import '../../../helpers/test_db.dart';

void main() {
  testWidgets('shows validation error when name is empty', (tester) async {
    final db = newTestDb();
    final session = await SeedService(db, const IdGenerator()).ensureSeeded();
    final container = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
      sessionProvider.overrideWithValue(session),
    ]);
    addTearDown(container.dispose);

    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: AddEditCustomerScreen()),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();
    expect(find.text('Customer name is required.'), findsOneWidget);
    await db.close();
  });
}
