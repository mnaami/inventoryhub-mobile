import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/core/result/app_exception.dart';
import 'package:inventoryhub_mobile/features/sales/customer/data/customer_dao.dart';
import 'package:inventoryhub_mobile/features/sales/customer/data/customer_repository_impl.dart';
import 'package:inventoryhub_mobile/features/sales/customer/domain/customer_usecases.dart';
import '../../../helpers/test_db.dart';

void main() {
  late dynamic db;
  CustomerService service({Future<int> Function(String)? liveOrders}) =>
      CustomerService(
        repository: CustomerRepositoryImpl(CustomerDao(db)),
        ids: const IdGenerator(),
        organizationId: 'org1',
        liveOrdersForCustomer: liveOrders,
      );

  setUp(() => db = newTestDb());
  tearDown(() => db.close());

  test('create trims name and stores the customer', () async {
    final c = await service().create(name: '  Acme  ', paymentTerms: 45);
    expect(c.name, 'Acme');
    expect(c.paymentTerms, 45);
    expect((await service().get(c.id))!.name, 'Acme');
  });

  test('create rejects a blank name', () async {
    expect(() => service().create(name: '   '),
        throwsA(isA<ValidationException>()));
  });

  test('delete is blocked when the customer has live orders', () async {
    final c = await service().create(name: 'Acme');
    await expectLater(
      service(liveOrders: (_) async => 2).delete(c.id),
      throwsA(isA<ConflictException>()),
    );
    expect((await service().get(c.id))!.isActive, isTrue);
  });

  test('delete soft-deletes when there are no live orders', () async {
    final c = await service().create(name: 'Acme');
    await service(liveOrders: (_) async => 0).delete(c.id);
    expect(await service().get(c.id), isNull);
  });
}
