import 'package:freezed_annotation/freezed_annotation.dart';
import 'purchase_order_enums.dart';
part 'purchase_order.freezed.dart';

@freezed
abstract class PurchaseOrder with _$PurchaseOrder {
  const PurchaseOrder._();
  const factory PurchaseOrder({
    required String id,
    required String organizationId,
    required String orderNumber,
    required String supplierId,
    required DateTime orderDate,
    DateTime? expectedDeliveryDate,
    required PurchaseOrderStatus status,
    required PaymentStatus paymentStatus,
    required ReceiptStatus receiptStatus,
    required double totalAmount,
    required bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _PurchaseOrder;

  bool get isDraft => status == PurchaseOrderStatus.draft;
  bool get isCancelled => status == PurchaseOrderStatus.cancelled;
}

@freezed
abstract class PurchaseOrderItem with _$PurchaseOrderItem {
  const PurchaseOrderItem._();
  const factory PurchaseOrderItem({
    required String id,
    required String organizationId,
    required String purchaseOrderId,
    required String productId,
    required String productName,
    required double quantity,
    required double unitPrice,
    required double totalPrice,
    required double receivedQuantity,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _PurchaseOrderItem;

  double get remainingQuantity => quantity - receivedQuantity;
}

@freezed
abstract class PurchaseOrderReceipt with _$PurchaseOrderReceipt {
  const factory PurchaseOrderReceipt({
    required String id,
    required String organizationId,
    required String purchaseOrderId,
    required String receiptNumber,
    required DateTime receiptDate,
    required ReceiptDocStatus status,
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _PurchaseOrderReceipt;
}

@freezed
abstract class PurchaseOrderReceiptItem with _$PurchaseOrderReceiptItem {
  const factory PurchaseOrderReceiptItem({
    required String id,
    required String organizationId,
    required String receiptId,
    required String purchaseOrderItemId,
    required String productId,
    required double quantity,
    required DateTime createdAt,
  }) = _PurchaseOrderReceiptItem;
}

@freezed
abstract class PurchaseOrderPayment with _$PurchaseOrderPayment {
  const factory PurchaseOrderPayment({
    required String id,
    required String organizationId,
    required String purchaseOrderId,
    required String paymentNumber,
    required double amount,
    required PaymentMethod method,
    required PaymentDocStatus status,
    required DateTime paymentDate,
    required bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _PurchaseOrderPayment;
}
