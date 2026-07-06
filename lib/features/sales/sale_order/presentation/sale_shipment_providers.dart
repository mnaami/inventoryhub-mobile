import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/paging/paged_list_notifier.dart';
import '../../../../core/paging/paged_state.dart';
import '../../../../l10n/app_localizations.dart';
import '../domain/sale_order.dart';
import '../domain/sale_order_enums.dart';
import '../domain/sale_order_usecases.dart';
import 'sale_order_providers.dart' show saleOrderServiceProvider, DatePreset;

class SaleShipmentListCriteria {
  const SaleShipmentListCriteria({
    this.search = '',
    this.status,
    this.datePreset = DatePreset.all,
  });

  final String search;
  final ShipmentStatus? status;
  final DatePreset datePreset;

  SaleShipmentListCriteria copyWith({
    String? search,
    ShipmentStatus? status,
    bool clearStatus = false,
    DatePreset? datePreset,
  }) =>
      SaleShipmentListCriteria(
        search: search ?? this.search,
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
      search.isNotEmpty || status != null || datePreset != DatePreset.all;
}

class SaleShipmentCriteria extends Notifier<SaleShipmentListCriteria> {
  @override
  SaleShipmentListCriteria build() => const SaleShipmentListCriteria();

  void setSearch(String v) => state = state.copyWith(search: v);
  void setStatus(ShipmentStatus? v) =>
      state = state.copyWith(status: v, clearStatus: v == null);
  void setDatePreset(DatePreset v) => state = state.copyWith(datePreset: v);
  void reset() => state = const SaleShipmentListCriteria();
}

final saleShipmentCriteriaProvider =
    NotifierProvider<SaleShipmentCriteria, SaleShipmentListCriteria>(
        SaleShipmentCriteria.new);

class SaleShipmentListNotifier extends PagedListNotifier<SaleShipmentListItem> {
  @override
  int get pageSize => SaleOrderService.pageSize;

  @override
  PagedState<SaleShipmentListItem> build() {
    ref.listen(saleShipmentCriteriaProvider, (_, __) => reload());
    return super.build();
  }

  @override
  Future<List<SaleShipmentListItem>> fetch(int page) {
    final c = ref.read(saleShipmentCriteriaProvider);
    return ref.read(saleOrderServiceProvider).listShipments(
          page: page,
          status: c.status,
          from: c.from,
          to: c.to,
          search: c.search,
        );
  }
}

final saleShipmentListProvider =
    NotifierProvider<SaleShipmentListNotifier, PagedState<SaleShipmentListItem>>(
        SaleShipmentListNotifier.new);

String shipmentStatusLabel(AppLocalizations l10n, ShipmentStatus s) =>
    switch (s) {
      ShipmentStatus.shipped => l10n.shipStatusShipped,
      ShipmentStatus.inTransit => l10n.shipStatusInTransit,
      ShipmentStatus.delivered => l10n.shipStatusDelivered,
      ShipmentStatus.returned => l10n.shipStatusReturned,
    };
