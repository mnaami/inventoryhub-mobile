import 'package:drift/drift.dart';
import '../../../../core/db/app_database.dart';
import '../domain/sale_order.dart';
import '../domain/sale_order_enums.dart';

SaleOrder toSaleOrder(SaleOrderRow r) => SaleOrder(
      id: r.id,
      organizationId: r.organizationId,
      soNumber: r.soNumber,
      customerId: r.customerId,
      orderDate: r.orderDate,
      deliveryDate: r.deliveryDate,
      status: OrderStatus.fromWire(r.status),
      paymentStatus: PaymentStatus.fromWire(r.paymentStatus),
      shippingStatus: ShippingStatus.fromWire(r.shippingStatus),
      totalAmount: r.totalAmount,
      isActive: r.isActive,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
    );

SaleOrdersCompanion saleOrderInsert(SaleOrder o) => SaleOrdersCompanion.insert(
      id: o.id,
      organizationId: o.organizationId,
      soNumber: o.soNumber,
      customerId: o.customerId,
      orderDate: o.orderDate,
      deliveryDate: Value(o.deliveryDate),
      status: Value(o.status.wire),
      paymentStatus: Value(o.paymentStatus.wire),
      shippingStatus: Value(o.shippingStatus.wire),
      totalAmount: Value(o.totalAmount),
      isActive: Value(o.isActive),
      createdAt: o.createdAt,
      updatedAt: o.updatedAt,
    );

SaleOrderItem toSaleOrderItem(SaleOrderItemRow r) => SaleOrderItem(
      id: r.id,
      organizationId: r.organizationId,
      saleOrderId: r.saleOrderId,
      productId: r.productId,
      productName: r.productName,
      quantity: r.quantity,
      unitPrice: r.unitPrice,
      totalPrice: r.totalPrice,
      shippedQuantity: r.shippedQuantity,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
    );

SaleOrderItemsCompanion saleOrderItemInsert(SaleOrderItem i) =>
    SaleOrderItemsCompanion.insert(
      id: i.id,
      organizationId: i.organizationId,
      saleOrderId: i.saleOrderId,
      productId: i.productId,
      productName: i.productName,
      quantity: i.quantity,
      unitPrice: i.unitPrice,
      totalPrice: i.totalPrice,
      shippedQuantity: Value(i.shippedQuantity),
      createdAt: i.createdAt,
      updatedAt: i.updatedAt,
    );

SaleOrderPayment toSaleOrderPayment(SaleOrderPaymentRow r) => SaleOrderPayment(
      id: r.id,
      organizationId: r.organizationId,
      saleOrderId: r.saleOrderId,
      paymentNumber: r.paymentNumber,
      amount: r.amount,
      method: PaymentMethod.fromWire(r.method),
      status: PaymentRecordStatus.fromWire(r.status),
      paymentDate: r.paymentDate,
      isActive: r.isActive,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
    );

SalePaymentListItem toSalePaymentListItem(
  SaleOrderPaymentRow r, {
  required String soNumber,
  required String customerId,
}) =>
    SalePaymentListItem(
      id: r.id,
      organizationId: r.organizationId,
      saleOrderId: r.saleOrderId,
      paymentNumber: r.paymentNumber,
      amount: r.amount,
      method: PaymentMethod.fromWire(r.method),
      status: PaymentRecordStatus.fromWire(r.status),
      paymentDate: r.paymentDate,
      isActive: r.isActive,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
      soNumber: soNumber,
      customerId: customerId,
    );

SaleOrderPaymentsCompanion saleOrderPaymentInsert(SaleOrderPayment p) =>
    SaleOrderPaymentsCompanion.insert(
      id: p.id,
      organizationId: p.organizationId,
      saleOrderId: p.saleOrderId,
      paymentNumber: p.paymentNumber,
      amount: p.amount,
      method: p.method.wire,
      status: Value(p.status.wire),
      paymentDate: p.paymentDate,
      isActive: Value(p.isActive),
      createdAt: p.createdAt,
      updatedAt: p.updatedAt,
    );

SaleOrderShipping toSaleOrderShipping(SaleOrderShippingRow r) =>
    SaleOrderShipping(
      id: r.id,
      organizationId: r.organizationId,
      saleOrderId: r.saleOrderId,
      soShippingNumber: r.soShippingNumber,
      shippingDate: r.shippingDate,
      carrier: r.carrier,
      trackingNumber: r.trackingNumber,
      status: ShipmentStatus.fromWire(r.status),
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
    );

SaleShipmentListItem toSaleShipmentListItem(
  SaleOrderShippingRow r, {
  required String soNumber,
  required String customerId,
}) =>
    SaleShipmentListItem(
      id: r.id,
      organizationId: r.organizationId,
      saleOrderId: r.saleOrderId,
      soShippingNumber: r.soShippingNumber,
      shippingDate: r.shippingDate,
      carrier: r.carrier,
      trackingNumber: r.trackingNumber,
      status: ShipmentStatus.fromWire(r.status),
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
      soNumber: soNumber,
      customerId: customerId,
    );

SaleOrderShippingsCompanion saleOrderShippingInsert(SaleOrderShipping s) =>
    SaleOrderShippingsCompanion.insert(
      id: s.id,
      organizationId: s.organizationId,
      saleOrderId: s.saleOrderId,
      soShippingNumber: s.soShippingNumber,
      shippingDate: s.shippingDate,
      carrier: Value(s.carrier),
      trackingNumber: Value(s.trackingNumber),
      status: Value(s.status.wire),
      createdAt: s.createdAt,
      updatedAt: s.updatedAt,
    );

SaleOrderShippingItem toSaleOrderShippingItem(SaleOrderShippingItemRow r) =>
    SaleOrderShippingItem(
      id: r.id,
      organizationId: r.organizationId,
      shippingId: r.shippingId,
      saleOrderItemId: r.saleOrderItemId,
      productId: r.productId,
      quantity: r.quantity,
      createdAt: r.createdAt,
    );

SaleOrderShippingItemsCompanion saleOrderShippingItemInsert(
        SaleOrderShippingItem i) =>
    SaleOrderShippingItemsCompanion.insert(
      id: i.id,
      organizationId: i.organizationId,
      shippingId: i.shippingId,
      saleOrderItemId: i.saleOrderItemId,
      productId: i.productId,
      quantity: i.quantity,
      createdAt: i.createdAt,
    );
