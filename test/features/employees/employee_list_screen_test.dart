import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventoryhub_mobile/app/currency/currency_controller.dart';
import 'package:inventoryhub_mobile/core/db/app_database.dart';
import 'package:inventoryhub_mobile/core/format/money_format.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/core/providers.dart';
import 'package:inventoryhub_mobile/core/seed/seed_service.dart';
import 'package:inventoryhub_mobile/features/employees/earning/data/production_earning_dao.dart';
import 'package:inventoryhub_mobile/features/employees/employee/presentation/employee_list_screen.dart';
import 'package:inventoryhub_mobile/features/employees/employee/presentation/employee_providers.dart';
import '../../helpers/l10n.dart';
import '../../helpers/test_db.dart';

void main() {
  testWidgets('renders employee names and a computed balance',
      (tester) async {
    final db = newTestDb();
    final session = await SeedService(db, const IdGenerator()).ensureSeeded();
    final container = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
      sessionProvider.overrideWithValue(session),
      moneyFormatterProvider
          .overrideWithValue((v) => formatMoney(v, Currency.usd)),
    ]);
    addTearDown(container.dispose);

    final employeeService = container.read(employeeServiceProvider);
    final withBalance = await employeeService.create(name: 'Sara Ahmed');
    await employeeService.create(name: 'Ali Hassan');

    // Seed a production earning so `withBalance` has a known, non-zero
    // balance (earned - paid = balance, no payments recorded).
    final earningDao = ProductionEarningDao(db);
    final now = DateTime.now().toUtc();
    await earningDao.into(earningDao.productionEarnings).insert(
          ProductionEarningsCompanion.insert(
            id: 'earn1',
            organizationId: session.organizationId,
            productionOrderId: 'order1',
            employeeId: withBalance.id,
            productId: 'prod1',
            quantity: 4.0,
            rate: 3.0,
            amount: 12.0,
            createdAt: now,
            updatedAt: now,
          ),
        );

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: localizedApp(home: const EmployeeListScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Sara Ahmed'), findsOneWidget);
    expect(find.text('Ali Hassan'), findsOneWidget);
    expect(find.text(formatMoney(12.0, Currency.usd)), findsOneWidget);
    expect(find.text(formatMoney(0.0, Currency.usd)), findsOneWidget);

    await db.close();
  });
}
