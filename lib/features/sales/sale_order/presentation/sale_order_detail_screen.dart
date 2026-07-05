import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/result/app_exception.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../app/theme/app_tokens.dart';
import 'package:inventoryhub_mobile/app/currency/currency_controller.dart';
import '../../../../core/l10n/l10n_ext.dart';
import '../../../../l10n/app_localizations.dart';
import '../../customer/presentation/customer_providers.dart';
import '../../../../core/format/date_format.dart';
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
    final l10n = context.l10n;
    final money = ref.watch(moneyFormatterProvider);
    final order = ref.watch(saleOrderProvider(orderId));
    final service = ref.read(saleOrderServiceProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.soDetailTitle)),
      body: AsyncValueView<SaleOrder?>(
        value: order,
        data: (o) {
          if (o == null) return Center(child: Text(l10n.soOrderNotFound));
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
                              Expanded(
                                child: Row(
                                  children: [
                                    _buildStatusIcon(o.status),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            o.soNumber,
                                            style: theme.textTheme.headlineMedium?.copyWith(
                                              fontWeight: FontWeight.w800,
                                              color: scheme.onSurface,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            money(o.totalAmount),
                                            style: theme.textTheme.titleLarge?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: scheme.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.person_outline,
                                  size: 16, color: scheme.onSurfaceVariant),
                              const SizedBox(width: 4),
                              Consumer(
                                builder: (context, ref, child) {
                                  final customerAsync =
                                      ref.watch(customerProvider(o.customerId));
                                  return customerAsync.when(
                                    data: (customer) => Text(
                                      customer?.name ?? l10n.soUnknownCustomer,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: scheme.onSurfaceVariant,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    loading: () => Text(
                                      l10n.soLoadingCustomer,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: scheme.onSurfaceVariant
                                            .withOpacity(0.6),
                                      ),
                                    ),
                                    error: (_, __) => Text(
                                      l10n.soUnknownCustomer,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: scheme.onSurfaceVariant
                                            .withOpacity(0.6),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildStatusBadge(context, o.status, l10n),
                              _buildPaymentStatusBadge(context, o.paymentStatus, l10n),
                              _buildShippingStatusBadge(context, o.shippingStatus, l10n),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTokens.space24),

                    // Line Items Section
                    Text(
                      l10n.soLineItemsHeading,
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
                                  l10n.soLineQtyOrderedShipped(
                                      '${list[i].quantity}', '${list[i].shippedQuantity}'),
                                  style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                                ),
                                trailing: Text(
                                  money(list[i].totalPrice),
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
                      l10n.poPaymentsHeading,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppTokens.space8),
                    AsyncValueView<List<SaleOrderPayment>>(
                      value: payments,
                      data: (list) => list.isEmpty
                          ? AppCard(
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Text(l10n.poNoPaymentsYet),
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
                                        '${list[i].method.wire.toUpperCase().replaceAll('_', ' ')} • ${formatDateTime(list[i].paymentDate)}',
                                        style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                                      ),
                                      trailing: Text(
                                        money(list[i].amount),
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
                      l10n.soShipmentsHeading,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppTokens.space8),
                    AsyncValueView<List<SaleOrderShipping>>(
                      value: shipments,
                      data: (list) => list.isEmpty
                          ? AppCard(
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Text(l10n.soNoShipmentsYet),
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
    final l10n = context.l10n;
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline, size: 20),
              const SizedBox(width: 8),
              Text(l10n.soConfirmOrderButton),
            ],
          ),
        ),
      );
    } else if (o.status == OrderStatus.confirmed) {
      widgets.add(
        FilledButton(
          onPressed: () => _run(context, ref, () => service.process(o)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.play_circle_outline, size: 20),
              const SizedBox(width: 8),
              Text(l10n.soStartProcessingButton),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.payment, size: 18),
                    const SizedBox(width: 8),
                    Text(l10n.soAddPaymentButton),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.local_shipping_outlined, size: 18),
                    const SizedBox(width: 8),
                    Text(l10n.soShipItemsButton),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.local_shipping_outlined, size: 18),
              const SizedBox(width: 8),
              Text(l10n.soCreateShipmentTitle),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.payment, size: 20),
                const SizedBox(width: 8),
                Text(l10n.soRecordPaymentTitle),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.payment, size: 18),
                const SizedBox(width: 8),
                Text(l10n.soAddPaymentButton),
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
                title: l10n.poCancelOrderButton,
                message: l10n.poCancelOrderConfirm(o.soNumber),
                confirmLabel: l10n.poCancelOrderButton);
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
                l10n.soCancelOrderLabel,
                style: TextStyle(color: scheme.error, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      );
    }

    return widgets;
  }

  Color _orderStatusColor(OrderStatus status) => switch (status) {
        OrderStatus.draft => Colors.blueGrey,
        OrderStatus.confirmed => Colors.blue,
        OrderStatus.processing => Colors.indigo,
        OrderStatus.shipped => Colors.purple,
        OrderStatus.delivered => Colors.green,
        OrderStatus.cancelled => Colors.red,
      };

  IconData _orderStatusIcon(OrderStatus status) => switch (status) {
        OrderStatus.draft => Icons.edit_note_rounded,
        OrderStatus.confirmed => Icons.check_circle_outline_rounded,
        OrderStatus.processing => Icons.autorenew_rounded,
        OrderStatus.shipped => Icons.local_shipping_outlined,
        OrderStatus.delivered => Icons.task_alt_rounded,
        OrderStatus.cancelled => Icons.cancel_outlined,
      };

  Widget _buildStatusIcon(OrderStatus status) {
    final color = _orderStatusColor(status);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        shape: BoxShape.circle,
      ),
      child: Icon(_orderStatusIcon(status), color: color, size: 22),
    );
  }

  Widget _buildStatusBadge(
      BuildContext context, OrderStatus status, AppLocalizations l10n) {
    return _statusBadge(
      color: _orderStatusColor(status),
      icon: _orderStatusIcon(status),
      label: orderStatusLabel(l10n, status),
    );
  }

  Widget _buildPaymentStatusBadge(
      BuildContext context, PaymentStatus status, AppLocalizations l10n) {
    final color = switch (status) {
      PaymentStatus.notPaid => Colors.red,
      PaymentStatus.partial => Colors.amber,
      PaymentStatus.paid => Colors.green,
    };
    final icon = switch (status) {
      PaymentStatus.notPaid => Icons.money_off_rounded,
      PaymentStatus.partial => Icons.pie_chart_outline_rounded,
      PaymentStatus.paid => Icons.check_circle_outline_rounded,
    };
    return _statusBadge(color: color, icon: icon, label: paymentStatusLabel(l10n, status));
  }

  Widget _buildShippingStatusBadge(
      BuildContext context, ShippingStatus status, AppLocalizations l10n) {
    final color = switch (status) {
      ShippingStatus.notShipped => Colors.red,
      ShippingStatus.partiallyShipped => Colors.amber,
      ShippingStatus.fullyShipped => Colors.green,
    };
    final icon = switch (status) {
      ShippingStatus.notShipped => Icons.inventory_2_outlined,
      ShippingStatus.partiallyShipped => Icons.local_shipping_outlined,
      ShippingStatus.fullyShipped => Icons.local_shipping_rounded,
    };
    return _statusBadge(color: color, icon: icon, label: shippingStatusLabel(l10n, status));
  }

  Widget _statusBadge({required Color color, required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
