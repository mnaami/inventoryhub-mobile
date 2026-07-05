import 'package:drift/drift.dart';
import '../../../../core/db/app_database.dart';
import '../../../../core/id/id_generator.dart';
import '../data/production_pay_rate_dao.dart';

class ProductionPayRateService {
  ProductionPayRateService({
    required ProductionPayRateDao dao,
    required IdGenerator ids,
    required String organizationId,
  })  : _dao = dao,
        _ids = ids,
        _orgId = organizationId;

  final ProductionPayRateDao _dao;
  final IdGenerator _ids;
  final String _orgId;

  Future<double> resolveRate({
    required String employeeId,
    required String productId,
  }) async {
    final override =
        await _dao.overrideForEmployeeProduct(_orgId, employeeId, productId);
    if (override != null) return override.rate;
    final fallback = await _dao.defaultForProduct(_orgId, productId);
    return fallback?.rate ?? 0.0;
  }

  Future<void> setDefaultRate(String productId, double rate) =>
      _upsertRate(employeeId: null, productId: productId, rate: rate);

  Future<void> setOverride({
    required String employeeId,
    required String productId,
    required double rate,
  }) =>
      _upsertRate(employeeId: employeeId, productId: productId, rate: rate);

  Future<void> removeOverride(String id) =>
      _dao.deactivate(id, DateTime.now().toUtc());

  Future<void> _upsertRate({
    required String? employeeId,
    required String productId,
    required double rate,
  }) async {
    final existing = employeeId == null
        ? await _dao.defaultForProduct(_orgId, productId)
        : await _dao.overrideForEmployeeProduct(_orgId, employeeId, productId);
    final now = DateTime.now().toUtc();
    if (existing != null) {
      await _dao.upsert(ProductionPayRatesCompanion(
        id: Value(existing.id),
        organizationId: Value(_orgId),
        productId: Value(productId),
        employeeId: Value(employeeId),
        rate: Value(rate),
        createdAt: Value(existing.createdAt),
        updatedAt: Value(now),
      ));
    } else {
      await _dao.upsert(ProductionPayRatesCompanion.insert(
        id: _ids.newId(),
        organizationId: _orgId,
        productId: productId,
        employeeId: Value(employeeId),
        rate: rate,
        createdAt: now,
        updatedAt: now,
      ));
    }
  }
}
