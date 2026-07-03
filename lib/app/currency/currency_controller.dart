import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/format/money_format.dart';
import '../theme/theme_controller.dart'; // sharedPrefsProvider

/// The user's chosen display currency. `null` means "not chosen yet" — the
/// onboarding currency gate keys off this, so no separate flag is needed.
///
/// Mirrors [ThemeController]/[LocaleController]: prefs-backed, reuses
/// [sharedPrefsProvider].
final currencyControllerProvider =
    NotifierProvider<CurrencyController, Currency?>(CurrencyController.new);

class CurrencyController extends Notifier<Currency?> {
  static const _key = 'app.currency';

  @override
  Currency? build() =>
      Currency.fromCode(ref.watch(sharedPrefsProvider).getString(_key));

  Future<void> set(Currency currency) async {
    state = currency;
    await ref.read(sharedPrefsProvider).setString(_key, currency.code);
  }
}

/// A reactive money formatter bound to the current [currencyControllerProvider].
///
/// UI money call sites read this instead of calling [formatMoney] directly, so
/// switching currency rebuilds every amount. Falls back to USD if unset (the
/// gate normally guarantees a choice before any money screen is reached).
final moneyFormatterProvider = Provider<String Function(num)>((ref) {
  final currency = ref.watch(currencyControllerProvider) ?? Currency.usd;
  return (v) => formatMoney(v, currency);
});
