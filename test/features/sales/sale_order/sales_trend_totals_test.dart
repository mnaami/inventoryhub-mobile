import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/db/app_database.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/data/document_counter_dao.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/data/sale_order_dao.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/data/sale_order_payment_dao.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/data/sale_order_repository_impl.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/data/sale_order_shipping_dao.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/domain/sale_order_usecases.dart';
import '../../../helpers/test_db.dart';

void main() {
  late AppDatabase db;
  late SaleOrderService service;
  // Fixed LOCAL reference time: 2026-07-03 15:00. All seeded orderDates are
  // local too, so bucketing assertions hold in any machine timezone.
  final now = DateTime(2026, 7, 3, 15);

  SaleOrdersCompanion order(
    String id, {
    required DateTime orderDate,
    String status = 'confirmed',
    double total = 10,
  }) =>
      SaleOrdersCompanion.insert(
        id: id,
        organizationId: 'org1',
        soNumber: 'SO-$id',
        customerId: 'c1',
        orderDate: orderDate,
        status: Value(status),
        paymentStatus: const Value('not_paid'),
        shippingStatus: const Value('not_shipped'),
        totalAmount: Value(total),
        createdAt: orderDate,
        updatedAt: orderDate,
      );

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

  group('dailySalesTotals', () {
    test('returns dense oldest-first buckets with correct sums and filters',
        () async {
      final dao = db.saleOrderDao;
      // Today, two orders — same bucket, summed. One is a draft (included).
      await dao.createWithItems(
          order('1', orderDate: DateTime(2026, 7, 3, 12), total: 10),
          const []);
      await dao.createWithItems(
          order('2',
              orderDate: DateTime(2026, 7, 3, 9),
              total: 20,
              status: 'draft'),
          const []);
      // 3 days ago.
      await dao.createWithItems(
          order('3', orderDate: DateTime(2026, 6, 30, 8), total: 7), const []);
      // 7 days ago — OUTSIDE a 7-day window ending today.
      await dao.createWithItems(
          order('4', orderDate: DateTime(2026, 6, 26, 8), total: 99),
          const []);
      // Today but cancelled — excluded.
      await dao.createWithItems(
          order('5',
              orderDate: DateTime(2026, 7, 3, 10),
              total: 50,
              status: 'cancelled'),
          const []);
      // Today but soft-deleted — excluded.
      await dao.createWithItems(
          order('6', orderDate: DateTime(2026, 7, 3, 11), total: 50),
          const []);
      await dao.softDelete('6', now);

      final r = await service.dailySalesTotals(days: 7, now: now);

      expect(r.length, 7);
      expect(r.first.bucketStart, DateTime(2026, 6, 27)); // oldest first
      expect(r.last.bucketStart, DateTime(2026, 7, 3)); // today last
      expect(r.last.total, 30); // 10 + 20 (draft included)
      expect(r[3].total, 7); // 2026-06-30
      expect(r[1].total, 0); // dense zero-day present
    });

    test('30-day window boundaries', () async {
      final dao = db.saleOrderDao;
      // Oldest included day for days=30 ending 2026-07-03 is 2026-06-04.
      await dao.createWithItems(
          order('1', orderDate: DateTime(2026, 6, 4, 0, 30), total: 5),
          const []);
      // 2026-06-03 is outside.
      await dao.createWithItems(
          order('2', orderDate: DateTime(2026, 6, 3, 23, 59), total: 99),
          const []);

      final r = await service.dailySalesTotals(days: 30, now: now);

      expect(r.length, 30);
      expect(r.first.bucketStart, DateTime(2026, 6, 4));
      expect(r.first.total, 5);
      expect(r.fold<double>(0, (a, p) => a + p.total), 5);
    });
  });

  group('hourlySalesTotals', () {
    test('returns 24 dense hour buckets for the local day of `now`',
        () async {
      final dao = db.saleOrderDao;
      await dao.createWithItems(
          order('1', orderDate: DateTime(2026, 7, 3, 9, 15), total: 10),
          const []);
      await dao.createWithItems(
          order('2', orderDate: DateTime(2026, 7, 3, 9, 45), total: 5),
          const []);
      await dao.createWithItems(
          order('3', orderDate: DateTime(2026, 7, 3, 23, 59), total: 2),
          const []);
      // Yesterday — excluded.
      await dao.createWithItems(
          order('4', orderDate: DateTime(2026, 7, 2, 23), total: 99),
          const []);

      final r = await service.hourlySalesTotals(now: now);

      expect(r.length, 24);
      expect(r.first.bucketStart, DateTime(2026, 7, 3, 0));
      expect(r[9].total, 15); // 09:15 + 09:45 summed
      expect(r[23].total, 2);
      expect(r.fold<double>(0, (a, p) => a + p.total), 17);
    });
  });
}
