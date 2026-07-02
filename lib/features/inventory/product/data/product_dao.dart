import 'package:drift/drift.dart';
import '../../../../core/db/app_database.dart';
import 'product_table.dart';

part 'product_dao.g.dart';

@DriftAccessor(tables: [Products])
class ProductDao extends DatabaseAccessor<AppDatabase> with _$ProductDaoMixin {
  ProductDao(super.db);

  Future<List<ProductRow>> paged(
    String orgId, {
    required int limit,
    required int offset,
    String? query,
    bool? lowStock,
    bool? outOfStock,
    String? categoryId,
  }) {
    final q = select(products)
      ..where((p) {
        Expression<bool> expr = p.organizationId.equals(orgId) & p.isActive.equals(true);
        if (query != null && query.trim().isNotEmpty) {
          final like = '%${query.trim()}%';
          expr = expr & (p.name.like(like) | p.barcode.like(like));
        }
        if (lowStock == true) {
          expr = expr & p.minimumStock.isBiggerThanValue(0) & p.currentStock.isSmallerOrEqual(p.minimumStock);
        }
        if (outOfStock == true) {
          expr = expr & p.currentStock.isSmallerOrEqualValue(0);
        }
        if (categoryId != null) {
          expr = expr & p.categoryId.equals(categoryId);
        }
        return expr;
      })
      ..orderBy([(p) => OrderingTerm(expression: p.name)])
      ..limit(limit, offset: offset);
    return q.get();
  }

  Future<int> countProducts(String orgId, {required bool onlyActive}) async {
    final c = countAll();
    final query = selectOnly(products)
      ..addColumns([c])
      ..where(products.organizationId.equals(orgId) &
          (onlyActive ? products.isActive.equals(true) : const Constant(true)));
    final row = await query.getSingle();
    return row.read(c) ?? 0;
  }

  Future<double> totalStockValue(String orgId) async {
    final val = products.currentStock * products.purchasePrice;
    final query = selectOnly(products)
      ..addColumns([val.sum()])
      ..where(products.organizationId.equals(orgId) & products.isActive.equals(true));
    final row = await query.getSingle();
    return row.read(val.sum()) ?? 0.0;
  }

  Future<List<ProductRow>> search(String orgId, String query) {
    final like = '%$query%';
    return (select(products)
          ..where((p) =>
              p.organizationId.equals(orgId) &
              p.isActive.equals(true) &
              (p.name.like(like) | p.barcode.like(like)))
          ..orderBy([(p) => OrderingTerm(expression: p.name)]))
        .get();
  }

  Future<ProductRow?> byId(String id) =>
      (select(products)..where((p) => p.id.equals(id))).getSingleOrNull();

  Future<ProductRow?> byBarcode(String orgId, String barcode) {
    return (select(products)
          ..where((p) =>
              p.organizationId.equals(orgId) &
              p.isActive.equals(true) &
              p.barcode.equals(barcode)))
        .getSingleOrNull();
  }

  Future<List<ProductRow>> lowStock(String orgId) {
    return (select(products)
          ..where((p) =>
              p.organizationId.equals(orgId) &
              p.isActive.equals(true) &
              p.minimumStock.isBiggerThanValue(0) &
              p.currentStock.isSmallerOrEqual(p.minimumStock)))
        .get();
  }

  Future<List<ProductRow>> outOfStock(String orgId) {
    return (select(products)
          ..where((p) =>
              p.organizationId.equals(orgId) &
              p.isActive.equals(true) &
              p.currentStock.isSmallerOrEqualValue(0)))
        .get();
  }

  Future<int> countActiveByCategory(String orgId, String categoryId) async {
    final c = countAll();
    final q = selectOnly(products)
      ..addColumns([c])
      ..where(products.organizationId.equals(orgId) &
          products.isActive.equals(true) &
          products.categoryId.equals(categoryId));
    final row = await q.getSingle();
    return row.read(c) ?? 0;
  }

  Future<void> insertRow(ProductsCompanion c) => into(products).insert(c);

  Future<void> updateRow(ProductsCompanion c) =>
      (update(products)..where((t) => t.id.equals(c.id.value))).write(c);

  Future<void> softDelete(String id, DateTime now) {
    return (update(products)..where((t) => t.id.equals(id))).write(
      ProductsCompanion(isActive: const Value(false), updatedAt: Value(now)),
    );
  }
}
