import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers.dart';
import '../data/document_counter_dao.dart';
import '../data/sale_order_dao.dart';
import '../data/sale_order_payment_dao.dart';
import '../data/sale_order_repository_impl.dart';
import '../data/sale_order_shipping_dao.dart';
import '../domain/sale_order.dart';
import '../domain/sale_order_enums.dart';
import '../domain/sale_order_usecases.dart';

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
