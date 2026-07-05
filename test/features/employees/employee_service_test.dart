import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/db/app_database.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/core/result/app_exception.dart';
import 'package:inventoryhub_mobile/features/employees/employee/data/employee_dao.dart';
import 'package:inventoryhub_mobile/features/employees/employee/data/employee_repository_impl.dart';
import 'package:inventoryhub_mobile/features/employees/employee/domain/employee_service.dart';
import '../../helpers/test_db.dart';

void main() {
  late AppDatabase db;
  late EmployeeService service;

  setUp(() {
    db = newTestDb();
    service = EmployeeService(
      repository: EmployeeRepositoryImpl(EmployeeDao(db)),
      ids: const IdGenerator(),
      organizationId: 'org1',
    );
  });
  tearDown(() => db.close());

  test('create trims name and rejects blank', () async {
    final e = await service.create(name: '  Sara ');
    expect(e.name, 'Sara');
    expect(e.isActive, true);
    expect(await service.get(e.id), isNotNull);
    expect(() => service.create(name: '   '), throwsA(isA<ValidationException>()));
  });

  test('setActive hides from activeOnly list', () async {
    final e = await service.create(name: 'Ali');
    await service.setActive(e.id, false);
    expect((await service.list(activeOnly: true)).where((x) => x.id == e.id), isEmpty);
    expect((await service.list()).where((x) => x.id == e.id), isNotEmpty);
  });
}
