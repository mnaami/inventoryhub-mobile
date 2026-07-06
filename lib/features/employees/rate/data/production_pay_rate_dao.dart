import 'package:drift/drift.dart';
import '../../../../core/db/app_database.dart';
import 'production_pay_rate_table.dart';

part 'production_pay_rate_dao.g.dart';

@DriftAccessor(tables: [ProductionPayRates])
class ProductionPayRateDao extends DatabaseAccessor<AppDatabase>
    with _$ProductionPayRateDaoMixin {
  ProductionPayRateDao(super.db);

  Future<ProductionPayRateRow?> defaultForProduct(
    String orgId,
    String productId,
  ) =>
      (select(productionPayRates)
            ..where((r) =>
                r.organizationId.equals(orgId) &
                r.productId.equals(productId) &
                r.employeeId.isNull() &
                r.isActive.equals(true)))
          .getSingleOrNull();

  Future<ProductionPayRateRow?> overrideForEmployeeProduct(
    String orgId,
    String employeeId,
    String productId,
  ) =>
      (select(productionPayRates)
            ..where((r) =>
                r.organizationId.equals(orgId) &
                r.employeeId.equals(employeeId) &
                r.productId.equals(productId) &
                r.isActive.equals(true)))
          .getSingleOrNull();

  Future<List<ProductionPayRateRow>> ratesForEmployee(
    String orgId,
    String employeeId,
  ) =>
      (select(productionPayRates)
            ..where((r) =>
                r.organizationId.equals(orgId) &
                r.employeeId.equals(employeeId)))
          .get();

  Future<List<ProductionPayRateRow>> defaultsForOrg(String orgId) =>
      (select(productionPayRates)
            ..where((r) =>
                r.organizationId.equals(orgId) & r.employeeId.isNull()))
          .get();

  Future<void> upsert(ProductionPayRatesCompanion rate) =>
      into(productionPayRates).insertOnConflictUpdate(rate);

  Future<void> deactivate(String id, DateTime now) =>
      (update(productionPayRates)..where((r) => r.id.equals(id))).write(
        ProductionPayRatesCompanion(
          isActive: const Value(false),
          updatedAt: Value(now),
        ),
      );
}
