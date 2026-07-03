// Regression test for the home-dashboard / sale-order-list "this week" /
// "this month" divergence: the dashboard's stat cards and the list screen
// they push into must agree on exactly which orders count, or a tap-through
// shows a different number than the card just displayed.
//
// Before the fix, `SaleOrderListCriteria.week`/`.month` computed ROLLING
// windows (`now - 7 days` / `now - 30 days`, UTC) while
// `homeDashboardProvider` computed CALENDAR windows (Monday-to-date / whole
// month, local time). This test seeds orders that land differently under
// the two conventions and proves both code paths now produce the same
// count for the same preset.
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/db/app_database.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/core/providers.dart';
import 'package:inventoryhub_mobile/core/seed/seed_service.dart';
import 'package:inventoryhub_mobile/features/home/presentation/home_providers.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/presentation/sale_order_providers.dart';
import '../../helpers/test_db.dart';

void main() {
  Future<ProviderContainer> setUpContainer() async {
    final db = newTestDb();
    addTearDown(db.close);
    final session = await SeedService(db, const IdGenerator()).ensureSeeded();
    final container = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
      sessionProvider.overrideWithValue(session),
    ]);
    return container;
  }

  /// Seeds one confirmed sale order per day for the last [daysBack] local
  /// calendar days (inclusive of today), so the seeded data spans week and
  /// month boundaries regardless of what day "today" happens to be.
  Future<void> seedOneOrderPerDay(
      AppDatabase db, String orgId, int daysBack) async {
    final today = DateTime.now();
    for (var i = 0; i <= daysBack; i++) {
      final day = DateTime(today.year, today.month, today.day - i);
      await db.saleOrderDao.createWithItems(
        SaleOrdersCompanion.insert(
          id: 'so-back-$i',
          organizationId: orgId,
          soNumber: 'SO-BACK-$i',
          customerId: 'c1',
          orderDate: day,
          status: const Value('confirmed'),
          totalAmount: const Value(10),
          createdAt: day,
          updatedAt: day,
        ),
        const [],
      );
    }
  }

  test(
      'thisWeek.orderCount matches SaleOrderService.list() count for DatePreset.week',
      () async {
    final container = await setUpContainer();
    addTearDown(container.dispose);
    final db = container.read(appDatabaseProvider);
    final session = container.read(sessionProvider);

    // Spans well past a month so both week and month windows have a mix of
    // in-range and out-of-range orders.
    await seedOneOrderPerDay(db, session.organizationId, 40);

    final data = await container.read(homeDashboardProvider.future);

    // Drive the SAME code path the list screen uses after a tap-through:
    // set the criteria preset, read its resulting from/to, call the
    // service directly (bypassing pagination limits by using a large page
    // size worth of pages isn't needed here since count is what we check).
    final criteria = container.read(saleOrderCriteriaProvider.notifier);
    criteria.setDatePreset(DatePreset.week);
    final weekCriteria = container.read(saleOrderCriteriaProvider);
    expect(weekCriteria.from != null, isTrue);
    expect(weekCriteria.to != null, isTrue);

    final service = container.read(saleOrderServiceProvider);
    final weekCount = await service.countByDateRange(
        weekCriteria.from!, weekCriteria.to!);

    expect(data.thisWeek.orderCount, weekCount,
        reason: 'The "This Week" stat card and the list screen\'s '
            'DatePreset.week filter must agree on the same order count.');
  });

  test(
      'thisMonth.orderCount matches SaleOrderService.list() count for DatePreset.month',
      () async {
    final container = await setUpContainer();
    addTearDown(container.dispose);
    final db = container.read(appDatabaseProvider);
    final session = container.read(sessionProvider);

    await seedOneOrderPerDay(db, session.organizationId, 40);

    final data = await container.read(homeDashboardProvider.future);

    final criteria = container.read(saleOrderCriteriaProvider.notifier);
    criteria.setDatePreset(DatePreset.month);
    final monthCriteria = container.read(saleOrderCriteriaProvider);
    expect(monthCriteria.from != null, isTrue);
    expect(monthCriteria.to != null, isTrue);

    final service = container.read(saleOrderServiceProvider);
    final monthCount = await service.countByDateRange(
        monthCriteria.from!, monthCriteria.to!);

    expect(data.thisMonth.orderCount, monthCount,
        reason: 'The "This Month" stat card and the list screen\'s '
            'DatePreset.month filter must agree on the same order count.');
  });

  test(
      'DatePreset.week list() results are a subset of, and consistent with, '
      'the dashboard week count (end-to-end through the paged list query)',
      () async {
    final container = await setUpContainer();
    addTearDown(container.dispose);
    final db = container.read(appDatabaseProvider);
    final session = container.read(sessionProvider);

    await seedOneOrderPerDay(db, session.organizationId, 40);

    final data = await container.read(homeDashboardProvider.future);

    final criteria = container.read(saleOrderCriteriaProvider.notifier);
    criteria.setDatePreset(DatePreset.week);
    final weekCriteria = container.read(saleOrderCriteriaProvider);

    // This is the exact call the list screen's paged notifier makes.
    final service = container.read(saleOrderServiceProvider);
    final listed = await service.list(
      from: weekCriteria.from,
      to: weekCriteria.to,
    );

    // With <=41 seeded orders and a week window, results fit on page 0.
    expect(listed.length, data.thisWeek.orderCount,
        reason: 'Tapping through "This Week" must show exactly the order '
            'count the card displayed.');
  });
}
