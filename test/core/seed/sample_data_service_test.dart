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

  group('foundation', () {
    test('load creates units, categories, and ~16 tagged products', () async {
      await service.load();
      final units = await (db.select(db.units)..where((u) => u.isSample.equals(true))).get();
      final cats = await (db.select(db.categories)..where((c) => c.isSample.equals(true))).get();
      final products = await (db.select(db.products)..where((p) => p.isSample.equals(true))).get();
      expect(units.length, greaterThanOrEqualTo(4));
      expect(cats.length, greaterThanOrEqualTo(5));
      expect(products.length, inInclusiveRange(15, 25));
      // No duplicate of the base 'pc' unit.
      final pcUnits = await (db.select(db.units)..where((u) => u.symbol.equals('pc'))).get();
      expect(pcUnits, hasLength(1));
    });
  });

  test('foundation marks at least one product below its reorder point is possible',
      () async {
    // Foundation alone sets current_stock = 0; minimums are > 0, so every
    // product is technically below reorder until purchasing adds stock.
    await service.load();
    final products = await (db.select(db.products)..where((p) => p.isSample.equals(true))).get();
    expect(products.every((p) => p.minimumStock > 0), isTrue);
  });
}
