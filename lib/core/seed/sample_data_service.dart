import 'package:drift/drift.dart';
import '../db/app_database.dart';
import '../id/id_generator.dart';
import 'seed_service.dart';

/// Counts of demo records currently loaded, for the Settings UI.
class SampleDataSummary {
  const SampleDataSummary({
    required this.products,
    required this.sales,
    required this.purchases,
  });
  final int products;
  final int sales;
  final int purchases;
  bool get isLoaded => products > 0;
}

/// Loads and removes the opt-in hardware-store demo dataset. Every demo row is
/// tagged `is_sample = true`; [remove] deletes exactly those rows in FK
/// child→parent order and never touches user-created data.
class SampleDataService {
  SampleDataService(this._db, this._ids, this._session);
  final AppDatabase _db;
  final IdGenerator _ids;
  final SeededContext _session;

  Future<bool> isLoaded() async {
    final rows = await (_db.select(_db.products)
          ..where((p) => p.isSample.equals(true))
          ..limit(1))
        .get();
    return rows.isNotEmpty;
  }

  Future<SampleDataSummary> summary() async {
    final products = await (_db.select(_db.products)
          ..where((p) => p.isSample.equals(true)))
        .get();
    final sales = await (_db.select(_db.saleOrders)
          ..where((o) => o.isSample.equals(true)))
        .get();
    final purchases = await (_db.select(_db.purchaseOrders)
          ..where((o) => o.isSample.equals(true)))
        .get();
    return SampleDataSummary(
      products: products.length,
      sales: sales.length,
      purchases: purchases.length,
    );
  }

  Future<void> remove() async {
    await _db.transaction(() async {
      // Children first, then parents; stock movements before products.
      await (_db.delete(_db.saleOrderShippingItems)..where((t) => t.isSample.equals(true))).go();
      await (_db.delete(_db.saleOrderPayments)..where((t) => t.isSample.equals(true))).go();
      await (_db.delete(_db.saleOrderShippings)..where((t) => t.isSample.equals(true))).go();
      await (_db.delete(_db.saleOrderItems)..where((t) => t.isSample.equals(true))).go();
      await (_db.delete(_db.saleOrders)..where((t) => t.isSample.equals(true))).go();
      await (_db.delete(_db.purchaseOrderReceiptItems)..where((t) => t.isSample.equals(true))).go();
      await (_db.delete(_db.purchaseOrderPayments)..where((t) => t.isSample.equals(true))).go();
      await (_db.delete(_db.purchaseOrderReceipts)..where((t) => t.isSample.equals(true))).go();
      await (_db.delete(_db.purchaseOrderItems)..where((t) => t.isSample.equals(true))).go();
      await (_db.delete(_db.purchaseOrders)..where((t) => t.isSample.equals(true))).go();
      await (_db.delete(_db.stockMovements)..where((t) => t.isSample.equals(true))).go();
      await (_db.delete(_db.products)..where((t) => t.isSample.equals(true))).go();
      await (_db.delete(_db.categories)..where((t) => t.isSample.equals(true))).go();
      await (_db.delete(_db.units)..where((t) => t.isSample.equals(true))).go();
      await (_db.delete(_db.customers)..where((t) => t.isSample.equals(true))).go();
      await (_db.delete(_db.suppliers)..where((t) => t.isSample.equals(true))).go();
    });
  }

  Future<void> load() async {
    final now = DateTime.now().toUtc();
    await _db.transaction(() async {
      final refs = _Refs();
      await _seedFoundation(refs, now);
      await _seedPurchasing(refs, now);
    });
  }

  _ProductRef _product(_Refs refs, String name) =>
      refs.products.firstWhere((p) => p.name == name);

