import 'package:drift/drift.dart';
import '../../../../core/db/app_database.dart';
import '../domain/purchase_order.dart';
import '../domain/purchase_order_enums.dart';

PurchaseOrder toPurchaseOrder(PurchaseOrderRow r) => PurchaseOrder(
      id: r.id,
      organizationId: r.organizationId,
      orderNumber: r.orderNumber,
      supplierId: r.supplierId,
      orderDate: r.orderDate,
      expectedDeliveryDate: r.expectedDeliveryDate,
      status: PurchaseOrderStatus.fromWire(r.status),
      paymentStatus: PaymentStatus.fromWire(r.paymentStatus),
      receiptStatus: ReceiptStatus.fromWire(r.receiptStatus),
      totalAmount: r.totalAmount,
      isActive: r.isActive,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
    );

PurchaseOrdersCompanion purchaseOrderInsert(PurchaseOrder o) =>
    PurchaseOrdersCompanion.insert(
      id: o.id,
      organizationId: o.organizationId,
      orderNumber: o.orderNumber,
      supplierId: o.supplierId,
      orderDate: o.orderDate,
      expectedDeliveryDate: Value(o.expectedDeliveryDate),
      status: Value(o.status.wire),
      paymentStatus: Value(o.paymentStatus.wire),
      receiptStatus: Value(o.receiptStatus.wire),
      totalAmount: Value(o.totalAmount),
      isActive: Value(o.isActive),
      createdAt: o.createdAt,
      updatedAt: o.updatedAt,
    );

PurchaseOrderItem toPurchaseOrderItem(PurchaseOrderItemRow r) =>
    PurchaseOrderItem(
      id: r.id,
      organizationId: r.organizationId,
      purchaseOrderId: r.purchaseOrderId,
      productId: r.productId,
      productName: r.productName,
      quantity: r.quantity,
      unitPrice: r.unitPrice,
      totalPrice: r.totalPrice,
      receivedQuantity: r.receivedQuantity,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
    );

PurchaseOrderItemsCompanion purchaseOrderItemInsert(PurchaseOrderItem i) =>
    PurchaseOrderItemsCompanion.insert(
      id: i.id,
      organizationId: i.organizationId,
      purchaseOrderId: i.purchaseOrderId,
      productId: i.productId,
      productName: i.productName,
      quantity: i.quantity,
      unitPrice: i.unitPrice,
      totalPrice: i.totalPrice,
      receivedQuantity: Value(i.receivedQuantity),
      createdAt: i.createdAt,
      updatedAt: i.updatedAt,
    );

PurchaseOrderReceipt toPurchaseOrderReceipt(PurchaseOrderReceiptRow r) =>
    PurchaseOrderReceipt(
      id: r.id,
      organizationId: r.organizationId,
      purchaseOrderId: r.purchaseOrderId,
      receiptNumber: r.receiptNumber,
      receiptDate: r.receiptDate,
      status: ReceiptDocStatus.fromWire(r.status),
      notes: r.notes,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
    );

PurchaseOrderReceiptsCompanion purchaseOrderReceiptInsert(
        PurchaseOrderReceipt r) =>
    PurchaseOrderReceiptsCompanion.insert(
      id: r.id,
      organizationId: r.organizationId,
      purchaseOrderId: r.purchaseOrderId,
      receiptNumber: r.receiptNumber,
      receiptDate: r.receiptDate,
      status: Value(r.status.wire),
      notes: Value(r.notes),
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
    );

PurchaseOrderReceiptItem toPurchaseOrderReceiptItem(
        PurchaseOrderReceiptItemRow r) =>
    PurchaseOrderReceiptItem(
      id: r.id,
      organizationId: r.organizationId,
      receiptId: r.receiptId,
      purchaseOrderItemId: r.purchaseOrderItemId,
      productId: r.productId,
      quantity: r.quantity,
      createdAt: r.createdAt,
    );

PurchaseOrderReceiptItemsCompanion purchaseOrderReceiptItemInsert(
        PurchaseOrderReceiptItem i) =>
    PurchaseOrderReceiptItemsCompanion.insert(
      id: i.id,
      organizationId: i.organizationId,
      receiptId: i.receiptId,
      purchaseOrderItemId: i.purchaseOrderItemId,
      productId: i.productId,
      quantity: i.quantity,
      createdAt: i.createdAt,
    );

PurchaseOrderPayment toPurchaseOrderPayment(PurchaseOrderPaymentRow r) =>
    PurchaseOrderPayment(
      id: r.id,
      organizationId: r.organizationId,
      purchaseOrderId: r.purchaseOrderId,
      paymentNumber: r.paymentNumber,
      amount: r.amount,
      method: PaymentMethod.fromWire(r.method),
      status: PaymentDocStatus.fromWire(r.status),
      paymentDate: r.paymentDate,
      isActive: r.isActive,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
    );

PurchaseOrderPaymentsCompanion purchaseOrderPaymentInsert(
        PurchaseOrderPayment p) =>
    PurchaseOrderPaymentsCompanion.insert(
      id: p.id,
      organizationId: p.organizationId,
      purchaseOrderId: p.purchaseOrderId,
      paymentNumber: p.paymentNumber,
      amount: p.amount,
      method: p.method.wire,
      status: Value(p.status.wire),
      paymentDate: p.paymentDate,
      isActive: Value(p.isActive),
      createdAt: p.createdAt,
      updatedAt: p.updatedAt,
    );
