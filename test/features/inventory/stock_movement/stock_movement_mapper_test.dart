import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/db/app_database.dart';
import 'package:inventoryhub_mobile/features/inventory/stock_movement/data/stock_movement_mapper.dart';
import 'package:inventoryhub_mobile/features/inventory/stock_movement/domain/stock_movement.dart';
import '../../../helpers/test_db.dart';

void main() {
  late AppDatabase db;
  final now = DateTime.utc(2026, 6, 26);

  setUp(() => db = newTestDb());
  tearDown(() => db.close());

  test('mapper preserves referenceType/referenceId round-trip', () async {
    final m = StockMovement(
      id: 'm1', organizationId: 'org1', productId: 'p1',
      type: MovementType.inbound, quantity: 3,
      referenceType: 'purchase_order_receipt', referenceId: 'rcp1',
      createdBy: 'u1', createdAt: now,
    );
    await db.into(db.stockMovements).insert(toCompanion(m));
    final row = await (db.select(db.stockMovements)
          ..where((x) => x.id.equals('m1')))
        .getSingle();
    final back = toStockMovement(row);
    expect(back.referenceType, 'purchase_order_receipt');
    expect(back.referenceId, 'rcp1');
    expect(back.type, MovementType.inbound);
  });

  test('mapper tolerates a null reference (manual adjustment)', () async {
    final m = StockMovement(
      id: 'm2', organizationId: 'org1', productId: 'p1',
      type: MovementType.adjustment, quantity: -1,
      createdBy: 'u1', createdAt: now,
    );
    await db.into(db.stockMovements).insert(toCompanion(m));
    final row = await (db.select(db.stockMovements)
          ..where((x) => x.id.equals('m2')))
        .getSingle();
    final back = toStockMovement(row);
    expect(back.referenceType, null);
    expect(back.referenceId, null);
  });
}
