import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/result/app_exception.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../domain/sale_order.dart';
import '../domain/sale_order_enums.dart';
import 'create_shipment_screen.dart';
import 'record_payment_screen.dart';
import 'sale_order_providers.dart';

class SaleOrderDetailScreen extends ConsumerWidget {
  const SaleOrderDetailScreen({super.key, required this.orderId});
  final String orderId;

  void _refresh(WidgetRef ref) {
    ref.invalidate(saleOrderProvider(orderId));
    ref.invalidate(saleOrderItemsProvider(orderId));
    ref.invalidate(saleOrderPaymentsProvider(orderId));
    ref.invalidate(saleOrderShipmentsProvider(orderId));
    ref.invalidate(saleOrdersProvider);
  }

  Future<void> _run(BuildContext context, WidgetRef ref,
      Future<void> Function() action) async {
    try {
      await action();
      _refresh(ref);
    } on AppException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(saleOrderProvider(orderId));
    final service = ref.read(saleOrderServiceProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Sale Order')),
      body: AsyncValueView<SaleOrder?>(
        value: order,
        data: (o) {
          if (o == null) return const Center(child: Text('Not found'));
          final items = ref.watch(saleOrderItemsProvider(orderId));
          final payments = ref.watch(saleOrderPaymentsProvider(orderId));
          final shipments = ref.watch(saleOrderShipmentsProvider(orderId));
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(o.soNumber, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(
                  '${orderStatusLabel(o.status)} · ${paymentStatusLabel(o.paymentStatus)} · ${shippingStatusLabel(o.shippingStatus)}'),
              Text('Total: ${o.totalAmount.toStringAsFixed(2)}'),
              const Divider(),
              const Text('Lines'),
              AsyncValueView(
                value: items,
                data: (list) => Column(
                  children: [
                    for (final i in list)
                      ListTile(
                        dense: true,
                        title: Text(i.productName),
                        subtitle: Text(
                            'Qty ${i.quantity} · shipped ${i.shippedQuantity}'),
                        trailing: Text(i.totalPrice.toStringAsFixed(2)),
                      ),
                  ],
                ),
              ),
              const Divider(),
              const Text('Payments'),
              AsyncValueView(
                value: payments,
                data: (list) => Column(
                  children: [
                    for (final p in list)
                      ListTile(
                          dense: true,
                          title: Text(p.paymentNumber),
                          trailing: Text(p.amount.toStringAsFixed(2))),
                  ],
                ),
              ),
              const Divider(),
              const Text('Shipments'),
              AsyncValueView(
                value: shipments,
                data: (list) => Column(
                  children: [
                    for (final s in list)
                      ListTile(
                          dense: true,
                          title: Text(s.soShippingNumber),
                          subtitle: Text(s.status.wire)),
                  ],
                ),
              ),
              const Divider(),
              Wrap(
                spacing: 8,
                children: _actions(context, ref, service, o),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _actions(BuildContext context, WidgetRef ref,
      dynamic service, SaleOrder o) {
    final canCancel = o.status == OrderStatus.draft ||
        o.status == OrderStatus.confirmed ||
        o.status == OrderStatus.processing;
    final canPay = o.status != OrderStatus.draft &&
        o.status != OrderStatus.cancelled;
    final canShip = o.status == OrderStatus.confirmed ||
        o.status == OrderStatus.processing;
    return [
      if (o.status == OrderStatus.draft)
        FilledButton(
            onPressed: () => _run(context, ref, () => service.confirm(o)),
            child: const Text('Confirm')),
      if (o.status == OrderStatus.confirmed)
        FilledButton(
            onPressed: () => _run(context, ref, () => service.process(o)),
            child: const Text('Process')),
      if (canPay)
        OutlinedButton(
          onPressed: () async {
            await Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => RecordPaymentScreen(order: o)));
            _refresh(ref);
          },
          child: const Text('Add payment'),
        ),
      if (canShip)
        OutlinedButton(
          onPressed: () async {
            await Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => CreateShipmentScreen(order: o)));
            _refresh(ref);
          },
          child: const Text('Create shipment'),
        ),
      if (canCancel)
        TextButton(
          onPressed: () async {
            final ok = await confirmDialog(context,
                title: 'Cancel order',
                message: 'Cancel ${o.soNumber}?',
                confirmLabel: 'Cancel order');
            if (ok && context.mounted) {
              await _run(context, ref, () => service.cancel(o));
            }
          },
          child: const Text('Cancel order'),
        ),
    ];
  }
}
