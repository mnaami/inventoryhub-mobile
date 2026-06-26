import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/db/app_database.dart';
import '../../helpers/test_db.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = newTestDb());
  tearDown(() => db.close());

  test('sequence increments with no gaps and zero-pads', () async {
    final a = await db.documentCounterDao.next('org1', 'sale_order', 'SO');
    final b = await db.documentCounterDao.next('org1', 'sale_order', 'SO');
    final c = await db.documentCounterDao.next('org1', 'sale_order', 'SO');
    expect([a, b, c], ['SO-0001', 'SO-0002', 'SO-0003']);
  });

  test('sequences are independent per entity type and per org', () async {
    expect(await db.documentCounterDao.next('org1', 'sale_order', 'SO'), 'SO-0001');
    expect(await db.documentCounterDao.next('org1', 'so_payment', 'PAY'), 'PAY-0001');
    expect(await db.documentCounterDao.next('org2', 'sale_order', 'SO'), 'SO-0001');
    expect(await db.documentCounterDao.next('org1', 'sale_order', 'SO'), 'SO-0002');
  });
}
