import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/db/app_database.dart';

/// Drives the v6 schema (employee tables + production_orders.employee_id)
/// through the current-version `onCreate` path. A fresh in-memory database
/// always builds the schema at the latest `schemaVersion`, so this proves the
/// v6 shape is present without needing a hand-rolled v5 fixture.
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
}
