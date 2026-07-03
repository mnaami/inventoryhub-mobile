import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../app/theme/app_tokens.dart';
import '../../../sale_order/domain/sale_order.dart';
import '../../../sale_order/domain/sale_order_enums.dart';
import '../../../sale_order/presentation/record_payment_screen.dart';
import '../../../sale_order/presentation/sale_order_edit_screen.dart';
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
    await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => RecordPaymentScreen(order: target!)));
    ref.invalidate(customerOrdersProvider(customer.id));
    ref.invalidate(customerOutstandingProvider(customer.id));
  }

  Future<void> _call(BuildContext context) async {
    var phone = customer.phones.length == 1 ? customer.phones.first : null;
    phone ??= await showModalBottomSheet<String>(
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
              child: Text('Call which number?',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            const Divider(),
            for (final p in customer.phones)
              ListTile(
                leading: const Icon(Icons.phone_outlined),
                title: Text(p),
                onTap: () => Navigator.pop(context, p),
              ),
          ],
        ),
      ),
    );
    if (phone == null) return;
    final uri = Uri(scheme: 'tel', path: phone);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not launch phone call to $phone')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error launching call: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final outstanding = ref.watch(customerOutstandingProvider(customer.id));
    final showRecordPayment =
        outstanding.maybeWhen(data: (v) => v > 0, orElse: () => false);
    final showCall = customer.phones.isNotEmpty;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _newOrder(context, ref),
            icon: const Icon(Icons.add_shopping_cart_outlined, size: 18),
            label: const Text('New Order'),
          ),
        ),
        if (showRecordPayment) ...[
          const SizedBox(width: AppTokens.space8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _recordPayment(context, ref),
              icon: const Icon(Icons.payment_outlined, size: 18),
              label: const Text('Record Payment'),
            ),
          ),
        ],
        if (showCall) ...[
          const SizedBox(width: AppTokens.space8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _call(context),
              icon: const Icon(Icons.call_outlined, size: 18),
              label: const Text('Call'),
            ),
          ),
        ],
      ],
    );
  }
}
