import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/db/app_database.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/core/providers.dart';
import 'package:inventoryhub_mobile/core/seed/seed_service.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/domain/sale_order_enums.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/presentation/sale_payment_providers.dart';
import '../../../helpers/test_db.dart';

void main() {
  test('payment list loads and a method filter change reloads filtered',
      () async {
    final db = newTestDb();
    addTearDown(db.close);
    final session = await SeedService(db, const IdGenerator()).ensureSeeded();
    final c = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
      sessionProvider.overrideWithValue(session),
    ]);
    addTearDown(c.dispose);

    final now = DateTime.utc(2026, 6, 1);
    await db.into(db.saleOrders).insert(SaleOrdersCompanion.insert(
          id: 'so1', organizationId: session.organizationId,
          soNumber: 'SO-0001', customerId: 'c1', orderDate: now,
          totalAmount: const Value(100), createdAt: now, updatedAt: now,
        ));
    await db.saleOrderPaymentDao.recordPayment(SaleOrderPaymentsCompanion.insert(
      id: 'p1', organizationId: session.organizationId, saleOrderId: 'so1',
      paymentNumber: 'PAY-0001', amount: 10, method: 'cash',
      status: const Value('completed'), paymentDate: now,
      createdAt: now, updatedAt: now,
    ));
    await db.saleOrderPaymentDao.recordPayment(SaleOrderPaymentsCompanion.insert(
      id: 'p2', organizationId: session.organizationId, saleOrderId: 'so1',
      paymentNumber: 'PAY-0002', amount: 20, method: 'bank_transfer',
      status: const Value('completed'), paymentDate: now,
      createdAt: now, updatedAt: now,
    ));

    c.read(salePaymentListProvider); // trigger initial load
    await Future<void>.delayed(Duration.zero);
    expect(c.read(salePaymentListProvider).items.length, 2);

    c.read(salePaymentCriteriaProvider.notifier).setMethod(PaymentMethod.cash);
    await Future<void>.delayed(Duration.zero);
    final s = c.read(salePaymentListProvider);
    expect(s.error, isNull);
    expect(s.items.single.paymentNumber, 'PAY-0001');
  });
}
