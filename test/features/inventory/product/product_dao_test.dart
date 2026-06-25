import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/db/app_database.dart';
import '../../../helpers/test_db.dart';

void main() {
  late AppDatabase db;
  final now = DateTime.utc(2026, 1, 1);
  setUp(() => db = newTestDb());
  tearDown(() => db.close());

  ProductsCompanion p(
    String id,
    String name, {
    String? barcode,
    String? categoryId,
    double stock = 0,
    double min = 0,
  }) =>
      ProductsCompanion.insert(
        id: id,
        organizationId: 'org1',
        name: name,
        unitId: 'pc',
        barcode: Value(barcode),
        categoryId: Value(categoryId),
        currentStock: Value(stock),
        minimumStock: Value(min),
        createdAt: now,
        updatedAt: now,
      );

  test('paged returns active rows sorted by name', () async {
    await db.productDao.insertRow(p('b', 'Banana'));
    await db.productDao.insertRow(p('a', 'Apple'));
    final rows = await db.productDao.paged('org1', limit: 20, offset: 0);
    expect(rows.map((r) => r.name), ['Apple', 'Banana']);
  });

  test('search matches name or barcode', () async {
    await db.productDao.insertRow(p('a', 'Apple', barcode: '111'));
    await db.productDao.insertRow(p('b', 'Banana', barcode: '222'));
    expect((await db.productDao.search('org1', 'ppl')).map((r) => r.id), ['a']);
    expect((await db.productDao.search('org1', '222')).map((r) => r.id), ['b']);
  });

  test('byBarcode finds an exact match', () async {
    await db.productDao.insertRow(p('a', 'Apple', barcode: '111'));
    expect((await db.productDao.byBarcode('org1', '111'))!.id, 'a');
    expect(await db.productDao.byBarcode('org1', '999'), isNull);
  });

  test('lowStock and outOfStock partition by thresholds', () async {
    await db.productDao.insertRow(p('low', 'Low', stock: 2, min: 5));
    await db.productDao.insertRow(p('ok', 'Ok', stock: 10, min: 5));
    await db.productDao.insertRow(p('zero', 'Zero', stock: 0, min: 0));
    expect((await db.productDao.lowStock('org1')).map((r) => r.id), ['low']);
    expect((await db.productDao.outOfStock('org1')).map((r) => r.id), ['zero']);
  });

  test('countActiveByCategory counts only that category', () async {
    await db.productDao.insertRow(p('a', 'Apple', categoryId: 'cat1'));
    await db.productDao.insertRow(p('b', 'Banana', categoryId: 'cat1'));
    await db.productDao.insertRow(p('c', 'Cherry', categoryId: 'cat2'));
    expect(await db.productDao.countActiveByCategory('org1', 'cat1'), 2);
  });
}
