import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../app/theme/app_tokens.dart';
import '../../../sale_order/domain/sale_order.dart';
import '../../../sale_order/domain/sale_order_enums.dart';
import '../../../sale_order/presentation/record_payment_screen.dart';
import '../../../sale_order/presentation/sale_order_edit_screen.dart';
import '../../../sale_order/presentation/sale_order_providers.dart';
import '../../domain/customer.dart';
import '../customer_providers.dart';

/// Quick-action buttons at the top of the customer detail page: create an
/// order for this customer, record a payment against one of their unpaid
/// orders, or call them. Each action hides itself when it wouldn't apply.
class CustomerQuickActions extends ConsumerWidget {
  const CustomerQuickActions({super.key, required this.customer});
  final Customer customer;

  bool _isPayable(SaleOrder o) =>
      !o.isDraft && !o.isCancelled && o.paymentStatus != PaymentStatus.paid;

  Future<void> _newOrder(BuildContext context, WidgetRef ref) async {
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => SaleOrderEditScreen(customerId: customer.id)));
    ref.invalidate(customerOrdersProvider(customer.id));
    ref.invalidate(customerOutstandingProvider(customer.id));
  }

  Future<void> _recordPayment(BuildContext context, WidgetRef ref) async {
    final orders = await ref.read(customerOrdersProvider(customer.id).future);
    final payable = orders.where(_isPayable).toList();
    if (payable.isEmpty) return;

    var target = payable.length == 1 ? payable.first : null;
    if (target == null) {
      if (!context.mounted) return;
      target = await showModalBottomSheet<SaleOrder>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (_) => Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: ListView(
            shrinkWrap: true,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text('Select an order',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              const Divider(),
              for (final o in payable)
                ListTile(
                  title: Text(o.soNumber,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(o.paymentStatus.wire.replaceAll('_', ' ')),
                  onTap: () => Navigator.pop(context, o),
                ),
            ],
          ),
        ),
      );
    }
    if (target == null || !context.mounted) return;
    final chosen = target;
    await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => RecordPaymentScreen(order: chosen)));
    ref.invalidate(customerOrdersProvider(customer.id));
    ref.invalidate(customerOutstandingProvider(customer.id));
    ref.invalidate(saleOrdersProvider);
    ref.invalidate(saleOrderProvider(chosen.id));
    ref.invalidate(saleOrderPaymentsProvider(chosen.id));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final outstanding = ref.watch(customerOutstandingProvider(customer.id));
    final showRecordPayment =
        outstanding.maybeWhen(data: (v) => v > 0, orElse: () => false);

    if (showRecordPayment) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton.icon(
            onPressed: () => _newOrder(context, ref),
            icon: const Icon(Icons.add_shopping_cart_outlined, size: 18),
            label: const Text('New Order'),
          ),
          const SizedBox(height: AppTokens.space8),
          OutlinedButton.icon(
            onPressed: () => _recordPayment(context, ref),
            icon: const Icon(Icons.payment_outlined, size: 18),
            label: const Text('Record Payment'),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: () => _newOrder(context, ref),
            icon: const Icon(Icons.add_shopping_cart_outlined, size: 18),
            label: const Text('New Order'),
          ),
        ),
      ],
    );
  }
}
