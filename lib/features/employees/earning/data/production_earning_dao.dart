import 'package:drift/drift.dart';
import '../../../../core/db/app_database.dart';
import 'production_earning_table.dart';

part 'production_earning_dao.g.dart';

@DriftAccessor(tables: [ProductionEarnings])
class ProductionEarningDao extends DatabaseAccessor<AppDatabase>
    with _$ProductionEarningDaoMixin {
  ProductionEarningDao(super.db);

  Future<List<ProductionEarningRow>> earningsForEmployee(
    String orgId,
    String employeeId,
  ) =>
      (select(productionEarnings)
            ..where((e) =>
                e.organizationId.equals(orgId) &
                e.employeeId.equals(employeeId))
            ..orderBy([
              (e) =>
                  OrderingTerm(expression: e.createdAt, mode: OrderingMode.desc)
            ]))
          .get();

  Future<double> totalForEmployee(String orgId, String employeeId) async {
    final sum = productionEarnings.amount.sum();
    final q = selectOnly(productionEarnings)
      ..addColumns([sum])
      ..where(productionEarnings.organizationId.equals(orgId) &
          productionEarnings.employeeId.equals(employeeId));
    return (await q.getSingle()).read(sum) ?? 0.0;
  }

  Future<ProductionEarningRow?> earningForOrder(String orderId) =>
      (select(productionEarnings)
            ..where((e) => e.productionOrderId.equals(orderId)))
          .getSingleOrNull();
}
