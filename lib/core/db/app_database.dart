import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [], daos: [])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// In-memory database for tests.
  AppDatabase.forTesting() : super(NativeDatabase.memory());

  /// On-device database for the running app.
  factory AppDatabase.open() =>
      AppDatabase(driftDatabase(name: 'inventoryhub'));

  @override
  int get schemaVersion => 1;
}
