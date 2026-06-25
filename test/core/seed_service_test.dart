import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/core/seed/seed_service.dart';
import '../helpers/test_db.dart';

void main() {
  test('ensureSeeded creates exactly one org and one user, idempotently',
      () async {
    final db = newTestDb();
    final seed = SeedService(db, const IdGenerator());

    final first = await seed.ensureSeeded();
    final second = await seed.ensureSeeded();

    expect(first.organizationId, second.organizationId);
    expect(first.userId, second.userId);
    expect(await db.select(db.organizations).get(), hasLength(1));
    expect(await db.select(db.users).get(), hasLength(1));
    await db.close();
  });
}
