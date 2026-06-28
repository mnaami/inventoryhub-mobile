import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/core/providers.dart';
import 'package:inventoryhub_mobile/core/seed/seed_service.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/domain/sale_order_enums.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/presentation/sale_order_providers.dart';
import '../../../helpers/test_db.dart';

void main() {
  test('list provider loads, and changing criteria reloads', () async {
    final db = newTestDb();
    addTearDown(db.close);
    final session = await SeedService(db, const IdGenerator()).ensureSeeded();
    final c = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
      sessionProvider.overrideWithValue(session),
    ]);
    addTearDown(c.dispose);

    c.read(saleOrderListProvider); // triggers initial load
    await Future<void>.delayed(Duration.zero);
    expect(c.read(saleOrderListProvider).isLoadingInitial, false);

    // Changing criteria should put it back into a fresh load cycle.
    c.read(saleOrderCriteriaProvider.notifier).setStatus(OrderStatus.confirmed);
    await Future<void>.delayed(Duration.zero);
    final s = c.read(saleOrderListProvider);
    expect(s.error, isNull);
  });
}
