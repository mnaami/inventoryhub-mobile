import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inventoryhub_mobile/app/theme/theme_controller.dart';
import 'package:inventoryhub_mobile/core/db/app_database.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/core/providers.dart';
import 'package:inventoryhub_mobile/core/seed/seed_service.dart';
import 'package:inventoryhub_mobile/l10n/app_localizations.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/presentation/sale_payment_list_screen.dart';
import '../../../helpers/test_db.dart';

void main() {
  testWidgets('renders a seeded payment row', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final db = newTestDb();
    addTearDown(db.close);
    final session = await SeedService(db, const IdGenerator()).ensureSeeded();
    final now = DateTime.utc(2026, 6, 1);
    await db.into(db.saleOrders).insert(SaleOrdersCompanion.insert(
          id: 'so1', organizationId: session.organizationId,
          soNumber: 'SO-0001', customerId: 'c1', orderDate: now,
          totalAmount: const Value(100), createdAt: now, updatedAt: now,
        ));
    await db.saleOrderPaymentDao.recordPayment(SaleOrderPaymentsCompanion.insert(
      id: 'p1', organizationId: session.organizationId, saleOrderId: 'so1',
      paymentNumber: 'PAY-0001', amount: 10, method: 'cash',
      status: const Value('completed'), paymentDate: now,
      createdAt: now, updatedAt: now,
    ));

    await tester.pumpWidget(ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        sessionProvider.overrideWithValue(session),
        sharedPrefsProvider.overrideWithValue(prefs),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SalePaymentListScreen(),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('PAY-0001'), findsOneWidget);
  });
}
