import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/format/money_format.dart';

void main() {
  test('formats with thousands separators, dropping trailing zero decimals',
      () {
    expect(formatMoney(519156), '\$519,156');
    expect(formatMoney(519156.00), '\$519,156');
    expect(formatMoney(519156.20), '\$519,156.2');
    expect(formatMoney(519156.25), '\$519,156.25');
    expect(formatMoney(0), '\$0');
    expect(formatMoney(1000000), '\$1,000,000');
  });
}
