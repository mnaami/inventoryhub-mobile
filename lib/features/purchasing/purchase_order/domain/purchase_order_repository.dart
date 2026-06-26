import 'purchase_order.dart';
import 'purchase_order_enums.dart';

abstract interface class PurchaseOrderRepository {
  Future<String> nextNumber(String orgId, String entityType, String prefix);

  Future<void> createOrder(PurchaseOrder order, List<PurchaseOrderItem> items);
  Future<void> replaceDraftItems(
      String orderId, List<PurchaseOrderItem> items, double totalAmount);
  Future<PurchaseOrder?> getOrder(String id);
  Future<List<PurchaseOrderItem>> itemsFor(String orderId);
  Future<List<PurchaseOrder>> listOrders(String orgId,
      {PurchaseOrderStatus? status,
      String? supplierId,
      required int limit,
      required int offset});
  Future<void> setStatus(String id, PurchaseOrderStatus status);
  Future<void> softDeleteOrder(String id);
  Future<int> countLiveForSupplier(String orgId, String supplierId);

  Future<void> createDraftPayment(PurchaseOrderPayment payment);
  Future<void> editDraftPayment(String paymentId,
      {required double amount,
      required PaymentMethod method,
      required DateTime paymentDate});
  Future<void> cancelDraftPayment(String paymentId);
  Future<void> postPayment(String paymentId);
  Future<List<PurchaseOrderPayment>> paymentsFor(String orderId);
  Future<double> postedTotal(String orderId);

  Future<void> createReceipt(
      PurchaseOrderReceipt receipt, List<PurchaseOrderReceiptItem> items);
  Future<void> cancelDraftReceipt(String receiptId);
  Future<void> postReceipt(String receiptId,
      Map<String, String> movementIdByReceiptItem, String createdBy);
  Future<List<PurchaseOrderReceipt>> receiptsFor(String orderId);
  Future<List<PurchaseOrderReceiptItem>> receiptItemsFor(String receiptId);
}
