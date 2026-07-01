import '../../../../core/id/id_generator.dart';
import '../../../../core/result/app_exception.dart';
import '../data/sale_order_shipping_dao.dart' show ShipmentLine;
import 'sale_order.dart';
import 'sale_order_enums.dart';
import 'sale_order_repository.dart';

class NewLine {
  const NewLine({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });
  final String productId;
  final String productName;
  final double quantity;
  final double unitPrice;
}

class SaleOrderService {
  SaleOrderService({
    required SaleOrderRepository repository,
    required IdGenerator ids,
    required String organizationId,
    required String userId,
  })  : _repo = repository,
        _ids = ids,
        _orgId = organizationId,
        _userId = userId;

  static const int pageSize = 20;

  final SaleOrderRepository _repo;
  final IdGenerator _ids;
  final String _orgId;
  final String _userId;

  String get userId => _userId;

  Future<SaleOrder?> get(String id) => _repo.getOrder(id);

  Future<List<SaleOrder>> ordersForCustomer(String customerId) =>
      _repo.ordersForCustomer(_orgId, customerId);

  Future<double> outstandingForCustomer(String customerId) =>
      _repo.outstandingForCustomer(_orgId, customerId);

  Future<int> liveOrdersForCustomer(String customerId) =>
      _repo.countLiveForCustomer(_orgId, customerId);
  Future<List<SaleOrderItem>> items(String orderId) => _repo.itemsFor(orderId);

  Future<int> countByDateRange(DateTime from, DateTime to) =>
      _repo.countByDateRange(_orgId, from, to);

  Future<double> totalAmountByDateRange(DateTime from, DateTime to) =>
      _repo.totalAmountByDateRange(_orgId, from, to);

  Future<List<SaleOrder>> allActive() => _repo.allActive(_orgId);

  Future<List<SaleOrder>> list({
    OrderStatus? status,
    String? customerId,
    String? search,
    PaymentStatus? paymentStatus,
    ShippingStatus? shippingStatus,
    DateTime? from,
    DateTime? to,
    int page = 0,
  }) =>
      _repo.listOrders(_orgId,
          status: status,
          customerId: customerId,
          search: search,
          paymentStatus: paymentStatus,
          shippingStatus: shippingStatus,
          from: from,
          to: to,
          limit: pageSize,
          offset: page * pageSize);

  Future<SaleOrder> createDraft({
    required String customerId,
    required List<NewLine> lines,
    DateTime? deliveryDate,
  }) async {
    if (customerId.trim().isEmpty) {
      throw const ValidationException('A customer is required.');
    }
    if (lines.isEmpty) {
      throw const ValidationException('An order needs at least one line.');
    }
    final now = DateTime.now().toUtc();
    final orderId = _ids.newId();
    final soNumber = await _repo.nextNumber(_orgId, 'sale_order', 'SO');
    final items = lines.map((l) => _toItem(orderId, l, now)).toList();
    final total = items.fold<double>(0, (a, i) => a + i.totalPrice);
    final order = SaleOrder(
      id: orderId,
      organizationId: _orgId,
      soNumber: soNumber,
      customerId: customerId,
      orderDate: now,
      deliveryDate: deliveryDate,
      status: OrderStatus.draft,
      paymentStatus: PaymentStatus.notPaid,
      shippingStatus: ShippingStatus.notShipped,
      totalAmount: total,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );
    await _repo.createOrder(order, items);
    return order;
  }

  Future<void> editDraft(SaleOrder order, List<NewLine> lines) async {
    if (order.status != OrderStatus.draft) {
      throw const ValidationException('Only draft orders can be edited.');
    }
    if (lines.isEmpty) {
      throw const ValidationException('An order needs at least one line.');
    }
    final now = DateTime.now().toUtc();
    final items = lines.map((l) => _toItem(order.id, l, now)).toList();
    final total = items.fold<double>(0, (a, i) => a + i.totalPrice);
    await _repo.replaceDraftItems(order.id, items, total);
  }

  Future<void> confirm(SaleOrder order) =>
      _transition(order, from: {OrderStatus.draft}, to: OrderStatus.confirmed);

  Future<void> process(SaleOrder order) => _transition(order,
      from: {OrderStatus.confirmed}, to: OrderStatus.processing);

  Future<void> cancel(SaleOrder order) async {
    if (order.status == OrderStatus.shipped ||
        order.status == OrderStatus.delivered ||
        order.status == OrderStatus.cancelled) {
      throw const ValidationException(
          'A shipped, delivered, or cancelled order cannot be cancelled.');
    }
    final shipments = await _repo.shipmentsFor(order.id);
    if (shipments.isNotEmpty) {
      throw const ConflictException(
          'Cannot cancel an order that already has shipments.');
    }
    await _repo.setStatus(order.id, OrderStatus.cancelled);
  }

  Future<void> deleteDraft(SaleOrder order) async {
    if (order.status != OrderStatus.draft) {
      throw const ValidationException('Only draft orders can be deleted.');
    }
    await _repo.softDeleteOrder(order.id);
  }

  Future<List<SaleOrderPayment>> payments(String orderId) =>
      _repo.paymentsFor(orderId);

