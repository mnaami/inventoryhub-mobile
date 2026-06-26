import 'package:drift/drift.dart';

@DataClassName('PurchaseOrderRow')
class PurchaseOrders extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text().named('organization_id')();
  TextColumn get orderNumber => text().named('order_number')();
  TextColumn get supplierId => text().named('supplier_id')();
  DateTimeColumn get orderDate => dateTime().named('order_date')();
  DateTimeColumn get expectedDeliveryDate =>
      dateTime().named('expected_delivery_date').nullable()();
  TextColumn get status => text().withDefault(const Constant('draft'))();
  TextColumn get paymentStatus =>
      text().named('payment_status').withDefault(const Constant('not_paid'))();
  TextColumn get receiptStatus =>
      text().named('receipt_status').withDefault(const Constant('not_received'))();
  RealColumn get totalAmount =>
      real().named('total_amount').withDefault(const Constant(0))();
  BoolColumn get isActive =>
      boolean().named('is_active').withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('PurchaseOrderItemRow')
class PurchaseOrderItems extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text().named('organization_id')();
  TextColumn get purchaseOrderId => text().named('purchase_order_id')();
  TextColumn get productId => text().named('product_id')();
  TextColumn get productName => text().named('product_name')();
  RealColumn get quantity => real()();
  RealColumn get unitPrice => real().named('unit_price')();
  RealColumn get totalPrice => real().named('total_price')();
  RealColumn get receivedQuantity =>
      real().named('received_quantity').withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('PurchaseOrderReceiptRow')
class PurchaseOrderReceipts extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text().named('organization_id')();
  TextColumn get purchaseOrderId => text().named('purchase_order_id')();
  TextColumn get receiptNumber => text().named('receipt_number')();
  DateTimeColumn get receiptDate => dateTime().named('receipt_date')();
  TextColumn get status => text().withDefault(const Constant('draft'))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('PurchaseOrderReceiptItemRow')
class PurchaseOrderReceiptItems extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text().named('organization_id')();
  TextColumn get receiptId => text().named('receipt_id')();
  TextColumn get purchaseOrderItemId => text().named('purchase_order_item_id')();
  TextColumn get productId => text().named('product_id')();
  RealColumn get quantity => real()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('PurchaseOrderPaymentRow')
class PurchaseOrderPayments extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text().named('organization_id')();
  TextColumn get purchaseOrderId => text().named('purchase_order_id')();
  TextColumn get paymentNumber => text().named('payment_number')();
  RealColumn get amount => real()();
  TextColumn get method => text()();
  TextColumn get status => text().withDefault(const Constant('draft'))();
  DateTimeColumn get paymentDate => dateTime().named('payment_date')();
  BoolColumn get isActive =>
      boolean().named('is_active').withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column> get primaryKey => {id};
}
