import '../domain/purchase_order.dart';
import '../domain/purchase_order_enums.dart';
import '../domain/purchase_order_repository.dart';
import '../../../sales/sale_order/data/document_counter_dao.dart';
import 'purchase_order_dao.dart';
import 'purchase_order_mappers.dart';
import 'purchase_order_payment_dao.dart';
import 'purchase_order_receipt_dao.dart';

class PurchaseOrderRepositoryImpl implements PurchaseOrderRepository {
  PurchaseOrderRepositoryImpl(
      this._orders, this._receipts, this._payments, this._counters);
  final PurchaseOrderDao _orders;
  final PurchaseOrderReceiptDao _receipts;
  final PurchaseOrderPaymentDao _payments;
  final DocumentCounterDao _counters;

  @override
  Future<String> nextNumber(String orgId, String entityType, String prefix) =>
      _counters.next(orgId, entityType, prefix);

  @override
  Future<void> createOrder(PurchaseOrder order, List<PurchaseOrderItem> items) =>
      _orders.createWithItems(
          purchaseOrderInsert(order), items.map(purchaseOrderItemInsert).toList());

  @override
  Future<void> replaceDraftItems(
          String orderId, List<PurchaseOrderItem> items, double totalAmount) =>
      _orders.replaceItems(orderId, items.map(purchaseOrderItemInsert).toList(),
          totalAmount: totalAmount, now: DateTime.now().toUtc());

  @override
  Future<PurchaseOrder?> getOrder(String id) async {
    final r = await _orders.byId(id);
    return r == null ? null : toPurchaseOrder(r);
  }

  @override
  Future<List<PurchaseOrderItem>> itemsFor(String orderId) async =>
      (await _orders.itemsFor(orderId)).map(toPurchaseOrderItem).toList();

  @override
  Future<List<PurchaseOrder>> listOrders(String orgId,
          {PurchaseOrderStatus? status,
          String? supplierId,
          required int limit,
          required int offset}) async =>
      (await _orders.paged(orgId,
              status: status?.wire,
              supplierId: supplierId,
              limit: limit,
              offset: offset))
          .map(toPurchaseOrder)
          .toList();

  @override
  Future<void> setStatus(String id, PurchaseOrderStatus status) =>
      _orders.setStatus(id, status.wire, DateTime.now().toUtc());

  @override
  Future<void> softDeleteOrder(String id) =>
      _orders.softDelete(id, DateTime.now().toUtc());

  @override
  Future<int> countLiveForSupplier(String orgId, String supplierId) =>
      _orders.countLiveForSupplier(orgId, supplierId);

  @override
  Future<int> countOpenOrders(String orgId) => _orders.countByStatuses(
      orgId, const ['draft', 'sent', 'confirmed']);

  @override
  Future<int> countUnreceived(String orgId) => _orders.countUnreceived(orgId);

  @override
  Future<double> outstandingPayable(String orgId) async {
    final total = await _orders.ordersTotal(orgId);
    final paid = await _payments.postedTotalForOrg(orgId);
    return total - paid;
  }

  @override
  Future<void> createDraftPayment(PurchaseOrderPayment payment) =>
      _payments.createDraft(purchaseOrderPaymentInsert(payment));

  @override
  Future<void> editDraftPayment(String paymentId,
          {required double amount,
          required PaymentMethod method,
          required DateTime paymentDate}) =>
      _payments.editDraft(paymentId,
          amount: amount,
          method: method.wire,
          paymentDate: paymentDate,
          now: DateTime.now().toUtc());

  @override
  Future<void> cancelDraftPayment(String paymentId) =>
      _payments.cancelDraft(paymentId, DateTime.now().toUtc());

  @override
  Future<void> postPayment(String paymentId) =>
      _payments.post(paymentId, DateTime.now().toUtc());

  @override
  Future<List<PurchaseOrderPayment>> paymentsFor(String orderId) async =>
      (await _payments.paymentsFor(orderId)).map(toPurchaseOrderPayment).toList();

  @override
  Future<double> postedTotal(String orderId) => _payments.postedTotal(orderId);

  @override
  Future<void> createReceipt(
          PurchaseOrderReceipt receipt, List<PurchaseOrderReceiptItem> items) =>
      _receipts.createReceipt(
        receipt: purchaseOrderReceiptInsert(receipt),
        items: items.map(purchaseOrderReceiptItemInsert).toList(),
      );

  @override
  Future<void> cancelDraftReceipt(String receiptId) =>
      _receipts.cancelDraft(receiptId, DateTime.now().toUtc());

  @override
  Future<void> postReceipt(String receiptId,
          Map<String, String> movementIdByReceiptItem, String createdBy) =>
      _receipts.post(
        receiptId: receiptId,
        movementIdByReceiptItem: movementIdByReceiptItem,
        createdBy: createdBy,
        now: DateTime.now().toUtc(),
      );

  @override
  Future<List<PurchaseOrderReceipt>> receiptsFor(String orderId) async =>
      (await _receipts.receiptsFor(orderId)).map(toPurchaseOrderReceipt).toList();

  @override
  Future<List<PurchaseOrderReceiptItem>> receiptItemsFor(String receiptId) async =>
      (await _receipts.receiptItemsFor(receiptId))
          .map(toPurchaseOrderReceiptItem)
          .toList();
}
