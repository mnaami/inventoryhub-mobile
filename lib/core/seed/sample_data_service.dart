import 'package:drift/drift.dart';
import '../db/app_database.dart';
import '../id/id_generator.dart';
import 'seed_service.dart';
import '../../features/sales/sale_order/data/sale_order_shipping_dao.dart'
    show ShipmentLine;

/// Counts of demo records currently loaded, for the Settings UI.
class SampleDataSummary {
  const SampleDataSummary({
    required this.products,
    required this.sales,
    required this.purchases,
    this.employees = 0,
  });
  final int products;
  final int sales;
  final int purchases;
  final int employees;
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
    final employees = await (_db.select(_db.employees)
          ..where((e) => e.isSample.equals(true)))
        .get();
    return SampleDataSummary(
      products: products.length,
      sales: sales.length,
      purchases: purchases.length,
      employees: employees.length,
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

      // Employee attribution + piece-rate pay demo data. production_orders has
      // no is_sample column, so the sample orders are identified via the ids
      // referenced by sample-tagged production_earnings rows (the only rows
      // we create there) before those earnings are deleted.
      final sampleEarnings = await (_db.select(_db.productionEarnings)
            ..where((e) => e.isSample.equals(true)))
          .get();
      final sampleOrderIds =
          sampleEarnings.map((e) => e.productionOrderId).toSet().toList();
      await (_db.delete(_db.employeePayments)..where((t) => t.isSample.equals(true))).go();
      await (_db.delete(_db.productionEarnings)..where((t) => t.isSample.equals(true))).go();
      await (_db.delete(_db.productionPayRates)..where((t) => t.isSample.equals(true))).go();
      if (sampleOrderIds.isNotEmpty) {
        await (_db.delete(_db.productionOrders)..where((o) => o.id.isIn(sampleOrderIds))).go();
      }
      await (_db.delete(_db.employees)..where((t) => t.isSample.equals(true))).go();

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
      await _seedSales(refs, now);
      await _seedEmployees(refs, now);
      await _tagInternalRows(refs);
    });
  }

  /// Tags rows created INSIDE the shipping/receipt DAOs (stock movements and
  /// shipment items) — the only demo rows whose companions we don't build
  /// ourselves. Their ids are the movement ids we generated and passed in.
  Future<void> _tagInternalRows(_Refs refs) async {
    final allMovementIds = [
      ...refs.receiptMovementIds,
      ...refs.shipMovementIds,
    ];
    if (allMovementIds.isNotEmpty) {
      await (_db.update(_db.stockMovements)
            ..where((m) => m.id.isIn(allMovementIds)))
          .write(const StockMovementsCompanion(isSample: Value(true)));
    }
    if (refs.shipMovementIds.isNotEmpty) {
      // Shipment items reuse the movement id as their primary key.
      await (_db.update(_db.saleOrderShippingItems)
            ..where((i) => i.id.isIn(refs.shipMovementIds)))
          .write(const SaleOrderShippingItemsCompanion(isSample: Value(true)));
    }
  }

  _ProductRef _product(_Refs refs, String name) =>
      refs.products.firstWhere((p) => p.name == name,
          orElse: () => throw StateError('Unknown sample product: $name'));

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

    for (final spec in <_PoSpec>[..._kPurchaseOrders, ..._generatedPurchaseOrders()]) {
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
          refs.available[l.productId] =
              (refs.available[l.productId] ?? 0) + recvQty;
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

  Future<void> _seedSales(_Refs refs, DateTime now) async {
    final orgId = _session.organizationId;
    final userId = _session.userId;

    for (final c in _kCustomers) {
      final id = _ids.newId();
      refs.customerIds.add(id);
      await _db.customerDao.insertRow(CustomersCompanion.insert(
        id: id,
        organizationId: orgId,
        name: c[0] as String,
        paymentTerms: Value(c[1] as int),
        isSample: const Value(true),
        createdAt: now,
        updatedAt: now,
      ));
    }

    for (final spec in <_SoSpec>[..._kSaleOrders, ..._generatedSaleOrders()]) {
      final orderDate = now.subtract(Duration(days: spec.daysAgo));
      final soId = _ids.newId();
      final number = await _db.documentCounterDao.next(orgId, 'sale_order', 'SO');

      final items = <SaleOrderItemsCompanion>[];
      final lineRefs = <_SoLine>[];
      var total = 0.0;
      for (final it in spec.items) {
        final p = _product(refs, it[0] as String);
        final qty = it[1] as double;
        final price = it[2] as double;
        final lineTotal = qty * price;
        total += lineTotal;
        final itemId = _ids.newId();
        items.add(SaleOrderItemsCompanion.insert(
          id: itemId,
          organizationId: orgId,
          saleOrderId: soId,
          productId: p.id,
          productName: p.name,
          quantity: qty,
          unitPrice: price,
          totalPrice: lineTotal,
          isSample: const Value(true),
          createdAt: orderDate,
          updatedAt: orderDate,
        ));
        lineRefs.add(_SoLine(itemId, p.id, qty));
      }

      await _db.saleOrderDao.createWithItems(
        SaleOrdersCompanion.insert(
          id: soId,
          organizationId: orgId,
          soNumber: number,
          customerId: refs.customerIds[spec.customerIndex],
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

      // Shipment posts stock OUT for the shipped fraction, clamped to on-hand
      // stock so a sale never oversells (which would throw and roll back).
      if (spec.shipFraction > 0) {
        final shipLines = <ShipmentLine>[];
        for (final l in lineRefs) {
          final desired = l.qty * spec.shipFraction;
          if (desired <= 0) continue;
          final avail = refs.available[l.productId] ?? 0;
          final shipQty = desired <= avail ? desired : avail;
          if (shipQty <= 0) continue;
          refs.available[l.productId] = avail - shipQty;
          final movId = _ids.newId();
          refs.shipMovementIds.add(movId);
          shipLines.add(ShipmentLine(
            saleOrderItemId: l.itemId,
            productId: l.productId,
            movementId: movId,
            quantity: shipQty,
          ));
        }
        // If nothing is on hand, leave the order as awaiting shipment.
        if (shipLines.isNotEmpty) {
          final shipDate = orderDate.add(const Duration(days: 1));
          final shipId = _ids.newId();
          final sNumber =
              await _db.documentCounterDao.next(orgId, 'so_shipping', 'SHP');
          await _db.saleOrderShippingDao.createShipment(
            shipping: SaleOrderShippingsCompanion.insert(
              id: shipId,
              organizationId: orgId,
              saleOrderId: soId,
              soShippingNumber: sNumber,
              shippingDate: shipDate,
              isSample: const Value(true),
              createdAt: shipDate,
              updatedAt: shipDate,
            ),
            lines: shipLines,
            orgId: orgId,
            createdBy: userId,
            now: shipDate,
          );
        }
      }

      // Payment (status 'completed') for the paid fraction.
      if (spec.payFraction > 0) {
        final payDate = orderDate.add(const Duration(days: 2));
        final payId = _ids.newId();
        final pNumber =
            await _db.documentCounterDao.next(orgId, 'so_payment', 'PAY');
        await _db.saleOrderPaymentDao.recordPayment(
          SaleOrderPaymentsCompanion.insert(
            id: payId,
            organizationId: orgId,
            saleOrderId: soId,
            paymentNumber: pNumber,
            amount: total * spec.payFraction,
            method: 'cash',
            status: const Value('completed'),
            paymentDate: payDate,
            isSample: const Value(true),
            createdAt: payDate,
            updatedAt: payDate,
          ),
        );
      }
    }
  }

  /// Employee attribution + piece-rate pay demo data. Inserts a handful of
  /// employees, product default pay rates plus a couple of employee overrides,
  /// several already-`completed` production orders attributed to those
  /// employees (inserted directly — NOT via [ProductionOrderDao.complete] — so
  /// no recipe/stock-consumption entanglement; see report for the tradeoff),
  /// one rate-snapshot earning per order, and employee payments chosen to show
  /// a spread of balances: partially paid (owes), paid in full (zero), unpaid
  /// (owes full), and overpaid (a negative/credit balance — overpayment is
  /// allowed).
  Future<void> _seedEmployees(_Refs refs, DateTime now) async {
    final orgId = _session.organizationId;

    final employeeIdByName = <String, String>{};
    for (final e in _kEmployees) {
      final id = _ids.newId();
      final name = e[0] as String;
      employeeIdByName[name] = id;
      await _db.employeeDao.createRow(EmployeesCompanion.insert(
        id: id,
        organizationId: orgId,
        name: name,
        phone: Value(e[1] as String),
        notes: Value(e[2] as String?),
        isSample: const Value(true),
        createdAt: now,
        updatedAt: now,
      ));
    }

    // Product default rates (employee_id null) for the output products below.
    const defaultRates = <String, double>{
      'Cordless Drill 18V': 5.0,
      'Plywood Sheet': 3.0,
      'Claw Hammer': 1.5,
      'Paint Roller Set': 2.0,
      'Adjustable Wrench': 2.5,
    };
    // Employee overrides (employeeName, productName, rate): each employee earns
    // a different per-unit rate than the product default on that product.
    const overrides = <List<Object>>[
      ['Marcus Webb', 'Cordless Drill 18V', 6.0],
      ['Priya Nair', 'Plywood Sheet', 3.5],
    ];

    for (final entry in defaultRates.entries) {
      await _db.productionPayRateDao.upsert(ProductionPayRatesCompanion.insert(
        id: _ids.newId(),
        organizationId: orgId,
        productId: _product(refs, entry.key).id,
        rate: entry.value,
        isSample: const Value(true),
        createdAt: now,
        updatedAt: now,
      ));
    }
    for (final o in overrides) {
      await _db.productionPayRateDao.upsert(ProductionPayRatesCompanion.insert(
        id: _ids.newId(),
        organizationId: orgId,
        productId: _product(refs, o[1] as String).id,
        employeeId: Value(employeeIdByName[o[0] as String]!),
        rate: o[2] as double,
        isSample: const Value(true),
        createdAt: now,
        updatedAt: now,
      ));
    }

    // The rate that applies for an (employee, product) pair: override if one
    // exists, else the product default. Keeps every earning below internally
    // consistent with the rate table just seeded.
    double resolveRate(String employeeName, String productName) {
      for (final o in overrides) {
        if (o[0] == employeeName && o[1] == productName) return o[2] as double;
      }
      return defaultRates[productName]!;
    }

    // Attributed, already-completed production orders spread across recent days.
    // (employeeName, productName, quantity, daysAgo)
    const orderSpecs = <List<Object>>[
      ['Marcus Webb', 'Cordless Drill 18V', 4.0, 5],
      ['Marcus Webb', 'Plywood Sheet', 5.0, 3],
      ['Marcus Webb', 'Claw Hammer', 8.0, 2],
      ['Priya Nair', 'Plywood Sheet', 10.0, 5],
      ['Priya Nair', 'Paint Roller Set', 6.0, 4],
      ['Priya Nair', 'Plywood Sheet', 8.0, 1],
      ['Diego Santos', 'Adjustable Wrench', 6.0, 6],
      ['Diego Santos', 'Claw Hammer', 10.0, 2],
      ['Aisha Khan', 'Paint Roller Set', 5.0, 3],
      ['Aisha Khan', 'Cordless Drill 18V', 2.0, 1],
      ['Tom Becker', 'Plywood Sheet', 4.0, 2],
    ];

    final earnedByEmployee = <String, double>{};
    for (final spec in orderSpecs) {
      final employeeName = spec[0] as String;
      final productName = spec[1] as String;
      final quantity = spec[2] as double;
      final daysAgo = spec[3] as int;
      final employeeId = employeeIdByName[employeeName]!;
      final product = _product(refs, productName);
      final rate = resolveRate(employeeName, productName);
      final amount = quantity * rate;
      earnedByEmployee[employeeId] =
          (earnedByEmployee[employeeId] ?? 0) + amount;

      final orderDate = now.subtract(Duration(days: daysAgo));
      final orderId = _ids.newId();
      final orderNumber =
          await _db.documentCounterDao.next(orgId, 'production_order', 'PRD');
      await _db.productionOrderDao.createRow(ProductionOrdersCompanion.insert(
        id: orderId,
        organizationId: orgId,
        orderNumber: orderNumber,
        productId: product.id,
        employeeId: Value(employeeId),
        quantity: quantity,
        status: const Value('completed'),
        completionDate: Value(orderDate),
        createdAt: orderDate,
        updatedAt: orderDate,
      ));

      await _db.into(_db.productionEarnings).insert(
            ProductionEarningsCompanion.insert(
              id: _ids.newId(),
              organizationId: orgId,
              productionOrderId: orderId,
              employeeId: employeeId,
              productId: product.id,
              quantity: quantity,
              rate: rate,
              amount: amount,
              isSample: const Value(true),
              createdAt: orderDate,
              updatedAt: orderDate,
            ),
          );
    }

    // Payments giving a spread of balances (earned - paid). Priya is paid in
    // full (computed from her earnings); Marcus is paid down partially (owes);
    // Aisha is overpaid (credit balance); Diego and Tom go unpaid (owe full).
    // (employeeName, amount, daysAgo)
    final payments = <List<Object>>[
      ['Marcus Webb', 25.0, 1],
      ['Priya Nair', earnedByEmployee[employeeIdByName['Priya Nair']!]!, 2],
      ['Aisha Khan', 25.0, 1],
    ];
    for (final p in payments) {
      final payDate = now.subtract(Duration(days: p[2] as int));
      final paymentNumber =
          await _db.documentCounterDao.next(orgId, 'employee_payment', 'EPAY');
      await _db.employeePaymentDao.createRow(EmployeePaymentsCompanion.insert(
        id: _ids.newId(),
        organizationId: orgId,
        employeeId: employeeIdByName[p[0] as String]!,
        paymentNumber: paymentNumber,
        amount: p[1] as double,
        paymentDate: payDate,
        isSample: const Value(true),
        createdAt: payDate,
        updatedAt: payDate,
      ));
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

  /// Running on-hand stock per product id: receipts add, shipments subtract.
  /// Used to clamp shipments so a generated sale never oversells (which would
  /// throw in the shipping DAO and roll back the whole load).
  final Map<String, double> available = {};
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

class _SoLine {
  _SoLine(this.itemId, this.productId, this.qty);
  final String itemId;
  final String productId;
  final double qty;
}

// A sale order spec.
// items: (productName, qty, unitPrice); shipFraction: 0..1; payFraction: 0..1;
// status: 'confirmed' or 'draft'; daysAgo.
class _SoSpec {
  const _SoSpec(this.customerIndex, this.items, this.shipFraction,
      this.payFraction, this.status, this.daysAgo);
  final int customerIndex;
  final List<List<Object>> items;
  final double shipFraction;
  final double payFraction;
  final String status;
  final int daysAgo;
}

const _kCustomers = <List<Object>>[
  ['Acme Builders', 30],
  ['Ridgeline Construction', 45],
  ['Hometown Hardware', 15],
  ['Walk-in Retail', 0],
  ['Meadow Renovations', 30],
];

const _kSaleOrders = <_SoSpec>[
  _SoSpec(0, [
    ['Cordless Drill 18V', 2.0, 129.0],
    ['Wood Screws 4x40', 5.0, 7.0],
    ['Safety Goggles', 6.0, 8.0],
  ], 1.0, 1.0, 'confirmed', 6),
  _SoSpec(1, [
    ['Pine Plank 2.4m', 20.0, 5.5],
    ['Plywood Sheet', 4.0, 32.0],
    ['Interior Paint 5L', 8.0, 9.0],
  ], 1.0, 0.5, 'confirmed', 18),
  _SoSpec(2, [
    ['Claw Hammer', 4.0, 16.0],
    ['Tape Measure 5m', 6.0, 9.0],
    ['Wall Plugs', 5.0, 5.0],
  ], 1.0, 0.0, 'confirmed', 14),
  _SoSpec(3, [
    ['Copper Pipe 15mm', 10.0, 7.0],
    ['PVC Elbow 32mm', 8.0, 3.0],
    ['Pipe Wrench', 1.0, 22.0],
  ], 1.0, 1.0, 'confirmed', 10),
  _SoSpec(4, [
    ['Exterior Paint 5L', 6.0, 11.0],
    ['Paint Roller Set', 3.0, 12.0],
  ], 0.5, 0.5, 'confirmed', 9),
  _SoSpec(0, [
    ['Hex Bolts M8', 8.0, 11.0],
    ['Adjustable Wrench', 2.0, 13.0],
  ], 0.0, 0.0, 'confirmed', 5),
  _SoSpec(1, [
    ['Tape Measure 5m', 4.0, 9.0],
    ['Safety Goggles', 4.0, 8.0],
  ], 1.0, 1.0, 'confirmed', 4),
  _SoSpec(3, [
    ['Cordless Drill 18V', 1.0, 129.0],
  ], 0.0, 0.0, 'draft', 2),
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

// (name, phone, notes|null) for the piece-rate pay demo.
const _kEmployees = <List<Object?>>[
  ['Marcus Webb', '555-0142', 'Senior assembler'],
  ['Priya Nair', '555-0198', 'Finishing specialist'],
  ['Diego Santos', '555-0173', null],
  ['Aisha Khan', '555-0121', 'Part-time'],
  ['Tom Becker', '555-0155', null],
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

// Index of "Tape Measure 5m" in [_kProducts]; intentionally excluded from the
// generated restocks below so it stays below its reorder point after sales.
const _kLowStockShowcaseProduct = 2;

/// Generates 10 additional purchase orders that restock the catalogue
/// generously (so the 50 generated sales have stock to draw from) with a
/// realistic spread of received/payment states. Deterministic — keyed off the
/// loop index so every load produces the same data.
List<_PoSpec> _generatedPurchaseOrders() {
  final pool = [
    for (var i = 0; i < _kProducts.length; i++)
      if (i != _kLowStockShowcaseProduct) i,
  ];
  final out = <_PoSpec>[];
  for (var i = 0; i < 10; i++) {
    final items = <List<Object>>[];
    for (var j = 0; j < 4; j++) {
      final idx = pool[(i * 4 + j) % pool.length];
      final qty = 50.0 + ((i + j) % 4) * 20; // 50..110
      items.add([_kProducts[idx][0], qty, _kProducts[idx][3]]);
    }
    final isDraft = i == 9;
    final receive = isDraft ? 0.0 : (i == 7 ? 0.6 : 1.0);
    final pay = isDraft ? 0.0 : (i % 5 < 3 ? (i.isEven ? 1.0 : 0.5) : 0.0);
    final daysAgo = 56 - i * 5; // 56..11
    out.add(_PoSpec(i % _kSuppliers.length, items, receive, pay,
        isDraft ? 'draft' : 'sent', daysAgo));
  }
  return out;
}

/// Generates 50 additional sale orders with a realistic spread of
/// shipped/awaiting/draft and paid/partial/unpaid states. Roughly 60% carry a
/// payment. Shipment quantities are clamped to on-hand stock at load time, so
/// these never oversell. Deterministic — keyed off the loop index.
List<_SoSpec> _generatedSaleOrders() {
  final out = <_SoSpec>[];
  for (var i = 0; i < 50; i++) {
    final lineCount = 1 + (i % 3); // 1..3 lines
    final items = <List<Object>>[];
    for (var j = 0; j < lineCount; j++) {
      final idx = (i * 3 + j * 5) % _kProducts.length;
      final qty = (1 + (i + j) % 4).toDouble(); // 1..4
      items.add([_kProducts[idx][0], qty, _kProducts[idx][4]]);
    }
    final isDraft = i % 13 == 12; // a few drafts
    final awaiting = !isDraft && i % 9 == 8; // a few awaiting shipment
    final ship = (isDraft || awaiting) ? 0.0 : 1.0;
    final pay = isDraft ? 0.0 : (i % 5 < 3 ? (i.isEven ? 1.0 : 0.5) : 0.0);
    final daysAgo = 1 + (i * 7) % 59; // spread across ~60 days
    out.add(_SoSpec(i % _kCustomers.length, items, ship, pay,
        isDraft ? 'draft' : 'confirmed', daysAgo));
  }
  return out;
}
