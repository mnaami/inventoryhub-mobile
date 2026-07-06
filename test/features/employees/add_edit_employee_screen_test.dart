import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/core/providers.dart';
import 'package:inventoryhub_mobile/core/seed/seed_service.dart';
import 'package:inventoryhub_mobile/features/employees/employee/presentation/add_edit_employee_screen.dart';
import 'package:inventoryhub_mobile/features/employees/employee/presentation/employee_providers.dart';
import 'package:inventoryhub_mobile/l10n/app_localizations_en.dart';
import '../../helpers/l10n.dart';
import '../../helpers/test_db.dart';

void main() {
  testWidgets(
      'shows localized error and does not save when name is left blank',
      (tester) async {
    final db = newTestDb();
    addTearDown(db.close);
    final session = await SeedService(db, const IdGenerator()).ensureSeeded();
    final container = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
      sessionProvider.overrideWithValue(session),
    ]);
    addTearDown(container.dispose);

    final l10n = AppLocalizationsEn();

    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: localizedApp(home: const AddEditEmployeeScreen()),
    ));
    await tester.pumpAndSettle();

    // Leave name blank and tap Save.
    await tester.tap(find.widgetWithText(TextButton, l10n.employeeSaveButton));
    await tester.pumpAndSettle();

    // The localized required-name message must be shown (never the raw
    // English ValidationException text) — this is the l10n bug fix.
    expect(find.text(l10n.employeeNameRequiredError), findsOneWidget);

    // No employee should have been created.
    final employees = await container.read(employeeServiceProvider).list();
    expect(employees, isEmpty);
  });
}
