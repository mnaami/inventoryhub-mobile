import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventoryhub_mobile/app/currency/currency_controller.dart';
import 'package:inventoryhub_mobile/core/format/money_format.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/core/providers.dart';
import 'package:inventoryhub_mobile/core/seed/seed_service.dart';
import 'package:inventoryhub_mobile/features/employees/employee/presentation/employee_providers.dart';
import 'package:inventoryhub_mobile/features/inventory/product/presentation/product_providers.dart';
import 'package:inventoryhub_mobile/features/production/presentation/piece_rates_screen.dart';
import 'package:inventoryhub_mobile/l10n/app_localizations_en.dart';
import '../../helpers/l10n.dart';
import '../../helpers/test_db.dart';

void main() {
  testWidgets(
      'lists products with their default rate and persists an edited rate',
      (tester) async {
    final db = newTestDb();
    addTearDown(db.close);
    final session = await SeedService(db, const IdGenerator()).ensureSeeded();
    final container = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
      sessionProvider.overrideWithValue(session),
      moneyFormatterProvider
          .overrideWithValue((v) => formatMoney(v, Currency.usd)),
    ]);
    addTearDown(container.dispose);

    final productService = container.read(productServiceProvider);
    final rated = await productService.create(
      name: 'Rated Product',
      unitId: session.defaultUnitId,
    );
    final unrated = await productService.create(
      name: 'Unrated Product',
      unitId: session.defaultUnitId,
    );

    final rateService = container.read(employeePayRateServiceProvider);
    await rateService.setDefaultRate(rated.id, 5);

    final l10n = AppLocalizationsEn();

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: localizedApp(home: const PieceRatesScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Rated Product'), findsOneWidget);
    expect(find.text('Unrated Product'), findsOneWidget);

    // Rated product's field shows the plain number 5 (not money-formatted).
    expect(find.widgetWithText(TextField, '5'), findsOneWidget);

    // Edit the unrated product's rate field (currently empty/0) to 7 and save.
    final unratedFieldFinder = find.byKey(Key('piece_rate_field_${unrated.id}'));
    expect(unratedFieldFinder, findsOneWidget);
    await tester.enterText(unratedFieldFinder, '7');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    final saveButtonFinder =
        find.byKey(Key('piece_rate_save_${unrated.id}'));
    expect(saveButtonFinder, findsOneWidget);
    await tester.tap(saveButtonFinder);
    await tester.pumpAndSettle();

    expect(find.text(l10n.pieceRateSavedMessage), findsOneWidget);

    final persisted = await rateService.resolveRate(
        employeeId: 'unknown-employee', productId: unrated.id);
    expect(persisted, 7.0);
  });
}