  Future<void> _seedPurchasing(_Refs refs, DateTime now) async {
    final orgId = _session.organizationId;
    final userId = _session.userId;

    for (final s in _kSuppliers) {
      final id = _ids.newId();
      refs.supplierIds.add(id);
      await _db.supplierDao.insertRow(SuppliersCompanion.insert(
        id: id,
        organizationId: orgId,
        name: s[0] as String,
        contactPerson: Value(s[1] as String),
        paymentTerms: Value(s[2] as int),
        isSample: const Value(true),
        createdAt: now,
        updatedAt: now,
      ));
    }

    for (final spec in _kPurchaseOrders) {
      final orderDate = now.subtract(Duration(days: spec.daysAgo));
      final poId = _ids.newId();
      final number =
          await _db.documentCounterDao.next(orgId, 'purchase_order', 'PO');

      // Build line items.
      final items = <PurchaseOrderItemsCompanion>[];
      final lineRefs = <_PoLine>[];
      var total = 0.0;
      for (final it in spec.items) {
        final p = _product(refs, it[0] as String);
        final qty = it[1] as double;
        final cost = it[2] as double;
        final lineTotal = qty * cost;
        total += lineTotal;
        final itemId = _ids.newId();
        items.add(PurchaseOrderItemsCompanion.insert(
          id: itemId,
          organizationId: orgId,
          purchaseOrderId: poId,
          productId: p.id,
          productName: p.name,
          quantity: qty,
          unitPrice: cost,
          totalPrice: lineTotal,
          isSample: const Value(true),
          createdAt: orderDate,
          updatedAt: orderDate,
        ));
        lineRefs.add(_PoLine(itemId, p.id, qty));
      }

      await _db.purchaseOrderDao.createWithItems(
        PurchaseOrdersCompanion.insert(
          id: poId,
          organizationId: orgId,
          orderNumber: number,
          supplierId: refs.supplierIds[spec.supplierIndex],
          orderDate: orderDate,
          status: Value(spec.status),
          totalAmount: Value(total),
          isSample: const Value(true),
          createdAt: orderDate,
          updatedAt: orderDate,
        ),
        items,
      );

      if (spec.status == 'draft') continue;

      // Receipt (draft -> post) adds stock IN for the received fraction.
      if (spec.receiveFraction > 0) {
        final receiptDate = orderDate.add(const Duration(days: 2));
        final receiptId = _ids.newId();
        final rNumber =
            await _db.documentCounterDao.next(orgId, 'po_receipt', 'RCP');
        final receiptItems = <PurchaseOrderReceiptItemsCompanion>[];
        final movementByReceiptItem = <String, String>{};
        for (final l in lineRefs) {
          final recvQty = l.qty * spec.receiveFraction;
          if (recvQty <= 0) continue;
          final riId = _ids.newId();
          final movId = _ids.newId();
          movementByReceiptItem[riId] = movId;
          refs.receiptMovementIds.add(movId);
          receiptItems.add(PurchaseOrderReceiptItemsCompanion.insert(
            id: riId,
            organizationId: orgId,
            receiptId: receiptId,
            purchaseOrderItemId: l.itemId,
            productId: l.productId,
            quantity: recvQty,
            isSample: const Value(true),
            createdAt: receiptDate,
          ));
        }
        await _db.purchaseOrderReceiptDao.createReceipt(
          receipt: PurchaseOrderReceiptsCompanion.insert(
            id: receiptId,
            organizationId: orgId,
            purchaseOrderId: poId,
            receiptNumber: rNumber,
            receiptDate: receiptDate,
            isSample: const Value(true),
            createdAt: receiptDate,
            updatedAt: receiptDate,
          ),
          items: receiptItems,
        );
        await _db.purchaseOrderReceiptDao.post(
          receiptId: receiptId,
          movementIdByReceiptItem: movementByReceiptItem,
          createdBy: userId,
          now: receiptDate,
        );
      }

      // Payment (draft -> post) for the paid fraction.
      if (spec.payFraction > 0) {
        final payDate = orderDate.add(const Duration(days: 3));
        final payId = _ids.newId();
        final pNumber =
            await _db.documentCounterDao.next(orgId, 'po_payment', 'PPAY');
        await _db.purchaseOrderPaymentDao.createDraft(
          PurchaseOrderPaymentsCompanion.insert(
            id: payId,
            organizationId: orgId,
            purchaseOrderId: poId,
            paymentNumber: pNumber,
            amount: total * spec.payFraction,
            method: 'bank_transfer',
            paymentDate: payDate,
            isSample: const Value(true),
            createdAt: payDate,
            updatedAt: payDate,
          ),
        );
        await _db.purchaseOrderPaymentDao.post(payId, payDate);
      }
    }
  }

