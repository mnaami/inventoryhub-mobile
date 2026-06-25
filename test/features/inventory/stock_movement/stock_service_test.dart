import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/db/app_database.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/core/result/app_exception.dart';
import 'package:inventoryhub_mobile/features/inventory/stock_movement/data/stock_movement_dao.dart';
import 'package:inventoryhub_mobile/features/inventory/stock_movement/data/stock_movement_repository_impl.dart';
import 'package:inventoryhub_mobile/features/inventory/stock_movement/domain/stock_movement.dart';
import 'package:inventoryhub_mobile/features/inventory/stock_movement/domain/stock_movement_usecases.dart';
import '../../../helpers/test_db.dart';

void main() {
  late AppDatabase db;
  late StockService service;
  final now = DateTime.utc(2026, 1, 1);

  setUp(() async {
    db = newTestDb();
    await db.into(db.products).insert(ProductsCompanion.insert(
          id: 'p1', organizationId: 'org1', name: 'Widget', unitId: 'pc',
          createdAt: now, updatedAt: now,
        ));
    service = StockService(
      repository: StockMovementRepositoryImpl(StockMovementDao(db)),
      ids: const IdGenerator(),
      organizationId: 'org1',
      userId: 'u1',
    );
  });
  tearDown(() => db.close());

  test('inbound adds, outbound subtracts', () async {
    expect(await service.record(
        productId: 'p1', type: MovementType.inbound, quantity: 10), 10);
    expect(await service.record(
        productId: 'p1', type: MovementType.outbound, quantity: 4), 6);
  });

  test('adjustment applies the signed quantity', () async {
    await service.record(
        productId: 'p1', type: MovementType.inbound, quantity: 5);
    expect(await service.record(
        productId: 'p1', type: MovementType.adjustment, quantity: -2), 3);
  });

  test('zero quantity is rejected', () async {
    expect(
      () => service.record(
          productId: 'p1', type: MovementType.inbound, quantity: 0),
      throwsA(isA<ValidationException>()),
    );
  });

  test('history returns newest first', () async {
    await service.record(
        productId: 'p1', type: MovementType.inbound, quantity: 10);
    await service.record(
        productId: 'p1', type: MovementType.outbound, quantity: 4);
    final hist = await service.history('p1');
    expect(hist.first.quantity, -4);
  });
}
