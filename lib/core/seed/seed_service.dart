import '../db/app_database.dart';
import '../id/id_generator.dart';

class SeededContext {
  const SeededContext(this.organizationId, this.userId);
  final String organizationId;
  final String userId;
}

class SeedService {
  SeedService(this._db, this._ids);
  final AppDatabase _db;
  final IdGenerator _ids;

  Future<SeededContext> ensureSeeded() async {
    final existingOrg = await _db.select(_db.organizations).getSingleOrNull();
    if (existingOrg != null) {
      final user = await _db.select(_db.users).getSingle();
      return SeededContext(existingOrg.id, user.id);
    }
    final now = DateTime.now().toUtc();
    final orgId = _ids.newId();
    final userId = _ids.newId();
    await _db.transaction(() async {
      await _db.into(_db.organizations).insert(OrganizationsCompanion.insert(
            id: orgId,
            name: 'My Business',
            createdAt: now,
            updatedAt: now,
          ));
      await _db.into(_db.users).insert(UsersCompanion.insert(
            id: userId,
            name: 'Me',
            organizationId: orgId,
            createdAt: now,
            updatedAt: now,
          ));
    });
    return SeededContext(orgId, userId);
  }
}
