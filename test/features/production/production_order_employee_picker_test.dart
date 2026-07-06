import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/core/providers.dart';
import 'package:inventoryhub_mobile/core/seed/seed_service.dart';
import 'package:inventoryhub_mobile/features/employees/employee/presentation/employee_providers.dart';
import 'package:inventoryhub_mobile/features/inventory/product/presentation/product_providers.dart';
import 'package:inventoryhub_mobile/features/production/production_order/presentation/create_production_order_screen.dart';
import 'package:inventoryhub_mobile/features/production/production_order/presentation/production_order_providers.dart';
import 'package:inventoryhub_mobile/l10n/app_localizations_en.dart';
import '../../helpers/l10n.dart';
import '../../helpers/test_db.dart';

void main() {
  testWidgets(
      'Assigned to control defaults to none; selecting an employee persists '
      'employeeId on the created order', (tester) async {
    final db = newTestDb();
    addTearDown(db.close);
    final session = await SeedService(db, const IdGenerator()).ensureSeeded();
    final container = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
      sessionProvider.overrideWithValue(session),
    ]);
    addTearDown(container.dispose);

    final product = await container.read(productServiceProvider).create(
          name: 'Cake',
          unitId: session.defaultUnitId,
        );
    final employee = await container
        .read(employeeServiceProvider)
        .create(name: 'Sara Ahmed');

    final l10n = AppLocalizationsEn();

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: localizedApp(home: const CreateProductionOrderScreen()),
    ));
    await tester.pumpAndSettle();

    // "Assigned to" control exists and defaults to none.
    expect(find.text(l10n.productionAssignedTo), findsOneWidget);
    expect(find.text(l10n.productionAssignedToNone), findsOneWidget);

    // Choose the output product and quantity.
    await tester.tap(find.widgetWithText(
        DropdownButtonFormField<String>, l10n.productionOutputProductLabel));
    await tester.pumpAndSettle();
    await tester.tap(find.text(product.name).last);
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextField, l10n.productionQuantityLabel), '2');

    // Choose the employee from the assigned-to dropdown.
    await tester.tap(find.widgetWithText(
        DropdownButtonFormField<String?>, l10n.productionAssignedTo));
    await tester.pumpAndSettle();
    await tester.tap(find.text(employee.name).last);
    await tester.pumpAndSettle();

    await tester
        .tap(find.widgetWithText(FilledButton, l10n.productionCreateButton));
    await tester.pumpAndSettle();

    final orders = await container.read(productionOrderServiceProvider).list();
    expect(orders, hasLength(1));
    final persisted =
        await container.read(productionOrderServiceProvider).get(orders.first.id);
    expect(persisted!.employeeId, employee.id);
  });
}
