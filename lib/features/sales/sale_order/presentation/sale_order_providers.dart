import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/paging/paged_list_notifier.dart';
import '../../../../core/paging/paged_state.dart';
import '../../../../core/providers.dart';
import '../data/document_counter_dao.dart';
import '../data/sale_order_dao.dart';
import '../data/sale_order_payment_dao.dart';
import '../data/sale_order_repository_impl.dart';
import '../data/sale_order_shipping_dao.dart';
import '../domain/sale_order.dart';
import '../domain/sale_order_enums.dart';
import '../domain/sale_order_usecases.dart';

final saleDashboardProvider = FutureProvider((ref) =>
    ref.watch(saleOrderServiceProvider).dashboard());

final saleOrderServiceProvider = Provider<SaleOrderService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final session = ref.watch(sessionProvider);
  return SaleOrderService(
    repository: SaleOrderRepositoryImpl(SaleOrderDao(db),
        SaleOrderPaymentDao(db), SaleOrderShippingDao(db),
        DocumentCounterDao(db)),
    ids: ref.watch(idGeneratorProvider),
    organizationId: session.organizationId,
    userId: session.userId,
  );
});

class SaleOrderFilter extends Notifier<OrderStatus?> {
  @override
  OrderStatus? build() => null;
  void set(OrderStatus? status) => state = status;
}

final saleOrderFilterProvider =
    NotifierProvider<SaleOrderFilter, OrderStatus?>(SaleOrderFilter.new);

final saleOrdersProvider = FutureProvider<List<SaleOrder>>((ref) {
  return ref
      .watch(saleOrderServiceProvider)
      .list(status: ref.watch(saleOrderFilterProvider));
});

final saleOrderProvider = FutureProvider.family<SaleOrder?, String>(
    (ref, id) => ref.watch(saleOrderServiceProvider).get(id));

final saleOrderItemsProvider =
    FutureProvider.family<List<SaleOrderItem>, String>(
        (ref, id) => ref.watch(saleOrderServiceProvider).items(id));

final saleOrderPaymentsProvider =
    FutureProvider.family<List<SaleOrderPayment>, String>(
        (ref, id) => ref.watch(saleOrderServiceProvider).payments(id));

final saleOrderShipmentsProvider =
    FutureProvider.family<List<SaleOrderShipping>, String>(
        (ref, id) => ref.watch(saleOrderServiceProvider).shipments(id));

String orderStatusLabel(OrderStatus s) => switch (s) {
      OrderStatus.draft => 'Draft',
      OrderStatus.confirmed => 'Confirmed',
      OrderStatus.processing => 'Processing',
      OrderStatus.shipped => 'Shipped',
      OrderStatus.delivered => 'Delivered',
      OrderStatus.cancelled => 'Cancelled',
    };

String paymentStatusLabel(PaymentStatus s) => switch (s) {
      PaymentStatus.notPaid => 'Not paid',
      PaymentStatus.partial => 'Partial',
      PaymentStatus.paid => 'Paid',
    };

String shippingStatusLabel(ShippingStatus s) => switch (s) {
      ShippingStatus.notShipped => 'Not shipped',
      ShippingStatus.partiallyShipped => 'Partially shipped',
      ShippingStatus.fullyShipped => 'Fully shipped',
    };

enum DatePreset { all, today, week, month }

class SaleOrderListCriteria {
  const SaleOrderListCriteria({
    this.search = '',
    this.status,
    this.paymentStatus,
    this.shippingStatus,
    this.datePreset = DatePreset.all,
  });

  final String search;
  final OrderStatus? status;
  final PaymentStatus? paymentStatus;
  final ShippingStatus? shippingStatus;
  final DatePreset datePreset;

  SaleOrderListCriteria copyWith({
    String? search,
    OrderStatus? status,
    bool clearStatus = false,
    PaymentStatus? paymentStatus,
    bool clearPaymentStatus = false,
    ShippingStatus? shippingStatus,
    bool clearShippingStatus = false,
    DatePreset? datePreset,
  }) =>
      SaleOrderListCriteria(
        search: search ?? this.search,
        status: clearStatus ? null : (status ?? this.status),
        paymentStatus:
            clearPaymentStatus ? null : (paymentStatus ?? this.paymentStatus),
        shippingStatus:
            clearShippingStatus ? null : (shippingStatus ?? this.shippingStatus),
        datePreset: datePreset ?? this.datePreset,
      );

  /// Inclusive lower bound (UTC) for the selected preset, or null for "all".
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

  /// Inclusive upper bound (UTC, end-of-day) for the selected preset, or null
  /// for "all"/open-ended presets. None of the current presets cap the
  /// upper end (they all run through "now"), so this is always null today;
  /// it exists to demonstrate the `from`/`to` convention for later screens.
  DateTime? get to => null;

  bool get hasActiveFilters =>
      search.isNotEmpty ||
      status != null ||
      paymentStatus != null ||
      shippingStatus != null ||
      datePreset != DatePreset.all;
}

class SaleOrderCriteria extends Notifier<SaleOrderListCriteria> {
  @override
  SaleOrderListCriteria build() => const SaleOrderListCriteria();

  void setSearch(String v) => state = state.copyWith(search: v);
  void setStatus(OrderStatus? v) =>
      state = state.copyWith(status: v, clearStatus: v == null);
  void setPaymentStatus(PaymentStatus? v) =>
      state = state.copyWith(paymentStatus: v, clearPaymentStatus: v == null);
  void setShippingStatus(ShippingStatus? v) =>
      state = state.copyWith(shippingStatus: v, clearShippingStatus: v == null);
  void setDatePreset(DatePreset v) => state = state.copyWith(datePreset: v);
  void reset() => state = const SaleOrderListCriteria();
}

final saleOrderCriteriaProvider =
    NotifierProvider<SaleOrderCriteria, SaleOrderListCriteria>(
        SaleOrderCriteria.new);

class SaleOrderListNotifier extends PagedListNotifier<SaleOrder> {
  @override
  int get pageSize => SaleOrderService.pageSize;

  @override
  PagedState<SaleOrder> build() {
    ref.listen(saleOrderCriteriaProvider, (_, __) => reload());
    return super.build();
  }

  @override
  Future<List<SaleOrder>> fetch(int page) {
    final c = ref.read(saleOrderCriteriaProvider);
    return ref.read(saleOrderServiceProvider).list(
          page: page,
          search: c.search,
          status: c.status,
          paymentStatus: c.paymentStatus,
          shippingStatus: c.shippingStatus,
          from: c.from,
          to: c.to,
        );
  }
}

final saleOrderListProvider =
    NotifierProvider<SaleOrderListNotifier, PagedState<SaleOrder>>(
        SaleOrderListNotifier.new);

final saleOrderCountProvider = FutureProvider.family<int, ({DateTime startDate, DateTime endDate})>((ref, params) async {
  final service = ref.watch(saleOrderServiceProvider);
  return await service.countByDateRange(params.startDate, params.endDate);
});

final saleOrderAmountProvider = FutureProvider.family<double, ({DateTime startDate, DateTime endDate})>((ref, params) async {
  final service = ref.watch(saleOrderServiceProvider);
  return await service.totalAmountByDateRange(params.startDate, params.endDate);
});

final allSaleOrdersProvider = FutureProvider<List<SaleOrder>>((ref) async {
  final service = ref.watch(saleOrderServiceProvider);
  return await service.allActive();
});

