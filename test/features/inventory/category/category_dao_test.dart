import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/db/app_database.dart';
import '../../../helpers/test_db.dart';

void main() {
  late AppDatabase db;
  final now = DateTime.utc(2026, 1, 1);

  setUp(() => db = newTestDb());
  tearDown(() => db.close());

  CategoriesCompanion row(String id, String name, {String? parent}) =>
      CategoriesCompanion.insert(
        id: id,
        organizationId: 'org1',
        name: name,
        parentCategoryId: Value(parent),
        createdAt: now,
        updatedAt: now,
      );

  test('activeForOrg returns active rows sorted by name', () async {
    await db.categoryDao.insertRow(row('c2', 'Beverages'));
    await db.categoryDao.insertRow(row('c1', 'Apparel'));
    final rows = await db.categoryDao.activeForOrg('org1');
    expect(rows.map((r) => r.name), ['Apparel', 'Beverages']);
  });

  test('softDelete hides the row from activeForOrg', () async {
    await db.categoryDao.insertRow(row('c1', 'Apparel'));
    await db.categoryDao.softDelete('c1', now);
    expect(await db.categoryDao.activeForOrg('org1'), isEmpty);
  });

  test('childrenOf returns direct children only', () async {
    await db.categoryDao.insertRow(row('root', 'Food'));
    await db.categoryDao.insertRow(row('child', 'Snacks', parent: 'root'));
    final kids = await db.categoryDao.childrenOf('root');
    expect(kids.single.id, 'child');
  });

  test('duplicate (org, name) throws', () async {
    await db.categoryDao.insertRow(row('c1', 'Apparel'));
    expect(
      () => db.categoryDao.insertRow(row('c2', 'Apparel')),
      throwsA(isA<Exception>()),
    );
  });
}
