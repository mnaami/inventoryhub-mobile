import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/db/app_database.dart';
import '../../../helpers/test_db.dart';

void main() {
  late AppDatabase db;
  final now = DateTime.utc(2026, 1, 1);
  setUp(() => db = newTestDb());
  tearDown(() => db.close());

  UnitsCompanion u(String id, String name, String symbol, String type,
          {bool base = false}) =>
      UnitsCompanion.insert(
        id: id,
        organizationId: 'org1',
        name: name,
        symbol: symbol,
        unitType: type,
        isBaseUnit: Value(base),
        createdAt: now,
        updatedAt: now,
      );

  test('byType filters by unit type', () async {
    await db.unitDao.insertRow(u('g', 'Gram', 'g', 'weight', base: true));
    await db.unitDao.insertRow(u('pc', 'Piece', 'pc', 'count', base: true));
    final weight = await db.unitDao.byType('org1', 'weight');
    expect(weight.map((r) => r.id), ['g']);
  });

  test('baseUnits returns only base units', () async {
    await db.unitDao.insertRow(u('g', 'Gram', 'g', 'weight', base: true));
    await db.unitDao.insertRow(u('kg', 'Kilogram', 'kg', 'weight'));
    final bases = await db.unitDao.baseUnits('org1');
    expect(bases.map((r) => r.id), ['g']);
  });

  test('duplicate symbol within org throws', () async {
    await db.unitDao.insertRow(u('g', 'Gram', 'g', 'weight', base: true));
    await expectLater(db.unitDao.insertRow(u('g2', 'Grams', 'g', 'weight')),
        throwsA(isA<Exception>()));
  });
}
