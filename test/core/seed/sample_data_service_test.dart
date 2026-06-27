import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/db/app_database.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/core/seed/sample_data_service.dart';
import 'package:inventoryhub_mobile/core/seed/seed_service.dart';
import '../../helpers/test_db.dart';

Matcher moveCloseTo(double v) => closeTo(v, 0.0001);

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
  Future<String> seedTwoProducts() async {
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

  test('ensureSeeded still resolves the default unit after sample data adds '
      'base units (relaunch must not crash)', () async {
    // Sample data legitimately adds Meter/Liter/Kilogram as base units of their
    // own types. A subsequent app launch calls ensureSeeded again, which must
    // not throw "Too many elements" and must return the original default unit.
    await service.load();
    final again = await SeedService(db, const IdGenerator()).ensureSeeded();
    expect(again.defaultUnitId, session.defaultUnitId);
    expect(again.organizationId, session.organizationId);
  });

  test('isLoaded is false on a fresh seed, true once a sample row exists', () async {
    expect(await service.isLoaded(), isFalse);
    await seedTwoProducts();
    expect(await service.isLoaded(), isTrue);
  });

  test('remove deletes only is_sample rows, preserving user data', () async {
    final realId = await seedTwoProducts();
    await service.remove();
    final remaining = await db.select(db.products).get();
    expect(remaining.map((p) => p.id), [realId]);
  });

  test('remove preserves document counters and the org/unit', () async {
    await seedTwoProducts();
    await db.documentCounterDao.next(session.organizationId, 'sale_order', 'SO');
    await service.remove();
    final counters = await db.select(db.documentCounters).get();
    expect(counters, isNotEmpty);
    expect(await db.select(db.organizations).get(), hasLength(1));
    expect(await db.select(db.units).get(), isNotEmpty); // base 'pc' unit survives
  });

  test('summary counts tagged products/sales/purchases', () async {
    await seedTwoProducts();
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

  group('purchasing', () {
    test('receipts add stock IN through the ledger and reconcile', () async {
      await service.load();
      final products = await (db.select(db.products)..where((p) => p.isSample.equals(true))).get();
      // At least some products have positive stock from posted receipts.
      expect(products.where((p) => p.currentStock > 0), isNotEmpty);
      // current_stock equals the signed sum of that product's movements.
      for (final p in products) {
        final moves = await db.stockMovementDao.forProduct(p.id);
        final sum = moves.fold<double>(0, (a, m) => a + m.quantity);
        expect(p.currentStock, moveCloseTo(sum));
      }
    });

    test('purchase orders show a mix of payment statuses', () async {
      await service.load();
      final pos = await (db.select(db.purchaseOrders)..where((o) => o.isSample.equals(true))).get();
      final statuses = pos.map((o) => o.paymentStatus).toSet();
      expect(statuses.length, greaterThan(1)); // not all identical
      expect(pos.where((o) => o.status == 'draft'), isNotEmpty);
    });

    test('directly-built purchasing rows are tagged is_sample', () async {
      await service.load();
      // Stock movements are created INSIDE the receipt DAO and are tagged in
      // Task 6 (_tagInternalRows); they are NOT asserted here.
      final receipts = await db.select(db.purchaseOrderReceipts).get();
      expect(receipts.every((r) => r.isSample), isTrue);
      final items = await db.select(db.purchaseOrderItems).get();
      expect(items.every((i) => i.isSample), isTrue);
      final pays = await db.select(db.purchaseOrderPayments).get();
      expect(pays.every((p) => p.isSample), isTrue);
    });
  });

  group('sales', () {
    test('shipments post stock OUT and at least one product ends below reorder',
        () async {
      await service.load();
      final products = await (db.select(db.products)..where((p) => p.isSample.equals(true))).get();
      final outMoves = await (db.select(db.stockMovements)
            ..where((m) => m.movementType.equals('out')))
          .get();
      expect(outMoves, isNotEmpty);
      expect(products.any((p) => p.currentStock < p.minimumStock), isTrue);
      // Stock never goes negative.
      expect(products.every((p) => p.currentStock >= 0), isTrue);
    });

    test('sale orders show a mix of payment statuses incl. a draft', () async {
      await service.load();
      final sos = await (db.select(db.saleOrders)..where((o) => o.isSample.equals(true))).get();
      expect(sos.map((o) => o.paymentStatus).toSet().length, greaterThan(1));
      expect(sos.where((o) => o.status == 'draft'), isNotEmpty);
    });

    test('directly-built sales rows are tagged is_sample', () async {
      await service.load();
      // Shipment items + out stock movements are created INSIDE the shipping
      // DAO and are tagged in Task 6 (_tagInternalRows); not asserted here.
      final sos = await db.select(db.saleOrders).get();
      expect(sos, isNotEmpty);
      expect(sos.every((o) => o.isSample), isTrue);
      final items = await db.select(db.saleOrderItems).get();
      expect(items.every((i) => i.isSample), isTrue);
      final ships = await db.select(db.saleOrderShippings).get();
      expect(ships.every((s) => s.isSample), isTrue);
    });
  });

  group('end-to-end', () {
    test('rows created inside shipping/receipt DAOs are tagged is_sample', () async {
      await service.load();
      final moves = await db.select(db.stockMovements).get();
      expect(moves, isNotEmpty);
      expect(moves.every((m) => m.isSample), isTrue);
      final shipItems = await db.select(db.saleOrderShippingItems).get();
      expect(shipItems, isNotEmpty);
      expect(shipItems.every((i) => i.isSample), isTrue);
    });

    test('load then remove returns the DB to its pre-load state', () async {
      Future<int> totalRows() async {
        var n = 0;
        n += (await db.select(db.products).get()).length;
        n += (await db.select(db.categories).get()).length;
        n += (await db.select(db.units).get()).length;
        n += (await db.select(db.customers).get()).length;
        n += (await db.select(db.suppliers).get()).length;
        n += (await db.select(db.saleOrders).get()).length;
        n += (await db.select(db.saleOrderItems).get()).length;
        n += (await db.select(db.saleOrderPayments).get()).length;
        n += (await db.select(db.saleOrderShippings).get()).length;
        n += (await db.select(db.saleOrderShippingItems).get()).length;
        n += (await db.select(db.stockMovements).get()).length;
        n += (await db.select(db.purchaseOrders).get()).length;
        n += (await db.select(db.purchaseOrderItems).get()).length;
        n += (await db.select(db.purchaseOrderReceipts).get()).length;
        n += (await db.select(db.purchaseOrderReceiptItems).get()).length;
        n += (await db.select(db.purchaseOrderPayments).get()).length;
        return n;
      }

      final before = await totalRows();
      await service.load();
      expect(await totalRows(), greaterThan(before));
      await service.remove();
      expect(await totalRows(), before); // base 'pc' unit only
    });

    test('remove keeps a user-created product entered alongside the sample data',
        () async {
      await service.load();
      final now = DateTime.utc(2026, 2, 1);
      await db.into(db.products).insert(ProductsCompanion.insert(
            id: 'mine', organizationId: session.organizationId,
            name: 'My Hand-Entered Item', unitId: session.defaultUnitId,
            createdAt: now, updatedAt: now,
          ));
      await service.remove();
      final left = await db.select(db.products).get();
      expect(left.map((p) => p.id), ['mine']);
    });

    test('load is idempotent across load -> remove -> load', () async {
      await service.load();
      final firstCount =
          (await (db.select(db.products)..where((p) => p.isSample.equals(true))).get()).length;
      await service.remove();
      await service.load();
      final secondCount =
          (await (db.select(db.products)..where((p) => p.isSample.equals(true))).get()).length;
      expect(secondCount, firstCount);
    });
  });
}
