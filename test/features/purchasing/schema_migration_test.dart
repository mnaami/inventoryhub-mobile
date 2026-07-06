import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/db/app_database.dart';
import '../../helpers/test_db.dart';

void main() {
  test('v3 tables exist and accept rows', () async {
    final db = newTestDb();
    final now = DateTime.utc(2026, 6, 26);
    await db.into(db.suppliers).insert(SuppliersCompanion.insert(
          id: 's1',
          organizationId: 'org1',
          name: 'Acme Supply',
          createdAt: now,
          updatedAt: now,
        ));
    final s = await db.select(db.suppliers).getSingle();
    expect(s.name, 'Acme Supply');
    expect(s.paymentTerms, 30);
    expect(s.isActive, isTrue);

    await db.into(db.purchaseOrders).insert(PurchaseOrdersCompanion.insert(
          id: 'po1',
          organizationId: 'org1',
          orderNumber: 'PO-0001',
          supplierId: 's1',
          orderDate: now,
          createdAt: now,
          updatedAt: now,
        ));
    final po = await db.select(db.purchaseOrders).getSingle();
    expect(po.status, 'draft');
    expect(po.receiptStatus, 'not_received');
    expect(po.paymentStatus, 'not_paid');
    await db.close();
  });

  test('schemaVersion is 6', () {
    final db = newTestDb();
    expect(db.schemaVersion, 6);
    db.close();
  });
}
