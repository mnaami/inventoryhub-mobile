import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/db/app_database.dart';
import 'package:inventoryhub_mobile/features/production/production_order/data/production_order_dao.dart';
import '../../../helpers/test_db.dart';

void main() {
  late AppDatabase db;
  late ProductionOrderDao dao;
  final now = DateTime.utc(2026, 6, 27);

  ProductionOrdersCompanion order(String id, {String status = 'planned'}) =>
      ProductionOrdersCompanion.insert(
        id: id,
        organizationId: 'org1',
        orderNumber: 'PRD-000$id',
        productId: 'p1',
        quantity: 5,
        status: Value(status),
        createdAt: now,
        updatedAt: now,
      );

  setUp(() {
    db = newTestDb();
    dao = db.productionOrderDao;
  });
  tearDown(() => db.close());

  test('createRow then byId round-trips', () async {
    await dao.createRow(order('1'));
    expect((await dao.byId('1'))!.orderNumber, 'PRD-0001');
  });

  test('start sets in_progress and start_date', () async {
    await dao.createRow(order('1'));
    await dao.start('1', now);
    final o = (await dao.byId('1'))!;
    expect(o.status, 'in_progress');
    expect(o.startDate!.millisecondsSinceEpoch, now.millisecondsSinceEpoch);
  });

  test('cancel sets cancelled', () async {
    await dao.createRow(order('1'));
    await dao.cancel('1', now);
    expect((await dao.byId('1'))!.status, 'cancelled');
  });

  test('paged filters by status', () async {
    await dao.createRow(order('1'));
    await dao.createRow(order('2', status: 'completed'));
    final planned =
        await dao.paged('org1', status: 'planned', limit: 20, offset: 0);
    expect(planned.map((o) => o.id), ['1']);
  });

  test('paged filters by search query', () async {
    await dao.createRow(order('1'));
    await dao.createRow(order('2', status: 'completed'));
    final results = await dao.paged('org1', search: '0002', limit: 20, offset: 0);
    expect(results.map((o) => o.id), ['2']);
  });

  test('countByStatuses counts matching orders', () async {
    await dao.createRow(order('1'));
    await dao.createRow(order('2'));
    await dao.createRow(order('3', status: 'completed'));
    expect(await dao.countByStatuses('org1', ['planned']), 2);
    expect(await dao.countByStatuses('org1', ['completed']), 1);
  });
}
