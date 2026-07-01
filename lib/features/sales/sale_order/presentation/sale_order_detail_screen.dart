import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/result/app_exception.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../app/theme/app_tokens.dart';
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Order Details')),
      body: AsyncValueView<SaleOrder?>(
        value: order,
        data: (o) {
          if (o == null) return const Center(child: Text('Order not found'));
          final items = ref.watch(saleOrderItemsProvider(orderId));
          final payments = ref.watch(saleOrderPaymentsProvider(orderId));
          final shipments = ref.watch(saleOrderShipmentsProvider(orderId));
          
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  children: [
                    // Summary Header Card
                    AppCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                o.soNumber,
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: scheme.onSurface,
                                ),
                              ),
                              Text(
                                '\$${o.totalAmount.toStringAsFixed(2)}',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: scheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildStatusBadge(context, o.status),
                              _buildPaymentStatusBadge(context, o.paymentStatus),
                              _buildShippingStatusBadge(context, o.shippingStatus),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTokens.space24),

                    // Line Items Section
                    Text(
                      'Line Items',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppTokens.space8),
                    AsyncValueView<List<SaleOrderItem>>(
                      value: items,
                      data: (list) => AppCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            for (int i = 0; i < list.length; i++) ...[
                              ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                title: Text(
                                  list[i].productName,
                                  style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(
                                  'Qty ordered: ${list[i].quantity} · shipped: ${list[i].shippedQuantity}',
                                  style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                                ),
                                trailing: Text(
                                  '\$${list[i].totalPrice.toStringAsFixed(2)}',
                                  style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                              if (i < list.length - 1)
                                const Divider(),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTokens.space24),

                    // Payments Section
                    Text(
                      'Payments',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppTokens.space8),
                    AsyncValueView<List<SaleOrderPayment>>(
                      value: payments,
                      data: (list) => list.isEmpty
                          ? const AppCard(
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Text('No payments recorded yet.'),
                                ),
                              ),
                            )
                          : AppCard(
                              padding: EdgeInsets.zero,
                              child: Column(
                                children: [
                                  for (int i = 0; i < list.length; i++) ...[
                                    ListTile(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                      leading: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.08),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.check, color: Colors.green, size: 16),
                                      ),
                                      title: Text(
                                        list[i].paymentNumber,
                                        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                                      ),
                                      subtitle: Text(
                                        list[i].method.wire.toUpperCase().replaceAll('_', ' '),
                                        style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                                      ),
                                      trailing: Text(
                                        '\$${list[i].amount.toStringAsFixed(2)}',
                                        style: theme.textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ),
                                    if (i < list.length - 1)
                                      const Divider(),
                                  ],
                                ],
                              ),
                            ),
                    ),
                    const SizedBox(height: AppTokens.space24),

                    // Shipments Section
                    Text(
                      'Shipments',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppTokens.space8),
                    AsyncValueView<List<SaleOrderShipping>>(
                      value: shipments,
                      data: (list) => list.isEmpty
                          ? const AppCard(
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Text('No shipments recorded yet.'),
                                ),
                              ),
                            )
                          : AppCard(
                              padding: EdgeInsets.zero,
                              child: Column(
                                children: [
                                  for (int i = 0; i < list.length; i++) ...[
                                    ListTile(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                      leading: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: scheme.primary.withOpacity(0.08),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(Icons.local_shipping_outlined, color: scheme.primary, size: 16),
                                      ),
                                      title: Text(
                                        list[i].soShippingNumber,
                                        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                                      ),
                                      trailing: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.purple.withOpacity(0.08),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          list[i].status.wire.toUpperCase(),
                                          style: const TextStyle(color: Colors.purple, fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    if (i < list.length - 1)
                                      const Divider(),
                                  ],
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              
              // Fixed Bottom Actions Container (Only rendered when there are actions)
              Builder(
                builder: (context) {
                  final actions = _actions(context, ref, service, o);
                  if (actions.isEmpty) return const SizedBox.shrink();
                  
                  return Container(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: actions,
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _actions(BuildContext context, WidgetRef ref,
      dynamic service, SaleOrder o) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    
    final canCancel = o.status == OrderStatus.draft ||
        o.status == OrderStatus.confirmed ||
        o.status == OrderStatus.processing;
    final canPay = o.status != OrderStatus.draft &&
        o.status != OrderStatus.cancelled &&
        o.paymentStatus != PaymentStatus.paid;
    final canShip = (o.status == OrderStatus.confirmed ||
        o.status == OrderStatus.processing) &&
        o.shippingStatus != ShippingStatus.fullyShipped;
        
    final List<Widget> widgets = [];

    // 1. Primary transitions (Confirm or Process)
    if (o.status == OrderStatus.draft) {
      widgets.add(
        FilledButton(
          onPressed: () => _run(context, ref, () => service.confirm(o)),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_outline, size: 20),
              SizedBox(width: 8),
              Text('Confirm Order'),
            ],
          ),
        ),
      );
    } else if (o.status == OrderStatus.confirmed) {
      widgets.add(
        FilledButton(
          onPressed: () => _run(context, ref, () => service.process(o)),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.play_circle_outline, size: 20),
              SizedBox(width: 8),
              Text('Start Processing'),
            ],
          ),
        ),
      );
    }

    // Spacing between primary and secondary
    if (widgets.isNotEmpty && (canPay || canShip)) {
      widgets.add(const SizedBox(height: 12));
    }

    // 2. Secondary operational actions (Ship / Pay)
    if (canShip && canPay) {
      widgets.add(
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () async {
                  await Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => RecordPaymentScreen(order: o)));
                  _refresh(ref);
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.payment, size: 18),
                    SizedBox(width: 8),
                    Text('Add Payment'),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () async {
                  await Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => CreateShipmentScreen(order: o)));
                  _refresh(ref);
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.local_shipping_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('Ship Items'),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } else if (canShip) {
      widgets.add(
        OutlinedButton(
          onPressed: () async {
            await Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => CreateShipmentScreen(order: o)));
            _refresh(ref);
          },
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.local_shipping_outlined, size: 18),
              SizedBox(width: 8),
              Text('Create Shipment'),
            ],
          ),
        ),
      );
    } else if (canPay) {
      final isPostProcessing = o.status == OrderStatus.shipped || o.status == OrderStatus.delivered;
      if (isPostProcessing) {
        widgets.add(
          FilledButton(
            onPressed: () async {
              await Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => RecordPaymentScreen(order: o)));
              _refresh(ref);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.payment, size: 20),
                SizedBox(width: 8),
                Text('Record Payment'),
              ],
            ),
          ),
        );
      } else {
        widgets.add(
          OutlinedButton(
            onPressed: () async {
              await Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => RecordPaymentScreen(order: o)));
              _refresh(ref);
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.payment, size: 18),
                SizedBox(width: 8),
                Text('Add Payment'),
              ],
            ),
          ),
        );
      }
    }

    // Spacing before Cancel
    if (widgets.isNotEmpty && canCancel) {
      widgets.add(const SizedBox(height: 12));
    }

    // 3. Destructive actions (Cancel)
    if (canCancel) {
      widgets.add(
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.close_rounded, color: scheme.error, size: 18),
              const SizedBox(width: 8),
              Text(
                'Cancel Order',
                style: TextStyle(color: scheme.error, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      );
    }

    return widgets;
  }

  Widget _buildStatusBadge(BuildContext context, OrderStatus status) {
    final color = switch (status) {
      OrderStatus.draft => Colors.blueGrey,
      OrderStatus.confirmed => Colors.blue,
      OrderStatus.processing => Colors.indigo,
      OrderStatus.shipped => Colors.purple,
      OrderStatus.delivered => Colors.green,
      OrderStatus.cancelled => Colors.red,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        orderStatusLabel(status),
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPaymentStatusBadge(BuildContext context, PaymentStatus status) {
    final color = switch (status) {
      PaymentStatus.notPaid => Colors.red,
      PaymentStatus.partial => Colors.amber,
      PaymentStatus.paid => Colors.green,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        paymentStatusLabel(status),
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildShippingStatusBadge(BuildContext context, ShippingStatus status) {
    final color = switch (status) {
      ShippingStatus.notShipped => Colors.red,
      ShippingStatus.partiallyShipped => Colors.amber,
      ShippingStatus.fullyShipped => Colors.green,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        shippingStatusLabel(status),
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
