import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/db/app_database.dart';

/// Reproduces the real on-device upgrade path (which `AppDatabase.forTesting()`
/// — a fresh v5 `onCreate` — never exercises). A v4 device has `products` WITH
/// `is_sample` (it has carried the column since slice 1) and the other demo
/// tables WITHOUT it (the column was added to their definitions in v5). The v5
/// migration must add the flag where it is missing and must NOT re-add it to
/// `products`.
void main() {
  // The 15 demo tables that gained `is_sample` in v5 — a v4 device has them
  // without the column.
  const v4TablesWithoutFlag = [
    'categories',
    'units',
    'customers',
    'suppliers',
    'stock_movements',
    'sale_orders',
    'sale_order_items',
    'sale_order_payments',
    'sale_order_shippings',
    'sale_order_shipping_items',
    'purchase_orders',
    'purchase_order_items',
    'purchase_order_receipts',
    'purchase_order_receipt_items',
    'purchase_order_payments',
  ];

  late Directory dir;
  late File file;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('ih_mig_v4v5');
    file = File('${dir.path}/app.sqlite');
  });
  tearDown(() {
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  // Lays down a v4-shaped schema and stamps user_version = 4.
  Future<void> buildV4Database() async {
    final setup = _V4Setup(NativeDatabase(file), v4TablesWithoutFlag);
    await setup.customSelect('SELECT 1').get(); // triggers onCreate at v4
    await setup.close();
  }

  Future<bool> hasIsSampleColumn(AppDatabase db, String table) async {
    final rows = await db.customSelect('PRAGMA table_info($table)').get();
    return rows.any((r) => r.read<String>('name') == 'is_sample');
  }

  test('upgrading a v4 database to v5 does not crash and backfills the flag',
      () async {
    await buildV4Database();

    final db = AppDatabase(NativeDatabase(file));
    addTearDown(db.close);

    // Forces the v4 -> v5 onUpgrade to run.
    await db.customSelect('SELECT 1').get();

    // products keeps its long-standing column (must not be re-added).
    expect(await hasIsSampleColumn(db, 'products'), isTrue);
    // A table that lacked the flag now has it.
    expect(await hasIsSampleColumn(db, 'categories'), isTrue);
    expect(await hasIsSampleColumn(db, 'purchase_order_payments'), isTrue);
  });
}

/// Minimal drift database used only to lay down a v4-shaped schema on disk.
class _V4Setup extends GeneratedDatabase {
  _V4Setup(super.executor, this._tablesWithoutFlag);

  final List<String> _tablesWithoutFlag;

  @override
  Iterable<TableInfo<Table, dynamic>> get allTables => const [];

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          // products has carried is_sample since slice 1.
          await customStatement(
            'CREATE TABLE products (id TEXT NOT NULL PRIMARY KEY, '
            'is_sample INTEGER NOT NULL DEFAULT 0);',
          );
          for (final t in _tablesWithoutFlag) {
            await customStatement(
              'CREATE TABLE $t (id TEXT NOT NULL PRIMARY KEY);',
            );
          }
          // production_orders exists since v4 (before is_sample and before
          // employee_id); later onUpgrade steps (v6) alter it, so the
          // fixture must include it to accurately represent a v4 device.
          await customStatement(
            'CREATE TABLE production_orders (id TEXT NOT NULL PRIMARY KEY);',
          );
        },
      );
}
