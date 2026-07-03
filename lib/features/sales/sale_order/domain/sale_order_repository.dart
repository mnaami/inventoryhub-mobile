import '../data/sale_order_shipping_dao.dart' show ShipmentLine;
import 'sale_order.dart';
import 'sale_order_enums.dart';

abstract interface class SaleOrderRepository {
  Future<String> nextNumber(String orgId, String entityType, String prefix);

  Future<void> createOrder(SaleOrder order, List<SaleOrderItem> items);
  Future<void> replaceDraftItems(
      String orderId, List<SaleOrderItem> items, double totalAmount);
  Future<SaleOrder?> getOrder(String id);
  Future<List<SaleOrderItem>> itemsFor(String orderId);
  Future<List<SaleOrder>> listOrders(String orgId,
      {OrderStatus? status,
      String? customerId,
      String? search,
      PaymentStatus? paymentStatus,
      ShippingStatus? shippingStatus,
      DateTime? from,
      DateTime? to,
      required int limit,
      required int offset});
  Future<void> setStatus(String id, OrderStatus status);
  Future<void> softDeleteOrder(String id);
  Future<int> countLiveForCustomer(String orgId, String customerId);
  Future<List<SaleOrder>> ordersForCustomer(String orgId, String customerId);
  Future<double> outstandingForCustomer(String orgId, String customerId);
  Future<int> countOpenOrders(String orgId);
  Future<int> countUnshipped(String orgId);
  Future<double> outstandingReceivables(String orgId);
  Future<int> countByDateRange(String orgId, DateTime from, DateTime to);
  Future<double> totalAmountByDateRange(String orgId, DateTime from, DateTime to);
  Future<List<SaleOrder>> allActive(String orgId);
  Future<List<({DateTime orderDate, double totalAmount})>> salesInRange(
      String orgId, DateTime from, DateTime to);


  Future<void> recordPayment(SaleOrderPayment payment);
  Future<void> editPayment(String paymentId,
      {required double amount,
      required PaymentMethod method,
      required PaymentRecordStatus status,
      required DateTime paymentDate});
  Future<void> deletePayment(String paymentId);
  Future<List<SaleOrderPayment>> paymentsFor(String orderId);
  Future<double> completedTotal(String orderId);

  Future<void> createShipment(SaleOrderShipping shipping,
      List<ShipmentLine> lines, String createdBy);
  Future<void> setShipmentStatus(String shippingId, ShipmentStatus status);
  Future<List<SaleOrderShipping>> shipmentsFor(String orderId);
}
