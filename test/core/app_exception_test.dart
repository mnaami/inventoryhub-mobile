import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/result/app_exception.dart';

void main() {
  test('exceptions carry a message and are AppExceptions', () {
    const e = ConflictException('duplicate');
    expect(e, isA<AppException>());
    expect(e.message, 'duplicate');
  });
}
