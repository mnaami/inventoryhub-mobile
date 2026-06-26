import 'package:drift/drift.dart';
import '../../../../core/db/app_database.dart';
import '../../../../core/result/app_exception.dart';
import '../../../inventory/product/data/product_table.dart';
import '../../../inventory/stock_movement/data/stock_movement_table.dart';
import 'sale_order_tables.dart';

part 'sale_order_shipping_dao.g.dart';

class ShipmentLine {
  const ShipmentLine({
    required this.saleOrderItemId,
    required this.productId,
    required this.movementId,
    required this.quantity,
  });
  final String saleOrderItemId;
  final String productId;
  final String movementId;
  final double quantity;
}

@DriftAccessor(tables: [
  SaleOrderShippings,
  SaleOrderShippingItems,
  SaleOrderItems,
  SaleOrders,
  Products,
  StockMovements,
])
class SaleOrderShippingDao extends DatabaseAccessor<AppDatabase>
    with _$SaleOrderShippingDaoMixin {
  SaleOrderShippingDao(super.db);

  Future<List<SaleOrderShippingRow>> shipmentsFor(String saleOrderId) {
    return (select(saleOrderShippings)
          ..where((s) => s.saleOrderId.equals(saleOrderId))
          ..orderBy([(s) => OrderingTerm(expression: s.createdAt)]))
        .get();
  }

  Future<List<SaleOrderShippingItemRow>> shippingItemsFor(String shippingId) {
    return (select(saleOrderShippingItems)
          ..where((i) => i.shippingId.equals(shippingId)))
        .get();
  }

  Future<void> createShipment({
    required SaleOrderShippingsCompanion shipping,
    required List<ShipmentLine> lines,
    required String orgId,
    required String createdBy,
    required DateTime now,
  }) {
    final shippingId = shipping.id.value;
    final saleOrderId = shipping.saleOrderId.value;
    return transaction(() async {
      // 1. Validate availability up front — block oversell.
      for (final line in lines) {
        final product = await (select(products)
              ..where((p) => p.id.equals(line.productId)))
            .getSingleOrNull();
        if (product == null) {
          throw const NotFoundException('Product not found for shipment.');
        }
        if (line.quantity > product.currentStock) {
          throw ConflictException(
              'Insufficient stock for ${product.name}: have ${product.currentStock}, need ${line.quantity}.');
        }
      }

      // 2. Insert the shipment header + items.
      await into(saleOrderShippings).insert(shipping);
      for (final line in lines) {
        await into(saleOrderShippingItems).insert(
          SaleOrderShippingItemsCompanion.insert(
            id: line.movementId, // reuse the same uuid for the join row id
            organizationId: orgId,
            shippingId: shippingId,
            saleOrderItemId: line.saleOrderItemId,
            productId: line.productId,
            quantity: line.quantity,
            createdAt: now,
          ),
        );
      }

      // 3. Issue stock via the slice-1 ledger primitive + bump shipped_quantity.
      for (final line in lines) {
        await attachedDatabase.stockMovementDao.record(
          StockMovementsCompanion.insert(
            id: line.movementId,
            organizationId: orgId,
            productId: line.productId,
            movementType: 'out',
            quantity: -line.quantity,
            referenceType: const Value('sale_order_shipping'),
            referenceId: Value(shippingId),
            createdBy: createdBy,
            createdAt: now,
          ),
          productId: line.productId,
          delta: -line.quantity,
        );
        final item = await (select(saleOrderItems)
              ..where((i) => i.id.equals(line.saleOrderItemId)))
            .getSingle();
        await (update(saleOrderItems)
              ..where((i) => i.id.equals(line.saleOrderItemId)))
            .write(SaleOrderItemsCompanion(
          shippedQuantity: Value(item.shippedQuantity + line.quantity),
          updatedAt: Value(now),
        ));
      }

      // 4. Recompute shipping_status across ALL the order's items.
      await _recalcShipping(saleOrderId, now);
    });
  }

  Future<void> setStatus(String shippingId, String status, DateTime now) {
    return transaction(() async {
      final shipment = await (select(saleOrderShippings)
            ..where((s) => s.id.equals(shippingId)))
          .getSingle();
      await (update(saleOrderShippings)..where((s) => s.id.equals(shippingId)))
          .write(SaleOrderShippingsCompanion(
              status: Value(status), updatedAt: Value(now)));
      if (status == 'delivered') {
        await (update(saleOrders)
              ..where((o) => o.id.equals(shipment.saleOrderId)))
            .write(SaleOrdersCompanion(
                status: const Value('delivered'), updatedAt: Value(now)));
      }
    });
  }

  Future<void> _recalcShipping(String saleOrderId, DateTime now) async {
    final items = await (select(saleOrderItems)
          ..where((i) => i.saleOrderId.equals(saleOrderId)))
        .get();
    final ordered = items.fold<double>(0, (a, i) => a + i.quantity);
    final shipped = items.fold<double>(0, (a, i) => a + i.shippedQuantity);
    final status = shipped <= 0
        ? 'not_shipped'
        : (shipped >= ordered ? 'fully_shipped' : 'partially_shipped');
    final order = await (select(saleOrders)
          ..where((o) => o.id.equals(saleOrderId)))
        .getSingle();
    final orderStatus =
        status == 'fully_shipped' && order.status == 'processing'
            ? 'shipped'
            : order.status;
    await (update(saleOrders)..where((o) => o.id.equals(saleOrderId))).write(
      SaleOrdersCompanion(
          shippingStatus: Value(status),
          status: Value(orderStatus),
          updatedAt: Value(now)),
    );
  }
}
