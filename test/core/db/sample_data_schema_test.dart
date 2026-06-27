import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/db/app_database.dart';
import '../../helpers/test_db.dart';

void main() {
  test('schemaVersion is 5', () {
    final db = AppDatabase.forTesting();
    addTearDown(db.close);
    expect(db.schemaVersion, 5);
  });

  test('is_sample defaults to false on newly created tables', () async {
    final db = newTestDb();
    addTearDown(db.close);
    final now = DateTime.utc(2026, 1, 1);
    await db.into(db.categories).insert(CategoriesCompanion.insert(
          id: 'c1', organizationId: 'org1', name: 'Cat', createdAt: now, updatedAt: now,
        ));
    final row = await (db.select(db.categories)..where((c) => c.id.equals('c1')))
        .getSingle();
    expect(row.isSample, isFalse);
  });
}
