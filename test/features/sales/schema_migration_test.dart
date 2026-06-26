import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/db/app_database.dart';
import '../../helpers/test_db.dart';

void main() {
  test('v2 tables exist and accept rows', () async {
    final db = newTestDb();
    final now = DateTime.utc(2026, 6, 26);
    await db.into(db.customers).insert(CustomersCompanion.insert(
          id: 'c1',
          organizationId: 'org1',
          name: 'Acme',
          createdAt: now,
          updatedAt: now,
        ));
    final c = await db.select(db.customers).getSingle();
    expect(c.name, 'Acme');
    expect(c.paymentTerms, 30); // default
    expect(c.isActive, isTrue);

    await db.into(db.documentCounters).insert(
        DocumentCountersCompanion.insert(
            organizationId: 'org1', entityType: 'sale_order'));
    final counter = await db.select(db.documentCounters).getSingle();
    expect(counter.nextSeq, 1);
    await db.close();
  });

  test('schemaVersion is 2', () {
    final db = newTestDb();
    expect(db.schemaVersion, 2);
    db.close();
  });
}
