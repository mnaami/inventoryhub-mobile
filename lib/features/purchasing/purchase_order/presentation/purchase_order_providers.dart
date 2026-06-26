import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers.dart';
import '../../../sales/sale_order/data/document_counter_dao.dart';
import '../data/purchase_order_dao.dart';
import '../data/purchase_order_payment_dao.dart';
import '../data/purchase_order_receipt_dao.dart';
import '../data/purchase_order_repository_impl.dart';
import '../domain/purchase_order.dart';
import '../domain/purchase_order_enums.dart';
import '../domain/purchase_order_usecases.dart';

final purchaseOrderServiceProvider = Provider<PurchaseOrderService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final session = ref.watch(sessionProvider);
  return PurchaseOrderService(
    repository: PurchaseOrderRepositoryImpl(PurchaseOrderDao(db),
        PurchaseOrderReceiptDao(db), PurchaseOrderPaymentDao(db),
        DocumentCounterDao(db)),
    ids: ref.watch(idGeneratorProvider),
    organizationId: session.organizationId,
    userId: session.userId,
  );
});

class PurchaseOrderFilter extends Notifier<PurchaseOrderStatus?> {
  @override
  PurchaseOrderStatus? build() => null;
  void set(PurchaseOrderStatus? status) => state = status;
}

final purchaseOrderFilterProvider =
    NotifierProvider<PurchaseOrderFilter, PurchaseOrderStatus?>(
        PurchaseOrderFilter.new);

final purchaseOrdersProvider = FutureProvider<List<PurchaseOrder>>((ref) {
  return ref
      .watch(purchaseOrderServiceProvider)
      .list(status: ref.watch(purchaseOrderFilterProvider));
});

final purchaseOrderProvider = FutureProvider.family<PurchaseOrder?, String>(
    (ref, id) => ref.watch(purchaseOrderServiceProvider).get(id));

final purchaseOrderItemsProvider =
    FutureProvider.family<List<PurchaseOrderItem>, String>(
        (ref, id) => ref.watch(purchaseOrderServiceProvider).items(id));

final purchaseOrderPaymentsProvider =
    FutureProvider.family<List<PurchaseOrderPayment>, String>(
        (ref, id) => ref.watch(purchaseOrderServiceProvider).payments(id));

final purchaseOrderReceiptsProvider =
    FutureProvider.family<List<PurchaseOrderReceipt>, String>(
        (ref, id) => ref.watch(purchaseOrderServiceProvider).receipts(id));

final purchaseDashboardProvider = FutureProvider((ref) =>
    ref.watch(purchaseOrderServiceProvider).dashboard());

String poStatusLabel(PurchaseOrderStatus s) => switch (s) {
      PurchaseOrderStatus.draft => 'Draft',
      PurchaseOrderStatus.sent => 'Sent',
      PurchaseOrderStatus.confirmed => 'Confirmed',
      PurchaseOrderStatus.received => 'Received',
      PurchaseOrderStatus.cancelled => 'Cancelled',
    };

String receiptStatusLabel(ReceiptStatus s) => switch (s) {
      ReceiptStatus.notReceived => 'Not received',
      ReceiptStatus.partial => 'Partially received',
      ReceiptStatus.fullyReceived => 'Fully received',
    };

String paymentStatusLabel(PaymentStatus s) => switch (s) {
      PaymentStatus.notPaid => 'Not paid',
      PaymentStatus.partial => 'Partial',
      PaymentStatus.paid => 'Paid',
    };
