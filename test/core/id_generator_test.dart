import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';

void main() {
  test('newId returns a unique 36-char uuid each call', () {
    final gen = IdGenerator();
    final a = gen.newId();
    final b = gen.newId();
    expect(a, isNot(equals(b)));
    expect(a.length, 36);
  });
}
