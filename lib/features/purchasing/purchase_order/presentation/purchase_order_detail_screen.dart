import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/result/app_exception.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../../core/format/money_format.dart';
import '../../../../core/l10n/l10n_ext.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../inventory/product/presentation/product_providers.dart';
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
    ref.invalidate(productProvider);
    ref.invalidate(productListProvider);
    ref.invalidate(lowStockProductsProvider);
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
    final order = ref.watch(purchaseOrderProvider(orderId));
    final service = ref.read(purchaseOrderServiceProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.poDetailTitle)),
      body: AsyncValueView<PurchaseOrder?>(
        value: order,
        data: (o) {
          if (o == null) return Center(child: Text(l10n.poNotFound));
          final items = ref.watch(purchaseOrderItemsProvider(orderId));
          final receipts = ref.watch(purchaseOrderReceiptsProvider(orderId));
          final payments = ref.watch(purchaseOrderPaymentsProvider(orderId));

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
                                o.orderNumber,
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: scheme.onSurface,
                                ),
                              ),
                              Text(
                                formatMoney(o.totalAmount),
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
                              _buildStatusBadge(context, o.status, l10n),
                              _buildPaymentStatusBadge(context, o.paymentStatus, l10n),
                              _buildReceiptStatusBadge(context, o.receiptStatus, l10n),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTokens.space24),

                    // Line Items Section
                    Text(
                      l10n.poLinesHeading,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppTokens.space8),
                    AsyncValueView<List<PurchaseOrderItem>>(
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
                                  l10n.poLineQtyOrderedReceived(
                                      '${list[i].quantity}', '${list[i].receivedQuantity}'),
                                  style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                                ),
                                trailing: Text(
                                  formatMoney(list[i].totalPrice),
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

                    // Receipts Section
                    Text(
                      l10n.poReceiptsHeading,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppTokens.space8),
                    AsyncValueView<List<PurchaseOrderReceipt>>(
                      value: receipts,
                      data: (list) => list.isEmpty
                          ? AppCard(
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Text(l10n.poNoReceiptsYet),
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
                                        child: Icon(Icons.archive_outlined, color: scheme.primary, size: 16),
                                      ),
                                      title: Text(
                                        list[i].receiptNumber,
                                        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                                      ),
                                      subtitle: Text(
                                        list[i].status.wire.toUpperCase(),
                                        style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                                      ),
                                      trailing: list[i].status == ReceiptDocStatus.draft
                                          ? Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                TextButton(
                                                  onPressed: () => _run(context, ref,
                                                      () => service.postReceipt(o, list[i])),
                                                  child: Text(l10n.poPostButton),
                                                ),
                                                TextButton(
                                                  onPressed: () => _run(context, ref,
                                                      () => service.cancelReceipt(list[i])),
                                                  child: Text(l10n.commonCancel),
                                                ),
                                              ],
                                            )
                                          : null,
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
                    AsyncValueView<List<PurchaseOrderPayment>>(
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
                                        list[i].status.wire.toUpperCase(),
                                        style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            formatMoney(list[i].amount),
                                            style: theme.textTheme.bodyLarge?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: list[i].status == PaymentDocStatus.posted ? Colors.green : null,
                                            ),
                                          ),
                                          if (list[i].status == PaymentDocStatus.draft) ...[
                                            const SizedBox(width: 8),
                                            TextButton(
                                              onPressed: () => _run(context, ref,
                                                  () => service.postPayment(o, list[i])),
                                              child: Text(l10n.poPostButton),
                                            ),
                                            TextButton(
                                              onPressed: () => _run(context, ref,
                                                  () => service.cancelPayment(list[i])),
                                              child: Text(l10n.commonCancel),
                                            ),
                                          ],
                                        ],
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

              // Fixed Bottom Actions Container
              Container(
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
                  children: _actions(context, ref, service, o),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _actions(BuildContext context, WidgetRef ref,
      dynamic service, PurchaseOrder o) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final canReceive = o.status == PurchaseOrderStatus.sent ||
        o.status == PurchaseOrderStatus.confirmed;
    final canPay = o.status != PurchaseOrderStatus.draft &&
        o.status != PurchaseOrderStatus.cancelled;
    final canCancel = o.status == PurchaseOrderStatus.draft ||
        o.status == PurchaseOrderStatus.sent ||
        o.status == PurchaseOrderStatus.confirmed;

    return [
      if (o.status == PurchaseOrderStatus.draft) ...[
        FilledButton(
          onPressed: () => _run(context, ref, () => service.send(o)),
          child: Text(l10n.poSendButton),
        ),
        const SizedBox(height: 12),
      ],
      if (o.status == PurchaseOrderStatus.sent) ...[
        FilledButton(
          onPressed: () => _run(context, ref, () => service.confirm(o)),
          child: Text(l10n.poConfirmButton),
        ),
        const SizedBox(height: 12),
      ],
      if (canReceive) ...[
        OutlinedButton(
          onPressed: () async {
            await Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => CreateReceiptScreen(order: o)));
            _refresh(ref);
          },
          child: Text(l10n.poReceiveGoodsButton),
        ),
        const SizedBox(height: 12),
      ],
      if (canPay) ...[
        OutlinedButton(
          onPressed: () async {
            await Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => RecordPaymentScreen(order: o)));
            _refresh(ref);
          },
          child: Text(l10n.poAddPaymentButton),
        ),
        const SizedBox(height: 12),
      ],
      if (canCancel) ...[
        TextButton(
          onPressed: () async {
            final ok = await confirmDialog(context,
                title: l10n.poCancelOrderButton,
                message: l10n.poCancelOrderConfirm(o.orderNumber),
                confirmLabel: l10n.poCancelOrderButton);
            if (ok && context.mounted) {
              await _run(context, ref, () => service.cancel(o));
            }
          },
          child: Text(
            l10n.poCancelOrderButton,
            style: TextStyle(color: scheme.error, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ];
  }

  Widget _buildStatusBadge(
      BuildContext context, PurchaseOrderStatus status, AppLocalizations l10n) {
    final color = switch (status) {
      PurchaseOrderStatus.draft => Colors.blueGrey,
      PurchaseOrderStatus.sent => Colors.blue,
      PurchaseOrderStatus.confirmed => Colors.indigo,
      PurchaseOrderStatus.received => Colors.green,
      PurchaseOrderStatus.cancelled => Colors.red,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        poStatusLabel(l10n, status),
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPaymentStatusBadge(
      BuildContext context, PaymentStatus status, AppLocalizations l10n) {
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
        paymentStatusLabel(l10n, status),
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildReceiptStatusBadge(
      BuildContext context, ReceiptStatus status, AppLocalizations l10n) {
    final color = switch (status) {
      ReceiptStatus.notReceived => Colors.red,
      ReceiptStatus.partial => Colors.amber,
      ReceiptStatus.fullyReceived => Colors.green,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        receiptStatusLabel(l10n, status),
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
