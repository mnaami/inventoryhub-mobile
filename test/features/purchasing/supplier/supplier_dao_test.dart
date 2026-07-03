import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/db/app_database.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/features/purchasing/supplier/data/supplier_dao.dart';
import 'package:inventoryhub_mobile/features/purchasing/supplier/data/supplier_repository_impl.dart';
import 'package:inventoryhub_mobile/features/purchasing/supplier/domain/supplier.dart';
import '../../../helpers/test_db.dart';

void main() {
  late SupplierRepositoryImpl repo;
  late AppDatabase db;
  final now = DateTime.utc(2026, 6, 26);
  final ids = const IdGenerator();

  Supplier make(String name, {String? email}) => Supplier(
        id: ids.newId(),
        organizationId: 'org1',
        name: name,
        contactPerson: 'Jane',
        email: email,
        phones: const ['111', '222'],
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

  setUp(() {
    db = newTestDb();
    repo = SupplierRepositoryImpl(SupplierDao(db));
  });
  tearDown(() => db.close());

  test('create round-trips including phones JSON and contact person', () async {
    final s = await repo.create(make('Acme', email: 'a@x.com'));
    final loaded = await repo.getById(s.id);
    expect(loaded!.name, 'Acme');
    expect(loaded.contactPerson, 'Jane');
    expect(loaded.phones, ['111', '222']);
    expect(loaded.paymentTerms, 30);
  });

  test('search matches name or email; soft-deleted excluded', () async {
    final a = await repo.create(make('Acme', email: 'a@x.com'));
    await repo.create(make('Globex', email: 'g@x.com'));
    expect((await repo.search('org1', 'glob')).single.name, 'Globex');
    expect((await repo.search('org1', 'a@x')).single.name, 'Acme');
    await repo.softDelete(a.id);
    expect((await repo.listActive('org1')).map((s) => s.name), ['Globex']);
  });

  test('listSuppliers paginates and filters correctly', () async {
    final s1 = await repo.create(make('Acme', email: 'a@x.com'));
    final s2 = await repo.create(make('Globex', email: 'g@x.com'));
    final s3 = await repo.create(make('Initech', email: 'i@x.com'));

    // Test pagination (limit/offset)
    final p1 = await repo.listSuppliers('org1', limit: 2, offset: 0);
    expect(p1.length, 2);
    expect(p1.map((s) => s.name), ['Acme', 'Globex']); // sorted alphabetically

    final p2 = await repo.listSuppliers('org1', limit: 2, offset: 2);
    expect(p2.length, 1);
    expect(p2.map((s) => s.name), ['Initech']);

    // Test search filtering
    final pSearch = await repo.listSuppliers('org1', search: 'glob', limit: 5, offset: 0);
    expect(pSearch.length, 1);
    expect(pSearch.first.name, 'Globex');
  });
}
