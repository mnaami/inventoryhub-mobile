// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_counter_dao.dart';

// ignore_for_file: type=lint
mixin _$DocumentCounterDaoMixin on DatabaseAccessor<AppDatabase> {
  $DocumentCountersTable get documentCounters =>
      attachedDatabase.documentCounters;
  DocumentCounterDaoManager get managers => DocumentCounterDaoManager(this);
}

class DocumentCounterDaoManager {
  final _$DocumentCounterDaoMixin _db;
  DocumentCounterDaoManager(this._db);
  $$DocumentCountersTableTableManager get documentCounters =>
      $$DocumentCountersTableTableManager(
        _db.attachedDatabase,
        _db.documentCounters,
      );
}
