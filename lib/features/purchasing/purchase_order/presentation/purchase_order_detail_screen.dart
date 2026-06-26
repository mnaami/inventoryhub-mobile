import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/result/app_exception.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../domain/purchase_order.dart';
import '../domain/purchase_order_enums.dart';
import 'create_receipt_screen.dart';
import 'purchase_order_providers.dart';
import 'record_payment_screen.dart';

class PurchaseOrderDetailScreen extends ConsumerWidget {
  const PurchaseOrderDetailScreen({super.key, required this.orderId});
  final String orderId;

  void _refresh(WidgetRef ref) {
    ref.invalidate(purchaseOrderProvider(orderId));
    ref.invalidate(purchaseOrderItemsProvider(orderId));
    ref.invalidate(purchaseOrderReceiptsProvider(orderId));
    ref.invalidate(purchaseOrderPaymentsProvider(orderId));
    ref.invalidate(purchaseOrdersProvider);
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
    final order = ref.watch(purchaseOrderProvider(orderId));
    final service = ref.read(purchaseOrderServiceProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Purchase Order')),
      body: AsyncValueView<PurchaseOrder?>(
        value: order,
        data: (o) {
          if (o == null) return const Center(child: Text('Not found'));
          final items = ref.watch(purchaseOrderItemsProvider(orderId));
          final receipts = ref.watch(purchaseOrderReceiptsProvider(orderId));
          final payments = ref.watch(purchaseOrderPaymentsProvider(orderId));
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(o.orderNumber,
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(
                  '${poStatusLabel(o.status)} · ${paymentStatusLabel(o.paymentStatus)} · ${receiptStatusLabel(o.receiptStatus)}'),
              Text('Total: ${o.totalAmount.toStringAsFixed(2)}'),
              const Divider(),
              const Text('Lines'),
              AsyncValueView(
                value: items,
                data: (list) => Column(children: [
                  for (final i in list)
                    ListTile(
                      dense: true,
                      title: Text(i.productName),
                      subtitle: Text(
                          'Qty ${i.quantity} · received ${i.receivedQuantity}'),
                      trailing: Text(i.totalPrice.toStringAsFixed(2)),
                    ),
                ]),
              ),
              const Divider(),
              const Text('Receipts'),
              AsyncValueView(
                value: receipts,
                data: (list) => Column(children: [
                  for (final r in list)
                    ListTile(
                      dense: true,
                      title: Text(r.receiptNumber),
                      subtitle: Text(r.status.wire),
                      trailing: r.status == ReceiptDocStatus.draft
                          ? Row(mainAxisSize: MainAxisSize.min, children: [
                              TextButton(
                                  onPressed: () => _run(context, ref,
                                      () => service.postReceipt(o, r)),
                                  child: const Text('Post')),
                              TextButton(
                                  onPressed: () => _run(context, ref,
                                      () => service.cancelReceipt(r)),
                                  child: const Text('Cancel')),
                            ])
                          : null,
                    ),
                ]),
              ),
              const Divider(),
              const Text('Payments'),
              AsyncValueView(
                value: payments,
                data: (list) => Column(children: [
                  for (final p in list)
                    ListTile(
                      dense: true,
                      title: Text(p.paymentNumber),
                      subtitle: Text(p.status.wire),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text(p.amount.toStringAsFixed(2)),
                        if (p.status == PaymentDocStatus.draft) ...[
                          TextButton(
                              onPressed: () => _run(context, ref,
                                  () => service.postPayment(o, p)),
                              child: const Text('Post')),
                          TextButton(
                              onPressed: () => _run(
                                  context, ref, () => service.cancelPayment(p)),
                              child: const Text('Cancel')),
                        ],
                      ]),
                    ),
                ]),
              ),
              const Divider(),
              Wrap(spacing: 8, children: _actions(context, ref, service, o)),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _actions(BuildContext context, WidgetRef ref,
      dynamic service, PurchaseOrder o) {
    final canReceive = o.status == PurchaseOrderStatus.sent ||
        o.status == PurchaseOrderStatus.confirmed;
    final canPay = o.status != PurchaseOrderStatus.draft &&
        o.status != PurchaseOrderStatus.cancelled;
    final canCancel = o.status == PurchaseOrderStatus.draft ||
        o.status == PurchaseOrderStatus.sent ||
        o.status == PurchaseOrderStatus.confirmed;
    return [
      if (o.status == PurchaseOrderStatus.draft)
        FilledButton(
            onPressed: () => _run(context, ref, () => service.send(o)),
            child: const Text('Send')),
      if (o.status == PurchaseOrderStatus.sent)
        FilledButton(
            onPressed: () => _run(context, ref, () => service.confirm(o)),
            child: const Text('Confirm')),
      if (canReceive)
        OutlinedButton(
          onPressed: () async {
            await Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => CreateReceiptScreen(order: o)));
            _refresh(ref);
          },
          child: const Text('Receive goods'),
        ),
      if (canPay)
        OutlinedButton(
          onPressed: () async {
            await Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => RecordPaymentScreen(order: o)));
            _refresh(ref);
          },
          child: const Text('Add payment'),
        ),
      if (canCancel)
        TextButton(
          onPressed: () async {
            final ok = await confirmDialog(context,
                title: 'Cancel order',
                message: 'Cancel ${o.orderNumber}?',
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