  Future<void> _seedFoundation(_Refs refs, DateTime now) async {
    final orgId = _session.organizationId;
    refs.unitIdBySymbol['pc'] = _session.defaultUnitId;

    for (final u in _kUnits) {
      final id = _ids.newId();
      refs.unitIdBySymbol[u[0] as String] = id;
      await _db.unitDao.insertRow(UnitsCompanion.insert(
        id: id,
        organizationId: orgId,
        name: u[1] as String,
        symbol: u[0] as String,
        unitType: u[2] as String,
        isBaseUnit: Value(u[3] as bool),
        baseUnitId: (u[3] as bool)
            ? const Value.absent()
            : Value(_session.defaultUnitId),
        conversionFactor: Value(u[4] as double),
        isSample: const Value(true),
        createdAt: now,
        updatedAt: now,
      ));
    }

    for (final name in _kCategories) {
      final id = _ids.newId();
      refs.categoryIdByName[name] = id;
      await _db.categoryDao.insertRow(CategoriesCompanion.insert(
        id: id,
        organizationId: orgId,
        name: name,
        isSample: const Value(true),
        createdAt: now,
        updatedAt: now,
      ));
    }

    for (final p in _kProducts) {
      final id = _ids.newId();
      final unitId = refs.unitIdBySymbol[p[2] as String]!;
      refs.products.add(_ProductRef(
        id, p[0] as String, unitId, p[3] as double, p[4] as double, p[5] as double,
      ));
      await _db.productDao.insertRow(ProductsCompanion.insert(
        id: id,
        organizationId: orgId,
        name: p[0] as String,
        unitId: unitId,
        categoryId: Value(refs.categoryIdByName[p[1] as String]!),
        purchasePrice: Value(p[3] as double),
        sellingPrice: Value(p[4] as double),
        minimumStock: Value(p[5] as double),
        isSample: const Value(true),
        createdAt: now,
        updatedAt: now,
      ));
    }
  }
}

class _ProductRef {
  _ProductRef(this.id, this.name, this.unitId, this.purchasePrice,
      this.sellingPrice, this.minimumStock);
  final String id;
  final String name;
  final String unitId;
  final double purchasePrice;
  final double sellingPrice;
  final double minimumStock;
}

class _PoLine {
  _PoLine(this.itemId, this.productId, this.qty);
  final String itemId;
  final String productId;
  final double qty;
}

class _Refs {
  final Map<String, String> unitIdBySymbol = {};
  final Map<String, String> categoryIdByName = {};
  final List<_ProductRef> products = [];
  final List<String> supplierIds = [];
  final List<String> customerIds = [];
  final List<String> shipMovementIds = [];
  final List<String> receiptMovementIds = [];
}

// (symbol, name, unitType, isBase, conversionFactor) — 'pc' reuses the seed unit.
const _kUnits = <List<Object>>[
  ['box100', 'Box of 100', 'count', false, 100.0],
  ['m', 'Meter', 'length', true, 1.0],
  ['L', 'Liter', 'volume', true, 1.0],
  ['kg', 'Kilogram', 'weight', true, 1.0],
];

const _kCategories = <String>[
  'Power Tools', 'Hand Tools', 'Fasteners', 'Timber', 'Paint & Finishes', 'Plumbing',
];

