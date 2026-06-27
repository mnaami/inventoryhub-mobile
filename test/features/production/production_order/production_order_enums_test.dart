import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/features/production/production_order/domain/production_order_enums.dart';

void main() {
  test('wire round-trips for every status', () {
    for (final s in ProductionOrderStatus.values) {
      expect(ProductionOrderStatus.fromWire(s.wire), s);
    }
  });

  test('wire values are the expected snake_case strings', () {
    expect(ProductionOrderStatus.planned.wire, 'planned');
    expect(ProductionOrderStatus.inProgress.wire, 'in_progress');
    expect(ProductionOrderStatus.completed.wire, 'completed');
    expect(ProductionOrderStatus.cancelled.wire, 'cancelled');
  });
}
