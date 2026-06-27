import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/db/app_database.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/core/seed/sample_data_service.dart';
import 'package:inventoryhub_mobile/core/seed/seed_service.dart';
import '../../helpers/test_db.dart';

void main() {
  late AppDatabase db;
  late SampleDataService service;
  late SeededContext session;
  final now = DateTime.utc(2026, 1, 1);

  setUp(() async {
    db = newTestDb();
    session = await SeedService(db, const IdGenerator()).ensureSeeded();
    service = SampleDataService(db, const IdGenerator(), session);
  });
  tearDown(() => db.close());

  // Inserts one tagged + one untagged product; returns the untagged id.
  Future<String> _seedTwoProducts() async {
    await db.into(db.products).insert(ProductsCompanion.insert(
          id: 'sample-p', organizationId: session.organizationId, name: 'Demo Drill',
          unitId: session.defaultUnitId, isSample: const Value(true),
          createdAt: now, updatedAt: now,
        ));
    await db.into(db.products).insert(ProductsCompanion.insert(
          id: 'real-p', organizationId: session.organizationId, name: 'My Real Product',
          unitId: session.defaultUnitId, createdAt: now, updatedAt: now,
        ));
    return 'real-p';
  }

  test('isLoaded is false on a fresh seed, true once a sample row exists', () async {
    expect(await service.isLoaded(), isFalse);
    await _seedTwoProducts();
    expect(await service.isLoaded(), isTrue);
  });

  test('remove deletes only is_sample rows, preserving user data', () async {
    final realId = await _seedTwoProducts();
    await service.remove();
    final remaining = await db.select(db.products).get();
    expect(remaining.map((p) => p.id), [realId]);
  });

  test('remove preserves document counters and the org/unit', () async {
    await _seedTwoProducts();
    await db.documentCounterDao.next(session.organizationId, 'sale_order', 'SO');
    await service.remove();
    final counters = await db.select(db.documentCounters).get();
    expect(counters, isNotEmpty);
    expect(await db.select(db.organizations).get(), hasLength(1));
    expect(await db.select(db.units).get(), isNotEmpty); // base 'pc' unit survives
  });

  test('summary counts tagged products/sales/purchases', () async {
    await _seedTwoProducts();
    final s = await service.summary();
    expect(s.products, 1);
    expect(s.sales, 0);
    expect(s.purchases, 0);
    expect(s.isLoaded, isTrue);
  });
}