// (name, category, unitSymbol|'pc', purchasePrice, sellingPrice, minimumStock)
const _kProducts = <List<Object>>[
  ['Cordless Drill 18V', 'Power Tools', 'pc', 75.0, 129.0, 3.0],
  ['Claw Hammer', 'Hand Tools', 'pc', 8.0, 16.0, 5.0],
  ['Tape Measure 5m', 'Hand Tools', 'pc', 4.0, 9.0, 8.0],
  ['Adjustable Wrench', 'Hand Tools', 'pc', 6.0, 13.0, 5.0],
  ['Pipe Wrench', 'Hand Tools', 'pc', 11.0, 22.0, 4.0],
  ['Wood Screws 4x40', 'Fasteners', 'box100', 3.0, 7.0, 10.0],
  ['Hex Bolts M8', 'Fasteners', 'box100', 5.0, 11.0, 8.0],
  ['Wall Plugs', 'Fasteners', 'box100', 2.0, 5.0, 12.0],
  ['Pine Plank 2.4m', 'Timber', 'm', 2.5, 5.5, 20.0],
  ['Plywood Sheet', 'Timber', 'pc', 18.0, 32.0, 6.0],
  ['Interior Paint 5L', 'Paint & Finishes', 'L', 4.0, 9.0, 15.0],
  ['Exterior Paint 5L', 'Paint & Finishes', 'L', 5.0, 11.0, 10.0],
  ['Paint Roller Set', 'Paint & Finishes', 'pc', 5.0, 12.0, 6.0],
  ['Copper Pipe 15mm', 'Plumbing', 'm', 3.0, 7.0, 25.0],
  ['PVC Elbow 32mm', 'Plumbing', 'pc', 1.0, 3.0, 20.0],
  ['Safety Goggles', 'Hand Tools', 'pc', 3.0, 8.0, 10.0],
];

// A purchase order spec.
// items: (productName, qty, unitCost); receiveFraction: 0..1 of each line;
// payFraction: 0..1 of total (posted); status: 'sent' or 'draft'; daysAgo.
class _PoSpec {
  const _PoSpec(this.supplierIndex, this.items, this.receiveFraction,
      this.payFraction, this.status, this.daysAgo);
  final int supplierIndex;
  final List<List<Object>> items;
  final double receiveFraction;
  final double payFraction;
  final String status;
  final int daysAgo;
}

const _kSuppliers = <List<Object>>[
  ['BuildPro Wholesale', 'Dana Cole', 30],
  ['FastFix Fasteners', 'Sam Reyes', 15],
  ['ColorCraft Paints', 'Lee Park', 30],
  ['Timberline Supply', 'Jo Quinn', 45],
];

const _kPurchaseOrders = <_PoSpec>[
  _PoSpec(0, [
    ['Cordless Drill 18V', 10.0, 75.0],
    ['Plywood Sheet', 12.0, 18.0],
    ['Paint Roller Set', 10.0, 5.0],
  ], 1.0, 1.0, 'sent', 8),
  _PoSpec(1, [
    ['Wood Screws 4x40', 40.0, 3.0],
    ['Hex Bolts M8', 30.0, 5.0],
    ['Wall Plugs', 50.0, 2.0],
  ], 1.0, 0.5, 'sent', 20),
  _PoSpec(2, [
    ['Interior Paint 5L', 30.0, 4.0],
    ['Exterior Paint 5L', 20.0, 5.0],
  ], 1.0, 0.0, 'sent', 15),
  _PoSpec(3, [
    ['Pine Plank 2.4m', 60.0, 2.5],
    ['Plywood Sheet', 10.0, 18.0],
  ], 0.6, 0.3, 'sent', 12),
  _PoSpec(0, [
    ['Claw Hammer', 12.0, 8.0],
    ['Tape Measure 5m', 15.0, 4.0],
    ['Adjustable Wrench', 10.0, 6.0],
    ['Pipe Wrench', 6.0, 11.0],
    ['Safety Goggles', 20.0, 3.0],
    ['Copper Pipe 15mm', 40.0, 3.0],
    ['PVC Elbow 32mm', 40.0, 1.0],
  ], 1.0, 1.0, 'sent', 30),
  _PoSpec(1, [
    ['Wood Screws 4x40', 20.0, 3.0],
    ['Hex Bolts M8', 15.0, 5.0],
  ], 0.0, 0.0, 'draft', 3),
];
