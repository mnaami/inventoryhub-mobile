import 'package:drift/drift.dart';
import '../db/app_database.dart';
import '../id/id_generator.dart';

class SeededContext {
  const SeededContext(this.organizationId, this.userId, this.defaultUnitId);
  final String organizationId;
  final String userId;
  final String defaultUnitId;
}

class SeedService {
  SeedService(this._db, this._ids);
  final AppDatabase _db;
  final IdGenerator _ids;

  Future<SeededContext> ensureSeeded() async {
    final existingOrg = await _db.select(_db.organizations).getSingleOrNull();
    if (existingOrg != null) {
      final user = await _db.select(_db.users).getSingle();
      // Resolve the original seeded base unit. Sample data and the unit editor
      // can add other base units (one per unit type), so pick the oldest base
      // unit deterministically rather than assuming exactly one exists.
      final unit = await (_db.select(_db.units)
            ..where((u) => u.isBaseUnit.equals(true))
            ..orderBy([(u) => OrderingTerm(expression: u.createdAt)])
            ..limit(1))
          .getSingle();
      return SeededContext(existingOrg.id, user.id, unit.id);
    }
    final now = DateTime.now().toUtc();
    final orgId = _ids.newId();
    final userId = _ids.newId();
    final unitId = _ids.newId();
    await _db.transaction(() async {
      await _db.into(_db.organizations).insert(OrganizationsCompanion.insert(
            id: orgId, name: 'My Business', createdAt: now, updatedAt: now,
          ));
      await _db.into(_db.users).insert(UsersCompanion.insert(
            id: userId, name: 'Me', organizationId: orgId,
            createdAt: now, updatedAt: now,
          ));
      await _db.into(_db.units).insert(UnitsCompanion.insert(
            id: unitId,
            organizationId: orgId,
            name: 'Piece',
            symbol: 'pc',
            unitType: 'count',
            isBaseUnit: const Value(true),
            conversionFactor: const Value(1.0),
            createdAt: now,
            updatedAt: now,
          ));
    });
    return SeededContext(orgId, userId, unitId);
  }
}
