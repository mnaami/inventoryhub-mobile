import '../../../../core/id/id_generator.dart';
import '../../../../core/result/app_exception.dart';
import 'unit.dart';
import 'unit_repository.dart';

class UnitService {
  UnitService({
    required UnitRepository repository,
    required IdGenerator ids,
    required String organizationId,
  })  : _repo = repository,
        _ids = ids,
        _orgId = organizationId;

  final UnitRepository _repo;
  final IdGenerator _ids;
  final String _orgId;

  Future<List<Unit>> list() => _repo.listActive(_orgId);
  Future<List<Unit>> baseUnits() => _repo.baseUnits(_orgId);

  Future<Unit> create({
    required String name,
    required String symbol,
    required String unitType,
    required bool isBase,
    String? baseUnitId,
    double conversionFactor = 1.0,
  }) {
    if (name.trim().isEmpty || symbol.trim().isEmpty) {
      throw const ValidationException('Unit name and symbol are required.');
    }
    if (!isBase && (baseUnitId == null || conversionFactor <= 0)) {
      throw const ValidationException(
          'A derived unit needs a base unit and a positive conversion factor.');
    }
    final now = DateTime.now().toUtc();
    return _repo.create(Unit(
      id: _ids.newId(),
      organizationId: _orgId,
      name: name.trim(),
      symbol: symbol.trim(),
      unitType: unitType,
      isBaseUnit: isBase,
      baseUnitId: isBase ? null : baseUnitId,
      conversionFactor: isBase ? 1.0 : conversionFactor,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    ));
  }

  Future<Unit> edit(Unit u) => _repo.update(u.copyWith(updatedAt: DateTime.now().toUtc()));

  Future<void> delete(String id) => _repo.softDelete(id);

  /// Converts [qty] from one unit to another within the same unit type.
  double convert(double qty, Unit from, Unit to) {
    if (from.unitType != to.unitType) {
      throw ValidationException(
          'Cannot convert between ${from.unitType} and ${to.unitType}.');
    }
    final inBase = qty * from.conversionFactor;
    return inBase / to.conversionFactor;
  }
}
