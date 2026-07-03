import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inventoryhub_mobile/app/currency/currency_controller.dart';
import 'package:inventoryhub_mobile/app/theme/theme_controller.dart';
import 'package:inventoryhub_mobile/core/format/money_format.dart';

Future<ProviderContainer> _container(Map<String, Object> prefs) async {
  SharedPreferences.setMockInitialValues(prefs);
  final sp = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPrefsProvider.overrideWithValue(sp)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('defaults to null when nothing is stored', () async {
    final c = await _container({});
    expect(c.read(currencyControllerProvider), isNull);
  });

  test('reads a persisted currency code on build', () async {
    final c = await _container({'app.currency': 'dzd'});
    expect(c.read(currencyControllerProvider), Currency.dzd);
  });

  test('set() updates state and persists the code', () async {
    final c = await _container({});
    await c.read(currencyControllerProvider.notifier).set(Currency.dzd);

    expect(c.read(currencyControllerProvider), Currency.dzd);
    final sp = await SharedPreferences.getInstance();
    expect(sp.getString('app.currency'), 'dzd');
  });

  test('moneyFormatterProvider follows the chosen currency', () async {
    final c = await _container({});
    // Falls back to USD before a choice is made.
    expect(c.read(moneyFormatterProvider)(1000), '\$1,000');

    await c.read(currencyControllerProvider.notifier).set(Currency.dzd);
    expect(c.read(moneyFormatterProvider)(1000), formatMoney(1000, Currency.dzd));
  });
}
