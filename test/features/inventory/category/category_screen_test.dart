import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/core/providers.dart';
import 'package:inventoryhub_mobile/core/seed/seed_service.dart';
import 'package:inventoryhub_mobile/features/inventory/category/presentation/category_management_screen.dart';
import 'package:inventoryhub_mobile/features/inventory/category/presentation/category_providers.dart';
import '../../../helpers/test_db.dart';
import '../../../helpers/l10n.dart';

void main() {
  testWidgets('shows empty state then a created category', (tester) async {
    final db = newTestDb();
    final session = await SeedService(db, const IdGenerator()).ensureSeeded();
    final container = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
      sessionProvider.overrideWithValue(session),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: localizedApp(home: const CategoryManagementScreen()),
    ));
    await tester.pumpAndSettle();
    expect(find.textContaining('No categories yet'), findsOneWidget);

    await container.read(categoryServiceProvider).create(name: 'Food');
    container.invalidate(categoryTreeProvider);
    await tester.pumpAndSettle();
    expect(find.text('Food'), findsOneWidget);
  });
}
