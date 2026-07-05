import 'package:freezed_annotation/freezed_annotation.dart';
import 'sale_order_enums.dart';
part 'sale_order.freezed.dart';

@freezed
abstract class SaleOrder with _$SaleOrder {
  const SaleOrder._();
  const factory SaleOrder({
    required String id,
    required String organizationId,
    required String soNumber,
    required String customerId,
    required DateTime orderDate,
    DateTime? deliveryDate,
    required OrderStatus status,
    required PaymentStatus paymentStatus,
    required ShippingStatus shippingStatus,
    required double totalAmount,
    required bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _SaleOrder;

  bool get isDraft => status == OrderStatus.draft;
  bool get isCancelled => status == OrderStatus.cancelled;
}

@freezed
abstract class SaleOrderItem with _$SaleOrderItem {
  const SaleOrderItem._();
  const factory SaleOrderItem({
    required String id,
    required String organizationId,
    required String saleOrderId,
    required String productId,
    required String productName,
    required double quantity,
    required double unitPrice,
    required double totalPrice,
    required double shippedQuantity,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _SaleOrderItem;

  double get remainingQuantity => quantity - shippedQuantity;
}

@freezed
abstract class SaleOrderPayment with _$SaleOrderPayment {
  const factory SaleOrderPayment({
    required String id,
    required String organizationId,
    required String saleOrderId,
    required String paymentNumber,
    required double amount,
    required PaymentMethod method,
    required PaymentRecordStatus status,
    required DateTime paymentDate,
    required bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _SaleOrderPayment;
}

@freezed
abstract class SaleOrderShipping with _$SaleOrderShipping {
  const factory SaleOrderShipping({
    required String id,
    required String organizationId,
    required String saleOrderId,
    required String soShippingNumber,
    required DateTime shippingDate,
    String? carrier,
    String? trackingNumber,
    required ShipmentStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _SaleOrderShipping;
}

@freezed
abstract class SaleOrderShippingItem with _$SaleOrderShippingItem {
  const factory SaleOrderShippingItem({
    required String id,
    required String organizationId,
    required String shippingId,
    required String saleOrderItemId,
    required String productId,
    required double quantity,
    required DateTime createdAt,
  }) = _SaleOrderShippingItem;
}

@freezed
abstract class SalePaymentListItem with _$SalePaymentListItem {
  const factory SalePaymentListItem({
    required String id,
    required String organizationId,
    required String saleOrderId,
    required String paymentNumber,
    required double amount,
    required PaymentMethod method,
    required PaymentRecordStatus status,
    required DateTime paymentDate,
    required bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String soNumber,
    required String customerId,
  }) = _SalePaymentListItem;
}
