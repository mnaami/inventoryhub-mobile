import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/db/app_database.dart';
import 'package:inventoryhub_mobile/features/production/production_order/data/production_order_dao.dart';
import 'package:inventoryhub_mobile/features/production/production_order/data/production_order_repository_impl.dart';
import 'package:inventoryhub_mobile/features/production/production_order/domain/production_order.dart';
import 'package:inventoryhub_mobile/features/production/production_order/domain/production_order_enums.dart';
import 'package:inventoryhub_mobile/features/production/recipe/data/production_recipe_dao.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/data/document_counter_dao.dart';
import '../../../helpers/test_db.dart';

void main() {
  late AppDatabase db;
  late ProductionOrderRepositoryImpl repo;
  final now = DateTime.utc(2026, 6, 27);

  ProductionOrder make(String id,
          {ProductionOrderStatus status = ProductionOrderStatus.planned}) =>
      ProductionOrder(
        id: id,
        organizationId: 'org1',
        orderNumber: 'PRD-0001',
        productId: 'cake',
        quantity: 5,
        status: status,
        createdAt: now,
        updatedAt: now,
      );

  setUp(() {
    db = newTestDb();
    repo = ProductionOrderRepositoryImpl(
        ProductionOrderDao(db), ProductionRecipeDao(db), DocumentCounterDao(db));
  });
  tearDown(() => db.close());

  test('nextNumber yields sequential PRD labels', () async {
    expect(await repo.nextNumber('org1', 'production_order', 'PRD'), 'PRD-0001');
    expect(await repo.nextNumber('org1', 'production_order', 'PRD'), 'PRD-0002');
  });

  test('create then load maps status enum', () async {
    await repo.createOrder(make('o1'));
    final loaded = await repo.getOrder('o1');
    expect(loaded!.status, ProductionOrderStatus.planned);
    expect(loaded.orderNumber, 'PRD-0001');
  });

  test('setStatus persists wire value', () async {
    await repo.createOrder(make('o1'));
    await repo.setStatus('o1', ProductionOrderStatus.cancelled);
    expect((await repo.getOrder('o1'))!.status, ProductionOrderStatus.cancelled);
  });

  test('domain getters', () {
    expect(make('o1').canComplete, isTrue);
    expect(make('o1', status: ProductionOrderStatus.inProgress).canComplete,
        isTrue);
    expect(make('o1', status: ProductionOrderStatus.completed).isTerminal,
        isTrue);
    expect(make('o1', status: ProductionOrderStatus.cancelled).isTerminal,
        isTrue);
  });
}
