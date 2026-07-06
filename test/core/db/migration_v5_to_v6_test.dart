import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/db/app_database.dart';

/// Drives the v6 schema (employee tables + production_orders.employee_id)
/// through the current-version `onCreate` path. A fresh in-memory database
/// always builds the schema at the latest `schemaVersion`, so this proves the
/// v6 shape is present without needing a hand-rolled v5 fixture.
///
/// This is a supplement only. It does NOT exercise the real `onUpgrade`
/// chain — see the "upgrading a v5 database to v6" test below, which stamps
/// a genuine v5-shaped on-disk database and reopens it with `AppDatabase` to
/// force `onUpgrade(m, 5, 6)` to actually run (mirrors
/// migration_v4_to_v5_test.dart).
void main() {
  test('current schema (v6) includes employee tables and '
      'production_orders.employee_id', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await db.customStatement('SELECT 1'); // triggers onCreate

    final cols =
        await db.customSelect('PRAGMA table_info(production_orders)').get();
    expect(cols.map((r) => r.read<String>('name')), contains('employee_id'));

    // New tables exist and are empty.
    for (final t in [
      'employees',
      'production_pay_rates',
      'production_earnings',
      'employee_payments',
    ]) {
      final rows = await db.customSelect('SELECT COUNT(*) c FROM $t').get();
      expect(rows.first.read<int>('c'), 0, reason: '$t should exist');
    }
  });

  test('schemaVersion is 6', () {
    final db = AppDatabase(NativeDatabase.memory());
    expect(db.schemaVersion, 6);
    db.close();
  });

  group('real onUpgrade(5, 6) path', () {
    late Directory dir;
    late File file;

    setUp(() {
      dir = Directory.systemTemp.createTempSync('ih_mig_v5v6');
      file = File('${dir.path}/app.sqlite');
    });
    tearDown(() {
      if (dir.existsSync()) dir.deleteSync(recursive: true);
    });

    // Lays down a v5-shaped schema and stamps user_version = 5. Critically
    // includes `production_orders` (without `employee_id`, since that column
    // is only added in v6) because `_addColumnIfAbsent` reads its
    // `PRAGMA table_info` during the v6 upgrade step.
    Future<void> buildV5Database() async {
      final setup = _V5Setup(NativeDatabase(file));
      await setup.customSelect('SELECT 1').get(); // triggers onCreate at v5
      await setup.close();
    }

    Future<bool> hasColumn(AppDatabase db, String table, String column) async {
      final rows = await db.customSelect('PRAGMA table_info($table)').get();
      return rows.any((r) => r.read<String>('name') == column);
    }

    Future<bool> tableExists(AppDatabase db, String table) async {
      final rows = await db.customSelect(
        "SELECT name FROM sqlite_master WHERE type='table' AND name = '$table'",
      ).get();
      return rows.isNotEmpty;
    }

    test(
        'upgrading a v5 database to v6 does not crash and adds the '
        'employee tables plus production_orders.employee_id', () async {
      await buildV5Database();

      final db = AppDatabase(NativeDatabase(file));
      addTearDown(db.close);

      // Forces the v5 -> v6 onUpgrade to run.
      await db.customSelect('SELECT 1').get();

      // production_orders gains the new column.
      expect(await hasColumn(db, 'production_orders', 'employee_id'), isTrue);

      // The four new tables exist and are queryable.
      for (final t in [
        'employees',
        'production_pay_rates',
        'production_earnings',
        'employee_payments',
      ]) {
        expect(await tableExists(db, t), isTrue, reason: '$t should exist');
        final rows = await db.customSelect('SELECT COUNT(*) c FROM $t').get();
        expect(rows.first.read<int>('c'), 0);
      }
    });
  });
}

/// Minimal drift database used only to lay down a v5-shaped schema on disk.
class _V5Setup extends GeneratedDatabase {
  _V5Setup(super.executor);

  @override
  Iterable<TableInfo<Table, dynamic>> get allTables => const [];

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          // production_orders exists since v4 and gained is_sample in v5's
          // "add where absent" pass (see migration_v4_to_v5_test), but
          // employee_id is only added in v6 — the fixture must omit it so
          // that the v6 onUpgrade's _addColumnIfAbsent has real work to do.
          await customStatement(
            'CREATE TABLE production_orders (id TEXT NOT NULL PRIMARY KEY, '
            'is_sample INTEGER NOT NULL DEFAULT 0);',
          );
          // A couple of other v5 tables, enough to represent a real v5
          // device without needing every legacy column faithfully modeled.
          await customStatement(
            'CREATE TABLE products (id TEXT NOT NULL PRIMARY KEY, '
            'is_sample INTEGER NOT NULL DEFAULT 0);',
          );
          await customStatement(
            'CREATE TABLE production_recipes (id TEXT NOT NULL PRIMARY KEY);',
          );
        },
      );
}
