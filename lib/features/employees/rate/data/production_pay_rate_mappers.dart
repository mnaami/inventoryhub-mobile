import 'package:drift/drift.dart';
import '../../../../core/db/app_database.dart';
import '../domain/production_pay_rate.dart';

ProductionPayRate toProductionPayRate(ProductionPayRateRow r) =>
    ProductionPayRate(
      id: r.id,
      organizationId: r.organizationId,
      productId: r.productId,
      employeeId: r.employeeId,
      rate: r.rate,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
    );

ProductionPayRatesCompanion productionPayRateInsert(ProductionPayRate r) =>
    ProductionPayRatesCompanion.insert(
      id: r.id,
      organizationId: r.organizationId,
      productId: r.productId,
      employeeId: Value(r.employeeId),
      rate: r.rate,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
    );