  Future<void> addPayment(
    SaleOrder order, {
    required double amount,
    required PaymentMethod method,
    PaymentRecordStatus status = PaymentRecordStatus.completed,
    DateTime? paymentDate,
  }) async {
    _assertPayable(order);
    if (amount <= 0) {
      throw const ValidationException('Payment amount must be positive.');
    }
    await _assertNoOverpay(order, addedCompleted: status, addedAmount: amount);
    final now = DateTime.now().toUtc();
    final number = await _repo.nextNumber(_orgId, 'so_payment', 'PAY');
    await _repo.recordPayment(SaleOrderPayment(
      id: _ids.newId(),
      organizationId: _orgId,
      saleOrderId: order.id,
      paymentNumber: number,
      amount: amount,
      method: method,
      status: status,
      paymentDate: paymentDate ?? now,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    ));
  }

  Future<void> editPayment(
    SaleOrder order,
    SaleOrderPayment payment, {
    required double amount,
    required PaymentMethod method,
    required PaymentRecordStatus status,
    DateTime? paymentDate,
  }) async {
    if (amount <= 0) {
      throw const ValidationException('Payment amount must be positive.');
    }
    await _assertNoOverpay(order,
        addedCompleted: status,
        addedAmount: amount,
        excludingPayment: payment);
    await _repo.editPayment(payment.id,
        amount: amount,
        method: method,
        status: status,
        paymentDate: paymentDate ?? payment.paymentDate);
  }

  Future<void> deletePayment(SaleOrderPayment payment) =>
      _repo.deletePayment(payment.id);

  void _assertPayable(SaleOrder order) {
    if (order.status == OrderStatus.draft ||
        order.status == OrderStatus.cancelled) {
      throw const ValidationException(
          'Payments can only be recorded on a confirmed order.');
    }
  }

  Future<void> _assertNoOverpay(
    SaleOrder order, {
    required PaymentRecordStatus addedCompleted,
    required double addedAmount,
    SaleOrderPayment? excludingPayment,
  }) async {
    var completed = await _repo.completedTotal(order.id);
    if (excludingPayment != null &&
        excludingPayment.status == PaymentRecordStatus.completed) {
      completed -= excludingPayment.amount;
    }
    final projected = completed +
        (addedCompleted == PaymentRecordStatus.completed ? addedAmount : 0);
    if (projected > order.totalAmount) {
      throw const ValidationException(
          'Total payments cannot exceed the order total.');
    }
  }

  Future<List<SaleOrderShipping>> shipments(String orderId) =>
      _repo.shipmentsFor(orderId);

  Future<void> createShipment(
    SaleOrder order, {
    required List<ShipLine> lines,
    String? carrier,
    String? trackingNumber,
    DateTime? shippingDate,
  }) async {
    if (order.status != OrderStatus.confirmed &&
        order.status != OrderStatus.processing) {
      throw const ValidationException(
          'Only confirmed or processing orders can ship.');
    }
    final positive = lines.where((l) => l.quantity > 0).toList();
    if (positive.isEmpty) {
      throw const ValidationException('A shipment needs at least one line.');
    }
    for (final l in positive) {
      if (l.quantity > l.item.remainingQuantity) {
        throw ValidationException(
            'Cannot ship ${l.quantity} of ${l.item.productName}; only ${l.item.remainingQuantity} remain.');
      }
    }
    final now = DateTime.now().toUtc();
    final shippingId = _ids.newId();
    final number = await _repo.nextNumber(_orgId, 'so_shipping', 'SHP');
    final shipping = SaleOrderShipping(
      id: shippingId,
      organizationId: _orgId,
      saleOrderId: order.id,
      soShippingNumber: number,
      shippingDate: shippingDate ?? now,
      carrier: carrier,
      trackingNumber: trackingNumber,
      status: ShipmentStatus.shipped,
      createdAt: now,
      updatedAt: now,
    );
    final daoLines = positive
        .map((l) => ShipmentLine(
              saleOrderItemId: l.item.id,
              productId: l.item.productId,
              movementId: _ids.newId(),
              quantity: l.quantity,
            ))
        .toList();
    await _repo.createShipment(shipping, daoLines, _userId);
  }

  Future<void> setShipmentStatus(
          SaleOrderShipping shipping, ShipmentStatus status) =>
      _repo.setShipmentStatus(shipping.id, status);

  Future<SaleKpis> dashboard() async => SaleKpis(
        openOrders: await _repo.countOpenOrders(_orgId),
        unshipped: await _repo.countUnshipped(_orgId),
        outstanding: await _repo.outstandingReceivables(_orgId),
      );

  Future<void> _transition(SaleOrder order,
      {required Set<OrderStatus> from, required OrderStatus to}) async {
    if (!from.contains(order.status)) {
      throw ValidationException(
          'Cannot move an order from ${order.status.wire} to ${to.wire}.');
    }
    await _repo.setStatus(order.id, to);
  }

  SaleOrderItem _toItem(String orderId, NewLine l, DateTime now) {
    if (l.quantity <= 0) {
      throw const ValidationException('Line quantity must be positive.');
    }
    return SaleOrderItem(
      id: _ids.newId(),
      organizationId: _orgId,
      saleOrderId: orderId,
      productId: l.productId,
      productName: l.productName,
      quantity: l.quantity,
      unitPrice: l.unitPrice,
      totalPrice: l.quantity * l.unitPrice,
      shippedQuantity: 0,
      createdAt: now,
      updatedAt: now,
    );
  }
}

class ShipLine {
  const ShipLine({required this.item, required this.quantity});
  final SaleOrderItem item;
  final double quantity;
}

class SaleKpis {
  const SaleKpis({
    required this.openOrders,
    required this.unshipped,
    required this.outstanding,
  });
  final int openOrders;
  final int unshipped;
  final double outstanding;
}
