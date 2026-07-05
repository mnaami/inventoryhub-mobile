import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/db/app_database.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/features/employees/rate/data/production_pay_rate_dao.dart';
import 'package:inventoryhub_mobile/features/employees/rate/domain/production_pay_rate_service.dart';
import '../../helpers/test_db.dart';

void main() {
  late AppDatabase db;
  late ProductionPayRateDao dao;
  late ProductionPayRateService service;
  const orgId = 'org1';

  setUp(() {
    db = newTestDb();
    dao = ProductionPayRateDao(db);
    service = ProductionPayRateService(
      dao: dao,
      ids: const IdGenerator(),
      organizationId: orgId,
    );
  });
  tearDown(() => db.close());

  test('resolveRate: override beats default beats zero', () async {
    // no rate at all -> 0
    expect(await service.resolveRate(employeeId: 'E1', productId: 'P1'), 0.0);
    // product default
    await service.setDefaultRate('P1', 5.0);
    expect(await service.resolveRate(employeeId: 'E1', productId: 'P1'), 5.0);
    // employee override wins
    await service.setOverride(employeeId: 'E1', productId: 'P1', rate: 8.0);
    expect(await service.resolveRate(employeeId: 'E1', productId: 'P1'), 8.0);
    // a different employee still gets the default
    expect(await service.resolveRate(employeeId: 'E2', productId: 'P1'), 5.0);
  });

  test('setDefaultRate updates existing default in place (no duplicate rows)', () async {
    await service.setDefaultRate('P1', 5.0);
    await service.setDefaultRate('P1', 6.0);
    final defaults = await dao.defaultsForOrg(orgId);
    expect(defaults.where((r) => r.productId == 'P1').length, 1);
    expect(await service.resolveRate(employeeId: 'E9', productId: 'P1'), 6.0);
  });
}
