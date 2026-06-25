import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/core/result/app_exception.dart';
import 'package:inventoryhub_mobile/features/inventory/unit/data/unit_dao.dart';
import 'package:inventoryhub_mobile/features/inventory/unit/data/unit_repository_impl.dart';
import 'package:inventoryhub_mobile/features/inventory/unit/domain/unit_usecases.dart';
import '../../../helpers/test_db.dart';

void main() {
  late UnitService service;
  late dynamic db;

  setUp(() {
    db = newTestDb();
    service = UnitService(
      repository: UnitRepositoryImpl(UnitDao(db)),
      ids: const IdGenerator(),
      organizationId: 'org1',
    );
  });
  tearDown(() => db.close());

  test('convert scales by conversion factor within the same type', () async {
    final gram = await service.create(
        name: 'Gram', symbol: 'g', unitType: 'weight', isBase: true);
    final kg = await service.create(
        name: 'Kilogram',
        symbol: 'kg',
        unitType: 'weight',
        isBase: false,
        baseUnitId: gram.id,
        conversionFactor: 1000);
    expect(service.convert(2, kg, gram), 2000);
    expect(service.convert(500, gram, kg), 0.5);
  });

  test('convert rejects mismatched unit types', () async {
    final gram = await service.create(
        name: 'Gram', symbol: 'g', unitType: 'weight', isBase: true);
    // A 'count' unit derived from gram (reusing its timestamps) — cross-type.
    final piece =
        gram.copyWith(id: 'pc', name: 'Piece', symbol: 'pc', unitType: 'count');
    expect(() => service.convert(1, gram, piece),
        throwsA(isA<ValidationException>()));
  });

  test('derived unit without a base is rejected', () async {
    expect(
      () => service.create(
          name: 'Box', symbol: 'bx', unitType: 'count', isBase: false),
      throwsA(isA<ValidationException>()),
    );
  });
}
