import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventoryhub_mobile/app/currency/currency_controller.dart';
import 'package:inventoryhub_mobile/core/format/money_format.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/core/providers.dart';
import 'package:inventoryhub_mobile/core/seed/seed_service.dart';
import 'package:inventoryhub_mobile/features/sales/customer/presentation/customer_detail_screen.dart';
import 'package:inventoryhub_mobile/features/sales/customer/presentation/customer_providers.dart';
import 'package:inventoryhub_mobile/features/sales/customer/presentation/widgets/customer_business_snapshot_card.dart';
import 'package:inventoryhub_mobile/features/sales/customer/presentation/widgets/customer_credit_limit_bar.dart';
import 'package:inventoryhub_mobile/features/sales/customer/presentation/widgets/customer_quick_actions.dart';
import '../../../helpers/l10n.dart';
import '../../../helpers/test_db.dart';

Future<ProviderContainer> _seededContainer() async {
  final db = newTestDb();
  final session = await SeedService(db, const IdGenerator()).ensureSeeded();
  return ProviderContainer(overrides: [
    appDatabaseProvider.overrideWithValue(db),
    sessionProvider.overrideWithValue(session),
    moneyFormatterProvider.overrideWithValue((v) => formatMoney(v, Currency.usd)),
  ]);
}

void main() {
  testWidgets('shows quick actions and business snapshot, hides credit bar without a limit',
      (tester) async {
    final container = await _seededContainer();
    addTearDown(container.dispose);
    final customer =
        await container.read(customerServiceProvider).create(name: 'Acme Co');

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: localizedApp(home: CustomerDetailScreen(customerId: customer.id)),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(CustomerQuickActions), findsOneWidget);
    expect(find.byType(CustomerBusinessSnapshotCard), findsOneWidget);
    expect(find.byType(CustomerCreditLimitBar), findsNothing);

    // Existing content still present, just further down the page — scroll to
    // bring it into the viewport before asserting (the new sections above
    // push it below the fold).
    await tester.drag(find.byType(ListView), const Offset(0, -2000));
    await tester.pumpAndSettle();
    expect(find.text('Payment terms: 30 days'), findsOneWidget);
    // "No orders yet" now appears twice: once in the business snapshot
    // card's empty trend chart, once in the empty Orders card below it.
    expect(find.text('No orders yet'), findsNWidgets(2));
  });

  testWidgets('shows the credit-limit bar when a credit limit is set',
      (tester) async {
    final container = await _seededContainer();
    addTearDown(container.dispose);
    final customer = await container
        .read(customerServiceProvider)
        .create(name: 'Acme Co', creditLimit: 500);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: localizedApp(home: CustomerDetailScreen(customerId: customer.id)),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(CustomerCreditLimitBar), findsOneWidget);
  });

  testWidgets('quick actions appear above the header card, which appears above the orders section',
      (tester) async {
    final container = await _seededContainer();
    addTearDown(container.dispose);
    final customer =
        await container.read(customerServiceProvider).create(name: 'Acme Co');

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: localizedApp(home: CustomerDetailScreen(customerId: customer.id)),
    ));
    await tester.pumpAndSettle();

    final quickActionsY =
        tester.getTopLeft(find.byType(CustomerQuickActions)).dy;
    final snapshotY =
        tester.getTopLeft(find.byType(CustomerBusinessSnapshotCard)).dy;
    expect(quickActionsY, lessThan(snapshotY));

    // The Orders section header sits below the fold once the new sections
    // push content down, so scroll it into view before measuring it against
    // the snapshot card (re-measured in the same, post-scroll frame so both
    // coordinates share a scroll offset).
    await tester.drag(find.byType(ListView), const Offset(0, -2000));
    await tester.pumpAndSettle();
    final snapshotYAfterScroll =
        tester.getTopLeft(find.byType(CustomerBusinessSnapshotCard)).dy;
    final ordersHeaderY = tester.getTopLeft(find.text('Orders')).dy;

    expect(snapshotYAfterScroll, lessThan(ordersHeaderY));
  });
}
