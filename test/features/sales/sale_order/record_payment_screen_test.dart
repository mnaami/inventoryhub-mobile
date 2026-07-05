import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventoryhub_mobile/app/currency/currency_controller.dart';
import 'package:inventoryhub_mobile/core/format/money_format.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/core/providers.dart';
import 'package:inventoryhub_mobile/core/seed/seed_service.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/presentation/record_payment_screen.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/presentation/sale_order_providers.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/domain/sale_order_usecases.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/domain/sale_order_enums.dart';
import '../../../helpers/l10n.dart';
import '../../../helpers/test_db.dart';

void main() {
  testWidgets('shows the remaining balance on the record-payment screen',
      (tester) async {
    final db = newTestDb();
    final session = await SeedService(db, const IdGenerator()).ensureSeeded();
    final container = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
      sessionProvider.overrideWithValue(session),
      moneyFormatterProvider.overrideWithValue((v) => formatMoney(v, Currency.usd)),
    ]);
    addTearDown(container.dispose);

    final service = container.read(saleOrderServiceProvider);
    final draft = await service.createDraft(
      customerId: 'c1',
      lines: [const NewLine(
          productId: 'p1', productName: 'Widget', quantity: 10, unitPrice: 10)],
    ); // total 100
    await service.confirm(draft);
    final confirmed = (await service.get(draft.id))!;
    await service.addPayment(confirmed, amount: 30, method: PaymentMethod.cash);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: localizedApp(home: RecordPaymentScreen(order: confirmed)),
    ));
    await tester.pumpAndSettle();

    // Remaining = total 100 - paid 30 = 70.
    expect(
      find.text('Remaining: ${formatMoney(70, Currency.usd)}'),
      findsOneWidget,
    );
    await db.close();
  });
}
