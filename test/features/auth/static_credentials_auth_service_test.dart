import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/features/auth/data/static_credentials_auth_service.dart';

void main() {
  const service = StaticCredentialsAuthService();

  test('accepts admin/admin', () async {
    expect(await service.signIn('admin', 'admin'), isTrue);
  });

  test('rejects wrong password', () async {
    expect(await service.signIn('admin', 'nope'), isFalse);
  });

  test('rejects wrong username', () async {
    expect(await service.signIn('root', 'admin'), isFalse);
  });

  test('rejects empty credentials', () async {
    expect(await service.signIn('', ''), isFalse);
  });

  test('is case-sensitive', () async {
    expect(await service.signIn('Admin', 'admin'), isFalse);
  });
}
