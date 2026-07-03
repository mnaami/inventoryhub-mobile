import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/format/money_format.dart';

void main() {
  // Amount and symbol are joined by a U+00A0 non-breaking space for DZD.
  const nbsp = ' ';

  group('USD (leading \$ symbol)', () {
    test('formats with thousands separators, dropping trailing zero decimals',
        () {
      expect(formatMoney(519156, Currency.usd), '\$519,156');
      expect(formatMoney(519156.00, Currency.usd), '\$519,156');
      expect(formatMoney(519156.20, Currency.usd), '\$519,156.2');
      expect(formatMoney(519156.25, Currency.usd), '\$519,156.25');
      expect(formatMoney(0, Currency.usd), '\$0');
      expect(formatMoney(1000000, Currency.usd), '\$1,000,000');
    });
  });

  group('DZD (trailing دج symbol)', () {
    test('formats amount then appends the دج symbol', () {
      expect(formatMoney(519156, Currency.dzd), '519,156${nbsp}دج');
      expect(formatMoney(519156.20, Currency.dzd), '519,156.2${nbsp}دج');
      expect(formatMoney(0, Currency.dzd), '0${nbsp}دج');
      expect(formatMoney(1000000, Currency.dzd), '1,000,000${nbsp}دج');
    });
  });

  group('Currency.fromCode', () {
    test('parses known codes and rejects unknown/null', () {
      expect(Currency.fromCode('usd'), Currency.usd);
      expect(Currency.fromCode('dzd'), Currency.dzd);
      expect(Currency.fromCode('eur'), isNull);
      expect(Currency.fromCode(null), isNull);
    });
  });
}
