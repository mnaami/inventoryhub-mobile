import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventoryhub_mobile/app/currency/currency_controller.dart';
import 'package:inventoryhub_mobile/core/format/money_format.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/core/providers.dart';
import 'package:inventoryhub_mobile/core/seed/seed_service.dart';
import 'package:inventoryhub_mobile/features/sales/customer/presentation/customer_providers.dart';
import 'package:inventoryhub_mobile/features/sales/customer/presentation/widgets/customer_quick_actions.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/domain/sale_order_usecases.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/presentation/sale_order_providers.dart';
import '../../../../../helpers/l10n.dart';
import '../../../../../helpers/test_db.dart';

/// The widget test environment has no platform implementation registered for
/// `url_launcher`'s method channel, so an un-mocked `canLaunchUrl` call would
/// hang forever waiting on a response that never arrives. Mock the channel
/// directly so `canLaunchUrl` resolves to `false`, exercising the widget's
/// "could not launch" fallback path deterministically.
const MethodChannel _urlLauncherChannel =
    MethodChannel('plugins.flutter.io/url_launcher');

Future<ProviderContainer> _seededContainer() async {
  final db = newTestDb();
  final session = await SeedService(db, const IdGenerator()).ensureSeeded();
  final container = ProviderContainer(overrides: [
    appDatabaseProvider.overrideWithValue(db),
    sessionProvider.overrideWithValue(session),
    moneyFormatterProvider.overrideWithValue((v) => formatMoney(v, Currency.usd)),
  ]);
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_urlLauncherChannel, (call) async {
      if (call.method == 'canLaunch') return false;
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_urlLauncherChannel, null);
  });

  testWidgets('shows only New Order when there is no balance and no phone',
      (tester) async {
    final container = await _seededContainer();
    addTearDown(container.dispose);
    final customer =
        await container.read(customerServiceProvider).create(name: 'Acme Co');

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: localizedApp(
          home: Scaffold(body: CustomerQuickActions(customer: customer))),
    ));
    await tester.pumpAndSettle();

    expect(find.text('New Order'), findsOneWidget);
    expect(find.text('Record Payment'), findsNothing);
    expect(find.text('Call'), findsNothing);
  });

  testWidgets('shows Record Payment when the customer has an outstanding balance',
      (tester) async {
    final container = await _seededContainer();
    addTearDown(container.dispose);
    final customer =
        await container.read(customerServiceProvider).create(name: 'Acme Co');
    final order = await container.read(saleOrderServiceProvider).createDraft(
      customerId: customer.id,
      lines: const [
        NewLine(
            productId: 'p1', productName: 'Widget', quantity: 1, unitPrice: 100),
      ],
    );
    await container.read(saleOrderServiceProvider).confirm(order);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: localizedApp(
          home: Scaffold(body: CustomerQuickActions(customer: customer))),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Record Payment'), findsOneWidget);
  });

  testWidgets('shows Call when the customer has a phone number',
      (tester) async {
    final container = await _seededContainer();
    addTearDown(container.dispose);
    final customer = await container
        .read(customerServiceProvider)
        .create(name: 'Acme Co', phones: const ['+15550001111']);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: localizedApp(
          home: Scaffold(body: CustomerQuickActions(customer: customer))),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Call'), findsOneWidget);
    await tester.tap(find.text('Call'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Could not launch phone call'), findsOneWidget);
  });
}
