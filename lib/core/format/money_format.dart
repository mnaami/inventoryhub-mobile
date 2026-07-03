import 'package:intl/intl.dart';

/// A currency the app can display money in.
///
/// [symbol] is the glyph shown next to amounts; [symbolLeads] controls whether
/// it precedes the amount (`$519,156`) or follows it (`519,156 دج`). [code] is
/// the stable string persisted in preferences.
enum Currency {
  usd(code: 'usd', symbol: r'$', symbolLeads: true),
  dzd(code: 'dzd', symbol: 'دج', symbolLeads: false);

  const Currency({
    required this.code,
    required this.symbol,
    required this.symbolLeads,
  });

  final String code;
  final String symbol;
  final bool symbolLeads;

  /// Parses a persisted [code] back into a [Currency], or `null` if unknown
  /// (including when nothing has been stored yet).
  static Currency? fromCode(String? code) => switch (code) {
        'usd' => usd,
        'dzd' => dzd,
        _ => null,
      };
}

final _moneyFormat = NumberFormat('#,##0.##', 'en');

/// Formats a money amount with thousands separators, dropping trailing zero
/// decimals, then attaches [currency]'s symbol on the correct side.
/// Examples: `formatMoney(519156, Currency.usd)` → '$519,156';
/// `formatMoney(519156.2, Currency.dzd)` → '519,156.2 دج'.
String formatMoney(num v, Currency currency) {
  final n = _moneyFormat.format(v);
  // U+00A0 non-breaking space keeps the amount and its symbol on one line.
  return currency.symbolLeads
      ? '${currency.symbol}$n'
      : '$n ${currency.symbol}';
}
