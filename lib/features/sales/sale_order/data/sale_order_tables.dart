import 'package:drift/drift.dart';

@DataClassName('SaleOrderRow')
class SaleOrders extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text().named('organization_id')();
  TextColumn get soNumber => text().named('so_number')();
  TextColumn get customerId => text().named('customer_id')();
  DateTimeColumn get orderDate => dateTime().named('order_date')();
  DateTimeColumn get deliveryDate => dateTime().named('delivery_date').nullable()();
  TextColumn get status => text().withDefault(const Constant('draft'))();
  TextColumn get paymentStatus =>
      text().named('payment_status').withDefault(const Constant('not_paid'))();
  TextColumn get shippingStatus =>
      text().named('shipping_status').withDefault(const Constant('not_shipped'))();
  RealColumn get totalAmount =>
      real().named('total_amount').withDefault(const Constant(0))();
  BoolColumn get isActive =>
      boolean().named('is_active').withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SaleOrderItemRow')
class SaleOrderItems extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text().named('organization_id')();
  TextColumn get saleOrderId => text().named('sale_order_id')();
  TextColumn get productId => text().named('product_id')();
  TextColumn get productName => text().named('product_name')();
  RealColumn get quantity => real()();
  RealColumn get unitPrice => real().named('unit_price')();
  RealColumn get totalPrice => real().named('total_price')();
  RealColumn get shippedQuantity =>
      real().named('shipped_quantity').withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SaleOrderPaymentRow')
class SaleOrderPayments extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text().named('organization_id')();
  TextColumn get saleOrderId => text().named('sale_order_id')();
  TextColumn get paymentNumber => text().named('payment_number')();
  RealColumn get amount => real()();
  TextColumn get method => text()();
  TextColumn get status => text().withDefault(const Constant('completed'))();
  DateTimeColumn get paymentDate => dateTime().named('payment_date')();
  BoolColumn get isActive =>
      boolean().named('is_active').withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SaleOrderShippingRow')
class SaleOrderShippings extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text().named('organization_id')();
  TextColumn get saleOrderId => text().named('sale_order_id')();
  TextColumn get soShippingNumber => text().named('so_shipping_number')();
  DateTimeColumn get shippingDate => dateTime().named('shipping_date')();
  TextColumn get carrier => text().nullable()();
  TextColumn get trackingNumber => text().named('tracking_number').nullable()();
  TextColumn get status => text().withDefault(const Constant('shipped'))();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SaleOrderShippingItemRow')
class SaleOrderShippingItems extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text().named('organization_id')();
  TextColumn get shippingId => text().named('shipping_id')();
  TextColumn get saleOrderItemId => text().named('sale_order_item_id')();
  TextColumn get productId => text().named('product_id')();
  RealColumn get quantity => real()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();

  @override
  Set<Column> get primaryKey => {id};
}
