import 'unit.dart';

abstract interface class UnitRepository {
  Future<List<Unit>> listActive(String organizationId);
  Future<List<Unit>> baseUnits(String organizationId);
  Future<Unit?> getById(String id);
  Future<Unit> create(Unit unit);
  Future<Unit> update(Unit unit);
  Future<void> softDelete(String id);
}
