import 'package:drift/drift.dart';
import '../../../../core/db/app_database.dart';
import '../../../../core/result/app_exception.dart';
import '../../../inventory/product/data/product_table.dart';
import '../../../inventory/stock_movement/data/stock_movement_table.dart';
import 'purchase_order_tables.dart';

part 'purchase_order_receipt_dao.g.dart';

@DriftAccessor(tables: [
  PurchaseOrderReceipts,
  PurchaseOrderReceiptItems,
  PurchaseOrderItems,
  PurchaseOrders,
  Products,
  StockMovements,
])
class PurchaseOrderReceiptDao extends DatabaseAccessor<AppDatabase>
    with _$PurchaseOrderReceiptDaoMixin {
  PurchaseOrderReceiptDao(super.db);

  Future<List<PurchaseOrderReceiptRow>> receiptsFor(String purchaseOrderId) {
    return (select(purchaseOrderReceipts)
          ..where((r) => r.purchaseOrderId.equals(purchaseOrderId))
          ..orderBy([(r) => OrderingTerm(expression: r.createdAt)]))
        .get();
  }

  Future<List<PurchaseOrderReceiptItemRow>> receiptItemsFor(String receiptId) {
    return (select(purchaseOrderReceiptItems)
          ..where((i) => i.receiptId.equals(receiptId)))
        .get();
  }

  /// Resolves the parent purchase order id for a receipt, or null if the
  /// receipt no longer exists. Used to navigate from a stock movement back to
  /// its source order.
  Future<String?> purchaseOrderIdFor(String receiptId) async {
    final row = await (select(purchaseOrderReceipts)
          ..where((r) => r.id.equals(receiptId)))
        .getSingleOrNull();
    return row?.purchaseOrderId;
  }

  Future<void> createReceipt({
    required PurchaseOrderReceiptsCompanion receipt,
    required List<PurchaseOrderReceiptItemsCompanion> items,
  }) {
    return transaction(() async {
      await into(purchaseOrderReceipts).insert(receipt);
      for (final it in items) {
        await into(purchaseOrderReceiptItems).insert(it);
      }
    });
  }

  Future<void> cancelDraft(String receiptId, DateTime now) {
    return (update(purchaseOrderReceipts)..where((r) => r.id.equals(receiptId)))
        .write(PurchaseOrderReceiptsCompanion(
            status: const Value('cancelled'), updatedAt: Value(now)));
  }

  /// Posts a draft receipt: validates over-receipt (aggregated per PO line),
  /// issues `in` stock via the ledger, bumps received_quantity, marks the
  /// receipt posted, and recomputes receipt_status. One transaction.
  Future<void> post({
    required String receiptId,
    required Map<String, String> movementIdByReceiptItem,
    required String createdBy,
    required DateTime now,
  }) {
    return transaction(() async {
      final receipt = await (select(purchaseOrderReceipts)
            ..where((r) => r.id.equals(receiptId)))
          .getSingle();
      final purchaseOrderId = receipt.purchaseOrderId;
      final items = await (select(purchaseOrderReceiptItems)
            ..where((i) => i.receiptId.equals(receiptId)))
          .get();

      // 1. Validate over-receipt, aggregated per PO line.
      final byPoItem = <String, double>{};
      for (final it in items) {
        byPoItem[it.purchaseOrderItemId] =
            (byPoItem[it.purchaseOrderItemId] ?? 0) + it.quantity;
      }
      for (final entry in byPoItem.entries) {
        final poItem = await (select(purchaseOrderItems)
              ..where((p) => p.id.equals(entry.key)))
            .getSingleOrNull();
        if (poItem == null) {
          throw const NotFoundException('Purchase-order line not found for receipt.');
        }
        if (poItem.receivedQuantity + entry.value > poItem.quantity) {
          throw ConflictException(
              'Over-receipt for ${poItem.productName}: ordered ${poItem.quantity}, already ${poItem.receivedQuantity}, receiving ${entry.value}.');
        }
      }

      // 2. Issue `in` stock via the slice-1 ledger + bump received_quantity.
      for (final it in items) {
        await attachedDatabase.stockMovementDao.record(
          StockMovementsCompanion.insert(
            id: movementIdByReceiptItem[it.id]!,
            organizationId: it.organizationId,
            productId: it.productId,
            movementType: 'in',
            quantity: it.quantity,
            referenceType: const Value('purchase_order_receipt'),
            referenceId: Value(receiptId),
            createdBy: createdBy,
            createdAt: now,
          ),
          productId: it.productId,
          delta: it.quantity,
        );
        final poItem = await (select(purchaseOrderItems)
              ..where((p) => p.id.equals(it.purchaseOrderItemId)))
            .getSingle();
        await (update(purchaseOrderItems)
              ..where((p) => p.id.equals(it.purchaseOrderItemId)))
            .write(PurchaseOrderItemsCompanion(
          receivedQuantity: Value(poItem.receivedQuantity + it.quantity),
          updatedAt: Value(now),
        ));
      }

      // 3. Mark the receipt posted.
      await (update(purchaseOrderReceipts)..where((r) => r.id.equals(receiptId)))
          .write(PurchaseOrderReceiptsCompanion(
              status: const Value('posted'), updatedAt: Value(now)));

      // 4. Recompute receipt_status across ALL the order's items.
      await _recalcReceipt(purchaseOrderId, now);
    });
  }

  Future<void> _recalcReceipt(String purchaseOrderId, DateTime now) async {
    final items = await (select(purchaseOrderItems)
          ..where((i) => i.purchaseOrderId.equals(purchaseOrderId)))
        .get();
    final ordered = items.fold<double>(0, (a, i) => a + i.quantity);
    final received = items.fold<double>(0, (a, i) => a + i.receivedQuantity);
    final status = received <= 0
        ? 'not_received'
        : (received >= ordered ? 'fully_received' : 'partial');
    final order = await (select(purchaseOrders)
          ..where((o) => o.id.equals(purchaseOrderId)))
        .getSingle();
    final orderStatus = status == 'fully_received' &&
            (order.status == 'sent' || order.status == 'confirmed')
        ? 'received'
        : order.status;
    await (update(purchaseOrders)..where((o) => o.id.equals(purchaseOrderId)))
        .write(PurchaseOrdersCompanion(
            receiptStatus: Value(status),
            status: Value(orderStatus),
            updatedAt: Value(now)));
  }
}
