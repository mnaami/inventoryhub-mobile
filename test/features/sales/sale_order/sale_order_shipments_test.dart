import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/db/app_database.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/core/result/app_exception.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/data/document_counter_dao.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/data/sale_order_dao.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/data/sale_order_payment_dao.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/data/sale_order_repository_impl.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/data/sale_order_shipping_dao.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/domain/sale_order_enums.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/domain/sale_order_usecases.dart';
import '../../../helpers/test_db.dart';

void main() {
  late AppDatabase db;
  late SaleOrderService service;
  final now = DateTime.utc(2026, 6, 26);

  setUp(() async {
    db = newTestDb();
    service = SaleOrderService(
      repository: SaleOrderRepositoryImpl(SaleOrderDao(db),
          SaleOrderPaymentDao(db), SaleOrderShippingDao(db),
          DocumentCounterDao(db)),
      ids: const IdGenerator(),
      organizationId: 'org1',
      userId: 'u1',
    );
    await db.into(db.products).insert(ProductsCompanion.insert(
          id: 'p1', organizationId: 'org1', name: 'Widget', unitId: 'pc',
          currentStock: const Value(10), createdAt: now, updatedAt: now,
        ));
  });
  tearDown(() => db.close());

  Future<dynamic> processingOrder() async {
    final o = await service.createDraft(customerId: 'c1', lines: [
      NewLine(productId: 'p1', productName: 'Widget', quantity: 6, unitPrice: 1),
    ]);
    await service.confirm(o);
    await service.process((await service.get(o.id))!);
    return (await service.get(o.id))!;
  }

  test('createShipment issues stock and assigns a SHP number', () async {
    final o = await processingOrder();
    final item = (await service.items(o.id)).single;
    await service.createShipment(o, lines: [ShipLine(item: item, quantity: 4)]);
    final shipments = await service.shipments(o.id);
    expect(shipments.single.soShippingNumber, 'SHP-0001');
    final p = await (db.select(db.products)..where((x) => x.id.equals('p1'))).getSingle();
    expect(p.currentStock, 6); // 10 - 4
  });

  test('shipping more than the remaining line qty is rejected', () async {
    final o = await processingOrder();
    final item = (await service.items(o.id)).single; // ordered 6
    await expectLater(
      service.createShipment(o, lines: [ShipLine(item: item, quantity: 7)]),
      throwsA(isA<ValidationException>()),
    );
  });

  test('cannot ship a draft order', () async {
    final o = await service.createDraft(customerId: 'c1', lines: [
      NewLine(productId: 'p1', productName: 'Widget', quantity: 1, unitPrice: 1),
    ]);
    final item = (await service.items(o.id)).single;
    await expectLater(
      service.createShipment(o, lines: [ShipLine(item: item, quantity: 1)]),
      throwsA(isA<ValidationException>()),
    );
  });
}
