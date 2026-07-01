import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/paging/paged_list_notifier.dart';
import '../../../../core/paging/paged_state.dart';
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

enum DatePreset { all, today, week, month }

class PurchaseOrderListCriteria {
  const PurchaseOrderListCriteria({
    this.search = '',
    this.status,
    this.paymentStatus,
    this.receiptStatus,
    this.datePreset = DatePreset.all,
  });

  final String search;
  final PurchaseOrderStatus? status;
  final PaymentStatus? paymentStatus;
  final ReceiptStatus? receiptStatus;
  final DatePreset datePreset;

  PurchaseOrderListCriteria copyWith({
    String? search,
    PurchaseOrderStatus? status,
    bool clearStatus = false,
    PaymentStatus? paymentStatus,
    bool clearPaymentStatus = false,
    ReceiptStatus? receiptStatus,
    bool clearReceiptStatus = false,
    DatePreset? datePreset,
  }) =>
      PurchaseOrderListCriteria(
        search: search ?? this.search,
        status: clearStatus ? null : (status ?? this.status),
        paymentStatus:
            clearPaymentStatus ? null : (paymentStatus ?? this.paymentStatus),
        receiptStatus:
            clearReceiptStatus ? null : (receiptStatus ?? this.receiptStatus),
        datePreset: datePreset ?? this.datePreset,
      );

  DateTime? get from {
    final now = DateTime.now().toUtc();
    switch (datePreset) {
      case DatePreset.all:
        return null;
      case DatePreset.today:
        return DateTime.utc(now.year, now.month, now.day);
      case DatePreset.week:
        return now.subtract(const Duration(days: 7));
      case DatePreset.month:
        return now.subtract(const Duration(days: 30));
    }
  }

  bool get hasActiveFilters =>
      search.isNotEmpty ||
      status != null ||
      paymentStatus != null ||
      receiptStatus != null ||
      datePreset != DatePreset.all;
}

class PurchaseOrderCriteria extends Notifier<PurchaseOrderListCriteria> {
  @override
  PurchaseOrderListCriteria build() => const PurchaseOrderListCriteria();

  void setSearch(String v) => state = state.copyWith(search: v);
  void setStatus(PurchaseOrderStatus? v) =>
      state = state.copyWith(status: v, clearStatus: v == null);
  void setPaymentStatus(PaymentStatus? v) =>
      state = state.copyWith(paymentStatus: v, clearPaymentStatus: v == null);
  void setReceiptStatus(ReceiptStatus? v) =>
      state = state.copyWith(receiptStatus: v, clearReceiptStatus: v == null);
  void setDatePreset(DatePreset v) => state = state.copyWith(datePreset: v);
  void reset() => state = const PurchaseOrderListCriteria();
}

final purchaseOrderCriteriaProvider =
    NotifierProvider<PurchaseOrderCriteria, PurchaseOrderListCriteria>(
        PurchaseOrderCriteria.new);

class PurchaseOrderListNotifier extends PagedListNotifier<PurchaseOrder> {
  @override
  int get pageSize => PurchaseOrderService.pageSize;

  @override
  PagedState<PurchaseOrder> build() {
    ref.listen(purchaseOrderCriteriaProvider, (_, __) => reload());
    return super.build();
  }

  @override
  Future<List<PurchaseOrder>> fetch(int page) {
    final c = ref.read(purchaseOrderCriteriaProvider);
    return ref.read(purchaseOrderServiceProvider).list(
          page: page,
          search: c.search,
          status: c.status,
          paymentStatus: c.paymentStatus,
          receiptStatus: c.receiptStatus,
          from: c.from,
        );
  }
}

final purchaseOrderListProvider =
    NotifierProvider<PurchaseOrderListNotifier, PagedState<PurchaseOrder>>(
        PurchaseOrderListNotifier.new);

final purchaseOrderCountProvider = FutureProvider.family<int, ({DateTime startDate, DateTime endDate})>((ref, params) async {
  final service = ref.watch(purchaseOrderServiceProvider);
  return await service.countByDateRange(params.startDate, params.endDate);
});

final purchaseOrderAmountProvider = FutureProvider.family<double, ({DateTime startDate, DateTime endDate})>((ref, params) async {
  final service = ref.watch(purchaseOrderServiceProvider);
  return await service.totalAmountByDateRange(params.startDate, params.endDate);
});

final allPurchaseOrdersProvider = FutureProvider<List<PurchaseOrder>>((ref) async {
  final service = ref.watch(purchaseOrderServiceProvider);
  return await service.allActive();
});
