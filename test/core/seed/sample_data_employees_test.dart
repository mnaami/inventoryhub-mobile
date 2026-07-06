import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/db/app_database.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/core/seed/sample_data_service.dart';
import 'package:inventoryhub_mobile/core/seed/seed_service.dart';
import '../../helpers/test_db.dart';

void main() {
  late AppDatabase db;
  late SampleDataService service;
  late SeededContext session;

  setUp(() async {
    db = newTestDb();
    session = await SeedService(db, const IdGenerator()).ensureSeeded();
    service = SampleDataService(db, const IdGenerator(), session);
  });
  tearDown(() => db.close());

  group('employees, pay rates, earnings, payment', () {
    test('load creates >=2 sample employees, all tagged is_sample', () async {
      await service.load();
      final employees = await db.select(db.employees).get();
      expect(employees.length, greaterThanOrEqualTo(2));
      expect(employees.every((e) => e.isSample), isTrue);
    });

    test('load creates at least one default rate and one override rate, '
        'all tagged is_sample', () async {
      await service.load();
      final rates = await db.select(db.productionPayRates).get();
      expect(rates.every((r) => r.isSample), isTrue);
      expect(rates.where((r) => r.employeeId == null), isNotEmpty);
      expect(rates.where((r) => r.employeeId != null), isNotEmpty);
    });

    // production_orders has no is_sample column; the sample orders seeded here
    // are identified via their (sample-tagged) production_earnings rows,
    // which is also how remove() finds them to delete.
    Future<List<ProductionOrderRow>> sampleOrders() async {
      final earnings = await (db.select(db.productionEarnings)
            ..where((e) => e.isSample.equals(true)))
          .get();
      final ids = earnings.map((e) => e.productionOrderId).toSet().toList();
      if (ids.isEmpty) return [];
      return (db.select(db.productionOrders)..where((o) => o.id.isIn(ids)))
          .get();
    }

    test('load creates sample production orders with employee attribution',
        () async {
      await service.load();
      final orders = await sampleOrders();
      expect(orders.length, greaterThanOrEqualTo(2));
      expect(orders.every((o) => o.status == 'completed'), isTrue);
      expect(orders.every((o) => o.employeeId != null), isTrue);
      expect(orders.every((o) => o.completionDate != null), isTrue);
    });

    test('load creates >=1 earning per sample production order, all tagged '
        'is_sample and consistent with the seeded rate table', () async {
      await service.load();
      final orders = await sampleOrders();
      final earnings = await db.select(db.productionEarnings).get();
      expect(earnings, isNotEmpty);
      expect(earnings.every((e) => e.isSample), isTrue);
      // Every sample order has a corresponding earning.
      final earningOrderIds = earnings.map((e) => e.productionOrderId).toSet();
      for (final o in orders) {
        expect(earningOrderIds, contains(o.id));
      }
      // amount = quantity * rate for every earning row.
      for (final e in earnings) {
        expect(e.amount, closeTo(e.quantity * e.rate, 0.0001));
      }
    });

    test('load creates >=1 EPAY- employee payment, tagged is_sample, that '
        'partially pays down an employee balance', () async {
      await service.load();
      final payments = await db.select(db.employeePayments).get();
      expect(payments, isNotEmpty);
      expect(payments.every((p) => p.isSample), isTrue);
      expect(payments.every((p) => p.paymentNumber.startsWith('EPAY-')), isTrue);

      // At least one paid employee has a positive remaining balance
      // (earned > paid), i.e. a partial payment.
      final earnings = await db.select(db.productionEarnings).get();
      final earnedByEmployee = <String, double>{};
      for (final e in earnings) {
        earnedByEmployee[e.employeeId] =
            (earnedByEmployee[e.employeeId] ?? 0) + e.amount;
      }
      final paidByEmployee = <String, double>{};
      for (final p in payments) {
        paidByEmployee[p.employeeId] = (paidByEmployee[p.employeeId] ?? 0) + p.amount;
      }
      final hasPartial = paidByEmployee.entries.any((entry) {
        final earned = earnedByEmployee[entry.key] ?? 0;
        return earned > entry.value && entry.value > 0;
      });
      expect(hasPartial, isTrue);
    });

    test('remove deletes all sample employee/rate/earning/payment rows, '
        'and non-sample rows (org/users/counters) remain', () async {
      await service.load();

      // Sanity: rows exist before remove.
      expect(await db.select(db.employees).get(), isNotEmpty);
      expect(await db.select(db.productionPayRates).get(), isNotEmpty);
      expect(await db.select(db.productionEarnings).get(), isNotEmpty);
      expect(await db.select(db.employeePayments).get(), isNotEmpty);
      final sampleOrdersBefore = await sampleOrders();
      expect(sampleOrdersBefore, isNotEmpty);

      await service.remove();

      expect(await db.select(db.employees).get(), isEmpty);
      expect(await db.select(db.productionPayRates).get(), isEmpty);
      expect(await db.select(db.productionEarnings).get(), isEmpty);
      expect(await db.select(db.employeePayments).get(), isEmpty);
      // All sample production orders are gone too (found via the now-deleted
      // sample earnings' order ids — re-derive from the id set captured above).
      final remainingIds = sampleOrdersBefore.map((o) => o.id).toList();
      final stillPresent = await (db.select(db.productionOrders)
            ..where((o) => o.id.isIn(remainingIds)))
          .get();
      expect(stillPresent, isEmpty);

      // Non-sample infra rows remain untouched.
      expect(await db.select(db.organizations).get(), hasLength(1));
      expect(await db.select(db.users).get(), isNotEmpty);
      final counters = await db.select(db.documentCounters).get();
      expect(counters, isNotEmpty);
      expect(
        counters.map((c) => c.entityType),
        containsAll(['production_order', 'employee_payment']),
      );
    });
  });
}
