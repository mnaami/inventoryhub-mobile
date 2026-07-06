import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventoryhub_mobile/app/currency/currency_controller.dart';
import 'package:inventoryhub_mobile/core/db/app_database.dart';
import 'package:inventoryhub_mobile/core/format/money_format.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/core/providers.dart';
import 'package:inventoryhub_mobile/core/seed/seed_service.dart';
import 'package:inventoryhub_mobile/features/employees/earning/data/production_earning_dao.dart';
import 'package:inventoryhub_mobile/features/employees/employee/presentation/employee_detail_screen.dart';
import 'package:inventoryhub_mobile/features/employees/employee/presentation/employee_providers.dart';
import 'package:inventoryhub_mobile/features/inventory/product/presentation/product_providers.dart';
import 'package:inventoryhub_mobile/l10n/app_localizations_en.dart';
import '../../helpers/l10n.dart';
import '../../helpers/test_db.dart';

Future<ProviderContainer> _seededContainer(AppDatabase db) async {
  final session = await SeedService(db, const IdGenerator()).ensureSeeded();
  return ProviderContainer(overrides: [
    appDatabaseProvider.overrideWithValue(db),
    sessionProvider.overrideWithValue(session),
    moneyFormatterProvider
        .overrideWithValue((v) => formatMoney(v, Currency.usd)),
  ]);
}

void main() {
  testWidgets(
      'shows balance (earned - paid), an earning row, and recording a '
      'payment updates the balance and payments list', (tester) async {
    final db = newTestDb();
    addTearDown(db.close);
    final container = await _seededContainer(db);
    addTearDown(container.dispose);

    final session = container.read(sessionProvider);
    final employee = await container
        .read(employeeServiceProvider)
        .create(name: 'Sara Ahmed');
    final product = await container.read(productServiceProvider).create(
          name: 'Widget',
          unitId: session.defaultUnitId,
        );

    final earningDao = ProductionEarningDao(db);
    final now = DateTime.now().toUtc();
    await earningDao.into(earningDao.productionEarnings).insert(
          ProductionEarningsCompanion.insert(
            id: 'earn1',
            organizationId: session.organizationId,
            productionOrderId: 'order1',
            employeeId: employee.id,
            productId: product.id,
            quantity: 4.0,
            rate: 3.0,
            amount: 12.0,
            createdAt: now,
            updatedAt: now,
          ),
        );

    await container.read(employeePaymentServiceProvider).record(
          employeeId: employee.id,
          amount: 5.0,
          paymentDate: now,
        );

    String money(num v) => formatMoney(v, Currency.usd);
    final l10n = AppLocalizationsEn();

    // Tall viewport so every section (header, quick action, earnings,
    // payments, overrides) is built and findable without scrolling.
    tester.view.physicalSize = const Size(1080, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: localizedApp(home: EmployeeDetailScreen(employeeId: employee.id)),
    ));
    await tester.pumpAndSettle();

    // Balance = earned(12) - paid(5) = 7.
    expect(find.text(money(7.0)), findsOneWidget);

    // Earning row shows product name + amount.
    expect(find.text(product.name), findsOneWidget);
    expect(find.text(money(12.0)), findsOneWidget);

    // Existing payment appears (EPAY-#### + amount).
    expect(find.textContaining('EPAY-'), findsOneWidget);
    expect(find.text(money(5.0)), findsOneWidget);

    // Record a new payment via the quick action.
    await tester.tap(find.byIcon(Icons.payments_outlined));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '3');
    await tester.tap(find.widgetWithText(FilledButton, l10n.employeeSaveButton));
    await tester.pumpAndSettle();

    // Balance updates: 12 - (5 + 3) = 4 — verifies the invalidation contract
    // (balance/payments/list providers all refresh after recording).
    expect(find.text(money(4.0)), findsOneWidget);
    // Two payments now listed.
    expect(find.textContaining('EPAY-'), findsNWidgets(2));
  });
}
