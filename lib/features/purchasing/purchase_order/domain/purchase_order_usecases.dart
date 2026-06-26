import '../../../../core/id/id_generator.dart';
import '../../../../core/result/app_exception.dart';
import 'purchase_order.dart';
import 'purchase_order_enums.dart';
import 'purchase_order_repository.dart';

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

class PurchaseOrderService {
  PurchaseOrderService({
    required PurchaseOrderRepository repository,
    required IdGenerator ids,
    required String organizationId,
    required String userId,
  })  : _repo = repository,
        _ids = ids,
        _orgId = organizationId,
        _userId = userId;

  static const int pageSize = 20;

  final PurchaseOrderRepository _repo;
  final IdGenerator _ids;
  final String _orgId;
  final String _userId;

  String get userId => _userId;

  Future<PurchaseOrder?> get(String id) => _repo.getOrder(id);
  Future<List<PurchaseOrderItem>> items(String orderId) =>
      _repo.itemsFor(orderId);
  Future<List<PurchaseOrderReceipt>> receipts(String orderId) =>
      _repo.receiptsFor(orderId);
  Future<List<PurchaseOrder>> list(
          {PurchaseOrderStatus? status, String? supplierId, int page = 0}) =>
      _repo.listOrders(_orgId,
          status: status,
          supplierId: supplierId,
          limit: pageSize,
          offset: page * pageSize);

  Future<PurchaseOrder> createDraft({
    required String supplierId,
    required List<NewLine> lines,
    DateTime? expectedDeliveryDate,
  }) async {
    if (supplierId.trim().isEmpty) {
      throw const ValidationException('A supplier is required.');
    }
    if (lines.isEmpty) {
      throw const ValidationException('An order needs at least one line.');
    }
    final now = DateTime.now().toUtc();
    final orderId = _ids.newId();
    final number = await _repo.nextNumber(_orgId, 'purchase_order', 'PO');
    final items = lines.map((l) => _toItem(orderId, l, now)).toList();
    final total = items.fold<double>(0, (a, i) => a + i.totalPrice);
    final order = PurchaseOrder(
      id: orderId,
      organizationId: _orgId,
      orderNumber: number,
      supplierId: supplierId,
      orderDate: now,
      expectedDeliveryDate: expectedDeliveryDate,
      status: PurchaseOrderStatus.draft,
      paymentStatus: PaymentStatus.notPaid,
      receiptStatus: ReceiptStatus.notReceived,
      totalAmount: total,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );
    await _repo.createOrder(order, items);
    return order;
  }

  Future<void> editDraft(PurchaseOrder order, List<NewLine> lines) async {
    if (order.status != PurchaseOrderStatus.draft) {
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

  Future<void> send(PurchaseOrder order) => _transition(order,
      from: {PurchaseOrderStatus.draft}, to: PurchaseOrderStatus.sent);

  Future<void> confirm(PurchaseOrder order) => _transition(order,
      from: {PurchaseOrderStatus.sent}, to: PurchaseOrderStatus.confirmed);

  Future<void> cancel(PurchaseOrder order) async {
    if (order.status == PurchaseOrderStatus.received ||
        order.status == PurchaseOrderStatus.cancelled) {
      throw const ValidationException(
          'A received or cancelled order cannot be cancelled.');
    }
    final orderReceipts = await _repo.receiptsFor(order.id);
    if (orderReceipts.any((r) => r.status == ReceiptDocStatus.posted)) {
      throw const ConflictException(
          'Cannot cancel an order that already has posted receipts.');
    }
    await _repo.setStatus(order.id, PurchaseOrderStatus.cancelled);
  }

  Future<void> deleteDraft(PurchaseOrder order) async {
    if (order.status != PurchaseOrderStatus.draft) {
      throw const ValidationException('Only draft orders can be deleted.');
    }
    await _repo.softDeleteOrder(order.id);
  }

  Future<List<PurchaseOrderPayment>> payments(String orderId) =>
      _repo.paymentsFor(orderId);

  Future<void> addPayment(
    PurchaseOrder order, {
    required double amount,
    required PaymentMethod method,
    DateTime? paymentDate,
  }) async {
    _assertPayable(order);
    if (amount <= 0) {
      throw const ValidationException('Payment amount must be positive.');
    }
    final now = DateTime.now().toUtc();
    final number = await _repo.nextNumber(_orgId, 'po_payment', 'PPAY');
    await _repo.createDraftPayment(PurchaseOrderPayment(
      id: _ids.newId(),
      organizationId: _orgId,
      purchaseOrderId: order.id,
      paymentNumber: number,
      amount: amount,
      method: method,
      status: PaymentDocStatus.draft,
      paymentDate: paymentDate ?? now,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    ));
  }

  Future<void> editPayment(
    PurchaseOrderPayment payment, {
    required double amount,
    required PaymentMethod method,
    DateTime? paymentDate,
  }) async {
    if (payment.status != PaymentDocStatus.draft) {
      throw const ValidationException('Only draft payments can be edited.');
    }
    if (amount <= 0) {
      throw const ValidationException('Payment amount must be positive.');
    }
    await _repo.editDraftPayment(payment.id,
        amount: amount,
        method: method,
        paymentDate: paymentDate ?? payment.paymentDate);
  }

  Future<void> postPayment(
      PurchaseOrder order, PurchaseOrderPayment payment) async {
    if (payment.status != PaymentDocStatus.draft) {
      throw const ValidationException('Only draft payments can be posted.');
    }
    final posted = await _repo.postedTotal(order.id);
    if (posted + payment.amount > order.totalAmount) {
      throw const ValidationException(
          'Total payments cannot exceed the order total.');
    }
    await _repo.postPayment(payment.id);
  }

  Future<void> cancelPayment(PurchaseOrderPayment payment) async {
    if (payment.status != PaymentDocStatus.draft) {
      throw const ValidationException('Only draft payments can be cancelled.');
    }
    await _repo.cancelDraftPayment(payment.id);
  }

  void _assertPayable(PurchaseOrder order) {
    if (order.status == PurchaseOrderStatus.draft ||
        order.status == PurchaseOrderStatus.cancelled) {
      throw const ValidationException(
          'Payments can only be recorded on a sent/confirmed order.');
    }
  }

  // Task 12 (receipts) will append methods here.

  Future<void> _transition(PurchaseOrder order,
      {required Set<PurchaseOrderStatus> from,
      required PurchaseOrderStatus to}) async {
    if (!from.contains(order.status)) {
      throw ValidationException(
          'Cannot move an order from ${order.status.wire} to ${to.wire}.');
    }
    await _repo.setStatus(order.id, to);
  }

  PurchaseOrderItem _toItem(String orderId, NewLine l, DateTime now) {
    if (l.quantity <= 0) {
      throw const ValidationException('Line quantity must be positive.');
    }
    return PurchaseOrderItem(
      id: _ids.newId(),
      organizationId: _orgId,
      purchaseOrderId: orderId,
      productId: l.productId,
      productName: l.productName,
      quantity: l.quantity,
      unitPrice: l.unitPrice,
      totalPrice: l.quantity * l.unitPrice,
      receivedQuantity: 0,
      createdAt: now,
      updatedAt: now,
    );
  }
}
