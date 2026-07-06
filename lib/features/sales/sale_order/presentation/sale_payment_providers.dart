import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/paging/paged_list_notifier.dart';
import '../../../../core/paging/paged_state.dart';
import '../../../../l10n/app_localizations.dart';
import '../domain/sale_order.dart';
import '../domain/sale_order_enums.dart';
import '../domain/sale_order_usecases.dart';
import 'sale_order_providers.dart' show saleOrderServiceProvider, DatePreset;

class SalePaymentListCriteria {
  const SalePaymentListCriteria({
    this.search = '',
    this.method,
    this.status,
    this.datePreset = DatePreset.all,
  });

  final String search;
  final PaymentMethod? method;
  final PaymentRecordStatus? status;
  final DatePreset datePreset;

  SalePaymentListCriteria copyWith({
    String? search,
    PaymentMethod? method,
    bool clearMethod = false,
    PaymentRecordStatus? status,
    bool clearStatus = false,
    DatePreset? datePreset,
  }) =>
      SalePaymentListCriteria(
        search: search ?? this.search,
        method: clearMethod ? null : (method ?? this.method),
        status: clearStatus ? null : (status ?? this.status),
        datePreset: datePreset ?? this.datePreset,
      );

  /// Inclusive lower bound for the preset, or null for "all". Mirrors
  /// SaleOrderListCriteria.from.
  DateTime? get from {
    final now = DateTime.now();
    switch (datePreset) {
      case DatePreset.all:
        return null;
      case DatePreset.today:
        return DateTime(now.year, now.month, now.day);
      case DatePreset.week:
        return DateTime(now.year, now.month, now.day - (now.weekday - 1));
      case DatePreset.month:
        return DateTime(now.year, now.month, 1);
    }
  }

  /// Exclusive upper bound for the preset, or null for "all". Mirrors
  /// SaleOrderListCriteria.to.
  DateTime? get to {
    final now = DateTime.now();
    final tomorrowStart = DateTime(now.year, now.month, now.day + 1);
    switch (datePreset) {
      case DatePreset.all:
        return null;
      case DatePreset.today:
      case DatePreset.week:
        return tomorrowStart;
      case DatePreset.month:
        return DateTime(now.year, now.month + 1, 1);
    }
  }

  bool get hasActiveFilters =>
      search.isNotEmpty ||
      method != null ||
      status != null ||
      datePreset != DatePreset.all;
}

class SalePaymentCriteria extends Notifier<SalePaymentListCriteria> {
  @override
  SalePaymentListCriteria build() => const SalePaymentListCriteria();

  void setSearch(String v) => state = state.copyWith(search: v);
  void setMethod(PaymentMethod? v) =>
      state = state.copyWith(method: v, clearMethod: v == null);
  void setStatus(PaymentRecordStatus? v) =>
      state = state.copyWith(status: v, clearStatus: v == null);
  void setDatePreset(DatePreset v) => state = state.copyWith(datePreset: v);
  void reset() => state = const SalePaymentListCriteria();
}

final salePaymentCriteriaProvider =
    NotifierProvider<SalePaymentCriteria, SalePaymentListCriteria>(
        SalePaymentCriteria.new);

class SalePaymentListNotifier extends PagedListNotifier<SalePaymentListItem> {
  @override
  int get pageSize => SaleOrderService.pageSize;

  @override
  PagedState<SalePaymentListItem> build() {
    ref.listen(salePaymentCriteriaProvider, (_, __) => reload());
    return super.build();
  }

  @override
  Future<List<SalePaymentListItem>> fetch(int page) {
    final c = ref.read(salePaymentCriteriaProvider);
    return ref.read(saleOrderServiceProvider).listPayments(
          page: page,
          method: c.method,
          status: c.status,
          from: c.from,
          to: c.to,
          search: c.search,
        );
  }
}

final salePaymentListProvider =
    NotifierProvider<SalePaymentListNotifier, PagedState<SalePaymentListItem>>(
        SalePaymentListNotifier.new);

String paymentMethodLabel(AppLocalizations l10n, PaymentMethod m) =>
    switch (m) {
      PaymentMethod.cash => l10n.spMethodCash,
      PaymentMethod.creditCard => l10n.spMethodCreditCard,
      PaymentMethod.bankTransfer => l10n.spMethodBankTransfer,
      PaymentMethod.check => l10n.spMethodCheck,
      PaymentMethod.digitalWallet => l10n.spMethodDigitalWallet,
      PaymentMethod.other => l10n.spMethodOther,
    };

String paymentRecordStatusLabel(AppLocalizations l10n, PaymentRecordStatus s) =>
    switch (s) {
      PaymentRecordStatus.pending => l10n.spStatusPending,
      PaymentRecordStatus.completed => l10n.spStatusCompleted,
      PaymentRecordStatus.failed => l10n.spStatusFailed,
      PaymentRecordStatus.refunded => l10n.spStatusRefunded,
    };
