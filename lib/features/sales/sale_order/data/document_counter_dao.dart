import 'package:drift/drift.dart';
import '../../../../core/db/app_database.dart';
import 'document_counter_table.dart';

part 'document_counter_dao.g.dart';

@DriftAccessor(tables: [DocumentCounters])
class DocumentCounterDao extends DatabaseAccessor<AppDatabase>
    with _$DocumentCounterDaoMixin {
  DocumentCounterDao(super.db);

  /// Atomically reads-and-increments the (org, entityType) counter and
  /// returns the formatted label, e.g. 'SO-0001'. Safe to call inside an
  /// enclosing transaction (Drift coalesces nested transactions).
  Future<String> next(String orgId, String entityType, String prefix) {
    return transaction(() async {
      final row = await (select(documentCounters)
            ..where((c) =>
                c.organizationId.equals(orgId) &
                c.entityType.equals(entityType)))
          .getSingleOrNull();
      final seq = row?.nextSeq ?? 1;
      if (row == null) {
        await into(documentCounters).insert(DocumentCountersCompanion.insert(
            organizationId: orgId,
            entityType: entityType,
            nextSeq: const Value(2)));
      } else {
        await (update(documentCounters)
              ..where((c) =>
                  c.organizationId.equals(orgId) &
                  c.entityType.equals(entityType)))
            .write(DocumentCountersCompanion(nextSeq: Value(seq + 1)));
      }
      return '$prefix-${seq.toString().padLeft(4, '0')}';
    });
  }
}
