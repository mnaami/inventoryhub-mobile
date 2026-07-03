import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/features/sales/customer/data/customer_dao.dart';
import 'package:inventoryhub_mobile/features/sales/customer/data/customer_repository_impl.dart';
import 'package:inventoryhub_mobile/features/sales/customer/domain/customer.dart';
import '../../../helpers/test_db.dart';

void main() {
  late CustomerRepositoryImpl repo;
  late dynamic db;
  final now = DateTime.utc(2026, 6, 26);
  final ids = const IdGenerator();

  Customer make(String name, {String? email}) => Customer(
        id: ids.newId(),
        organizationId: 'org1',
        name: name,
        email: email,
        phones: const ['111', '222'],
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

  setUp(() {
    db = newTestDb();
    repo = CustomerRepositoryImpl(CustomerDao(db));
  });
  tearDown(() => db.close());

  test('create round-trips including phones JSON', () async {
    final c = await repo.create(make('Acme', email: 'a@x.com'));
    final loaded = await repo.getById(c.id);
    expect(loaded!.name, 'Acme');
    expect(loaded.phones, ['111', '222']);
    expect(loaded.paymentTerms, 30);
  });

  test('search matches name or email; soft-deleted excluded', () async {
    final a = await repo.create(make('Acme', email: 'a@x.com'));
    await repo.create(make('Globex', email: 'g@x.com'));
    expect((await repo.search('org1', 'glob')).single.name, 'Globex');
    expect((await repo.search('org1', 'a@x')).single.name, 'Acme');
    await repo.softDelete(a.id);
    expect((await repo.listActive('org1')).map((c) => c.name), ['Globex']);
  });

  test('paged supports limit, offset, and search', () async {
    final a = await repo.create(make('Acme', email: 'a@x.com'));
    final b = await repo.create(make('Globex', email: 'g@x.com'));
    final c = await repo.create(make('Initech', email: 'i@x.com'));

    // Test search filter
    final searchResult = await repo.listActivePaged('org1', search: 'glob', limit: 10, offset: 0);
    expect(searchResult.map((x) => x.name), ['Globex']);

    // Test ordering & pagination limit/offset (alphabetical order)
    final page1 = await repo.listActivePaged('org1', limit: 2, offset: 0);
    expect(page1.map((x) => x.name), ['Acme', 'Globex']);

    final page2 = await repo.listActivePaged('org1', limit: 2, offset: 2);
    expect(page2.map((x) => x.name), ['Initech']);
  });
}
