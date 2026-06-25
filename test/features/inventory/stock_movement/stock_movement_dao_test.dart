import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/db/app_database.dart';
import 'package:inventoryhub_mobile/core/result/app_exception.dart';
import '../../../helpers/test_db.dart';

void main() {
  late AppDatabase db;
  final now = DateTime.utc(2026, 1, 1);

  setUp(() async {
    db = newTestDb();
    await db.into(db.products).insert(ProductsCompanion.insert(
          id: 'p1',
          organizationId: 'org1',
          name: 'Widget',
          unitId: 'pc',
          createdAt: now,
          updatedAt: now,
        ));
  });
  tearDown(() => db.close());

  StockMovementsCompanion mv(String id, double signed) =>
      StockMovementsCompanion.insert(
        id: id,
        organizationId: 'org1',
        productId: 'p1',
        movementType: 'adjustment',
        quantity: signed,
        createdBy: 'u1',
        createdAt: now,
      );

  test('current_stock always equals the sum of movements', () async {
    await db.stockMovementDao.record(mv('m1', 10), productId: 'p1', delta: 10);
    await db.stockMovementDao.record(mv('m2', -3), productId: 'p1', delta: -3);
    await db.stockMovementDao.record(mv('m3', 2), productId: 'p1', delta: 2);

    final product =
        await (db.select(db.products)..where((p) => p.id.equals('p1')))
            .getSingle();
    final movements = await db.stockMovementDao.forProduct('p1');
    final sum = movements.fold<double>(0, (a, m) => a + m.quantity);

    expect(product.currentStock, 9);
    expect(sum, 9);
  });

  test('record rolls back the inserted row when the product is missing',
      () async {
    await expectLater(
      db.stockMovementDao
          .record(mv('x', 5), productId: 'missing', delta: 5),
      throwsA(isA<NotFoundException>()),
    );
    expect(await db.select(db.stockMovements).get(), isEmpty);
  });

  test('forProduct returns newest first', () async {
    await db.into(db.stockMovements).insert(StockMovementsCompanion.insert(
          id: 'old', organizationId: 'org1', productId: 'p1',
          movementType: 'in', quantity: 1, createdBy: 'u1',
          createdAt: DateTime.utc(2026, 1, 1),
        ));
    await db.into(db.stockMovements).insert(StockMovementsCompanion.insert(
          id: 'new', organizationId: 'org1', productId: 'p1',
          movementType: 'in', quantity: 1, createdBy: 'u1',
          createdAt: DateTime.utc(2026, 2, 1),
        ));
    final rows = await db.stockMovementDao.forProduct('p1');
    expect(rows.first.id, 'new');
  });
}
