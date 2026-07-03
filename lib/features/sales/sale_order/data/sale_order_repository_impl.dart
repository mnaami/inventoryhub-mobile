import '../domain/sale_order.dart';
import '../domain/sale_order_enums.dart';
import '../domain/sale_order_repository.dart';
import 'document_counter_dao.dart';
import 'sale_order_dao.dart';
import 'sale_order_mappers.dart';
import 'sale_order_payment_dao.dart';
import 'sale_order_shipping_dao.dart';

class SaleOrderRepositoryImpl implements SaleOrderRepository {
  SaleOrderRepositoryImpl(
      this._orders, this._payments, this._shipping, this._counters);
  final SaleOrderDao _orders;
  final SaleOrderPaymentDao _payments;
  final SaleOrderShippingDao _shipping;
  final DocumentCounterDao _counters;

  @override
  Future<String> nextNumber(String orgId, String entityType, String prefix) =>
      _counters.next(orgId, entityType, prefix);

  @override
  Future<void> createOrder(SaleOrder order, List<SaleOrderItem> items) =>
      _orders.createWithItems(
          saleOrderInsert(order), items.map(saleOrderItemInsert).toList());

  @override
  Future<void> replaceDraftItems(
          String orderId, List<SaleOrderItem> items, double totalAmount) =>
      _orders.replaceItems(orderId, items.map(saleOrderItemInsert).toList(),
          totalAmount: totalAmount, now: DateTime.now().toUtc());

  @override
  Future<SaleOrder?> getOrder(String id) async {
    final r = await _orders.byId(id);
    return r == null ? null : toSaleOrder(r);
  }

  @override
  Future<List<SaleOrderItem>> itemsFor(String orderId) async =>
      (await _orders.itemsFor(orderId)).map(toSaleOrderItem).toList();

  @override
  Future<List<SaleOrder>> listOrders(String orgId,
          {OrderStatus? status,
          String? customerId,
          String? search,
          PaymentStatus? paymentStatus,
          ShippingStatus? shippingStatus,
          DateTime? from,
          DateTime? to,
          required int limit,
          required int offset}) async =>
      (await _orders.paged(orgId,
              status: status?.wire,
              customerId: customerId,
              search: search,
              paymentStatus: paymentStatus?.wire,
              shippingStatus: shippingStatus?.wire,
              from: from,
              to: to,
              limit: limit,
              offset: offset))
          .map(toSaleOrder)
          .toList();

  @override
  Future<void> setStatus(String id, OrderStatus status) =>
      _orders.setStatus(id, status.wire, DateTime.now().toUtc());

  @override
  Future<void> softDeleteOrder(String id) =>
      _orders.softDelete(id, DateTime.now().toUtc());

  @override
  Future<int> countLiveForCustomer(String orgId, String customerId) =>
      _orders.countLiveForCustomer(orgId, customerId);

  @override
  Future<List<SaleOrder>> ordersForCustomer(
          String orgId, String customerId) async =>
      (await _orders.forCustomer(orgId, customerId)).map(toSaleOrder).toList();

  @override
  Future<double> outstandingForCustomer(
      String orgId, String customerId) async {
    final total = await _orders.ordersTotalForCustomer(orgId, customerId);
    final paid = await _payments.completedTotalForCustomer(orgId, customerId);
    return total - paid;
  }

  @override
  Future<int> countOpenOrders(String orgId) => _orders.countByStatuses(
      orgId, const ['draft', 'confirmed', 'processing']);

  @override
  Future<int> countUnshipped(String orgId) => _orders.countUnshipped(orgId);

  @override
  Future<double> outstandingReceivables(String orgId) async {
    final total = await _orders.ordersTotal(orgId);
    final paid = await _payments.completedTotalForOrg(orgId);
    return total - paid;
  }

  @override
  Future<void> recordPayment(SaleOrderPayment payment) =>
      _payments.recordPayment(saleOrderPaymentInsert(payment));

  @override
  Future<void> editPayment(String paymentId,
          {required double amount,
          required PaymentMethod method,
          required PaymentRecordStatus status,
          required DateTime paymentDate}) =>
      _payments.editPayment(paymentId,
          amount: amount,
          method: method.wire,
          status: status.wire,
          paymentDate: paymentDate,
          now: DateTime.now().toUtc());

  @override
  Future<void> deletePayment(String paymentId) =>
      _payments.deletePayment(paymentId, DateTime.now().toUtc());

  @override
  Future<List<SaleOrderPayment>> paymentsFor(String orderId) async =>
      (await _payments.paymentsFor(orderId)).map(toSaleOrderPayment).toList();

  @override
  Future<double> completedTotal(String orderId) =>
      _payments.completedTotal(orderId);

  @override
  Future<void> createShipment(SaleOrderShipping shipping,
          List<ShipmentLine> lines, String createdBy) =>
      _shipping.createShipment(
        shipping: saleOrderShippingInsert(shipping),
        lines: lines,
        orgId: shipping.organizationId,
        createdBy: createdBy,
        now: DateTime.now().toUtc(),
      );

  @override
  Future<void> setShipmentStatus(String shippingId, ShipmentStatus status) =>
      _shipping.setStatus(shippingId, status.wire, DateTime.now().toUtc());

  @override
  Future<List<SaleOrderShipping>> shipmentsFor(String orderId) async =>
      (await _shipping.shipmentsFor(orderId)).map(toSaleOrderShipping).toList();

  @override
  Future<int> countByDateRange(String orgId, DateTime from, DateTime to) =>
      _orders.countByDateRange(orgId, from, to);

  @override
  Future<double> totalAmountByDateRange(String orgId, DateTime from, DateTime to) =>
      _orders.totalAmountByDateRange(orgId, from, to);

  @override
  Future<List<SaleOrder>> allActive(String orgId) async =>
      (await _orders.allActive(orgId)).map(toSaleOrder).toList();

  @override
  Future<List<({DateTime orderDate, double totalAmount})>> salesInRange(
          String orgId, DateTime from, DateTime to) =>
      _orders.salesInRange(orgId, from, to);
}

