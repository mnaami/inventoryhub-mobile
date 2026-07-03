import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventoryhub_mobile/app/currency/currency_controller.dart';
import 'package:inventoryhub_mobile/core/format/money_format.dart';
import 'package:inventoryhub_mobile/features/sales/customer/presentation/widgets/customer_credit_limit_bar.dart';

Future<void> _pump(
  WidgetTester tester, {
  required double outstanding,
  required double creditLimit,
}) async {
  final container = ProviderContainer(overrides: [
    moneyFormatterProvider
        .overrideWithValue((v) => formatMoney(v, Currency.usd)),
  ]);
  addTearDown(container.dispose);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      home: Scaffold(
        body: CustomerCreditLimitBar(
            outstanding: outstanding, creditLimit: creditLimit),
      ),
    ),
  ));
}

void main() {
  testWidgets('shows outstanding / limit text and clamps the bar at 100%',
      (tester) async {
    await _pump(tester, outstanding: 150, creditLimit: 100);
    expect(find.textContaining(formatMoney(150, Currency.usd)), findsOneWidget);
    expect(find.textContaining(formatMoney(100, Currency.usd)), findsOneWidget);
    final bar = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator));
    expect(bar.value, 1.0);
  });

  testWidgets('green under 70%, amber 70-100%, red over 100%',
      (tester) async {
    await _pump(tester, outstanding: 50, creditLimit: 100);
    var bar = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator));
    expect((bar.valueColor as AlwaysStoppedAnimation<Color>).value,
        const Color(0xFF15803D));

    await _pump(tester, outstanding: 80, creditLimit: 100);
    bar = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator));
    expect((bar.valueColor as AlwaysStoppedAnimation<Color>).value,
        const Color(0xFFB45309));

    await _pump(tester, outstanding: 120, creditLimit: 100);
    bar = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator));
    expect((bar.valueColor as AlwaysStoppedAnimation<Color>).value,
        const Color(0xFFB91C1C));
  });
}
