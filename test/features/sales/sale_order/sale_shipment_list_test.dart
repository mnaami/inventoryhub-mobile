import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inventoryhub_mobile/app/theme/theme_controller.dart';
import 'package:inventoryhub_mobile/core/db/app_database.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/core/providers.dart';
import 'package:inventoryhub_mobile/core/seed/seed_service.dart';
import 'package:inventoryhub_mobile/l10n/app_localizations.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/presentation/sale_shipment_list_screen.dart';
import '../../../helpers/test_db.dart';

void main() {
  testWidgets('renders a seeded shipment row', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final db = newTestDb();
    addTearDown(db.close);
    final session = await SeedService(db, const IdGenerator()).ensureSeeded();
    final now = DateTime.utc(2026, 6, 1);
    await db.into(db.saleOrders).insert(SaleOrdersCompanion.insert(
          id: 'so1', organizationId: session.organizationId,
          soNumber: 'SO-0001', customerId: 'c1', orderDate: now,
          createdAt: now, updatedAt: now,
        ));
    await db.into(db.saleOrderShippings).insert(SaleOrderShippingsCompanion.insert(
          id: 's1', organizationId: session.organizationId, saleOrderId: 'so1',
          soShippingNumber: 'SHP-0001', shippingDate: now,
          status: const Value('shipped'), createdAt: now, updatedAt: now,
        ));

    await tester.pumpWidget(ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        sessionProvider.overrideWithValue(session),
        sharedPrefsProvider.overrideWithValue(
            await SharedPreferences.getInstance()),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SaleShipmentListScreen(),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('SHP-0001'), findsOneWidget);
  });
}
