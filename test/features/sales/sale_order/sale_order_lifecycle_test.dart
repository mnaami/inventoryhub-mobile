import 'package:flutter_test/flutter_test.dart';
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
  late dynamic db;
  late SaleOrderService service;

  setUp(() {
    db = newTestDb();
    service = SaleOrderService(
      repository: SaleOrderRepositoryImpl(SaleOrderDao(db),
          SaleOrderPaymentDao(db), SaleOrderShippingDao(db),
          DocumentCounterDao(db)),
      ids: const IdGenerator(),
      organizationId: 'org1',
      userId: 'u1',
    );
  });
  tearDown(() => db.close());

  NewLine line(double qty, double price) =>
      NewLine(productId: 'p1', productName: 'Widget', quantity: qty, unitPrice: price);

  test('createDraft assigns SO number, computes total, starts as draft', () async {
    final o = await service.createDraft(customerId: 'c1', lines: [line(2, 25)]);
    expect(o.soNumber, 'SO-0001');
    expect(o.totalAmount, 50);
    expect(o.status, OrderStatus.draft);
    expect((await service.items(o.id)).single.totalPrice, 50);
  });

  test('createDraft rejects an empty line list', () async {
    await expectLater(
      service.createDraft(customerId: 'c1', lines: const []),
      throwsA(isA<ValidationException>()),
    );
  });

  test('confirm freezes total and moves draft -> confirmed', () async {
    final o = await service.createDraft(customerId: 'c1', lines: [line(1, 10)]);
    await service.confirm(o);
    expect((await service.get(o.id))!.status, OrderStatus.confirmed);
  });

  test('process moves confirmed -> processing; illegal from draft', () async {
    final o = await service.createDraft(customerId: 'c1', lines: [line(1, 10)]);
    await expectLater(service.process(o), throwsA(isA<ValidationException>()));
    await service.confirm(o);
    await service.process(await service.get(o.id) as dynamic);
    expect((await service.get(o.id))!.status, OrderStatus.processing);
  });

  test('editDraft is rejected once confirmed', () async {
    final o = await service.createDraft(customerId: 'c1', lines: [line(1, 10)]);
    await service.confirm(o);
    final confirmed = (await service.get(o.id))!;
    await expectLater(
      service.editDraft(confirmed, [line(2, 10)]),
      throwsA(isA<ValidationException>()),
    );
  });

  test('cancel from confirmed sets cancelled', () async {
    final o = await service.createDraft(customerId: 'c1', lines: [line(1, 10)]);
    await service.confirm(o);
    await service.cancel((await service.get(o.id))!);
    expect((await service.get(o.id))!.status, OrderStatus.cancelled);
  });
}
