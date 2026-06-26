import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/db/app_database.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/core/result/app_exception.dart';
import 'package:inventoryhub_mobile/features/purchasing/supplier/data/supplier_dao.dart';
import 'package:inventoryhub_mobile/features/purchasing/supplier/data/supplier_repository_impl.dart';
import 'package:inventoryhub_mobile/features/purchasing/supplier/domain/supplier_usecases.dart';
import '../../../helpers/test_db.dart';

void main() {
  late AppDatabase db;
  SupplierService service({Future<int> Function(String)? livePos}) =>
      SupplierService(
        repository: SupplierRepositoryImpl(SupplierDao(db)),
        ids: const IdGenerator(),
        organizationId: 'org1',
        livePosForSupplier: livePos,
      );

  setUp(() => db = newTestDb());
  tearDown(() => db.close());

  test('create trims name and stores the supplier', () async {
    final s = await service().create(name: '  Acme  ', paymentTerms: 45);
    expect(s.name, 'Acme');
    expect(s.paymentTerms, 45);
    expect((await service().get(s.id))!.name, 'Acme');
  });

  test('create rejects a blank name', () async {
    expect(() => service().create(name: '   '),
        throwsA(isA<ValidationException>()));
  });

  test('delete is blocked when the supplier has live POs', () async {
    final s = await service().create(name: 'Acme');
    await expectLater(
      service(livePos: (_) async => 2).delete(s.id),
      throwsA(isA<ConflictException>()),
    );
    expect((await service().get(s.id))!.isActive, isTrue);
  });

  test('delete soft-deletes when there are no live POs', () async {
    final s = await service().create(name: 'Acme');
    await service(livePos: (_) async => 0).delete(s.id);
    expect(await service().get(s.id), isNull);
  });
}
