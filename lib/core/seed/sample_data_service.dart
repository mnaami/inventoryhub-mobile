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
    // Implemented in later tasks.
    throw UnimplementedError('load() is implemented in Tasks 3-6');
  }
}
