import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventoryhub_mobile/app/currency/currency_controller.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../sale_order/domain/sale_order_enums.dart';
import '../../sale_order/presentation/sale_order_providers.dart';
import '../../../../l10n/app_localizations.dart';
import '../domain/customer.dart';
import 'add_edit_customer_screen.dart';
import 'customer_providers.dart';

class CustomerDetailScreen extends ConsumerWidget {
  const CustomerDetailScreen({super.key, required this.customerId});
  final String customerId;

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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        orderStatusLabel(AppLocalizations.of(context), status),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final money = ref.watch(moneyFormatterProvider);
    final customer = ref.watch(customerProvider(customerId));
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Customer')),
      body: AsyncValueView<Customer?>(
        value: customer,
        data: (c) {
          if (c == null) return const Center(child: Text('Not found'));
          final initial = c.name.isNotEmpty ? c.name[0].toUpperCase() : '?';

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              // Header Highlight Card (Initial + Name + Outstanding Balance)
              AppCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: scheme.primary.withOpacity(0.08),
                      child: Text(
                        initial,
                        style: TextStyle(
                          color: scheme.primary,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      c.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    Consumer(builder: (context, ref, _) {
                      final outstanding = ref.watch(customerOutstandingProvider(customerId));
                      return outstanding.maybeWhen(
                        data: (v) => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Outstanding Balance',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              money(v),
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: v > 0 ? scheme.error : scheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        orElse: () => const SizedBox.shrink(),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: AppTokens.space16),

              // Contact & Terms Info Card
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  children: [
                    if (c.email != null && c.email!.isNotEmpty) ...[
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.email_outlined, color: scheme.primary),
                        title: Text(
                          c.email!,
                          style: theme.textTheme.bodyLarge?.copyWith(color: scheme.onSurface),
                        ),
                      ),
                      const Divider(height: 1),
                    ],
                    if (c.phones.isNotEmpty) ...[
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.phone_outlined, color: scheme.primary),
                        title: Text(
                          c.phones.join(', '),
                          style: theme.textTheme.bodyLarge?.copyWith(color: scheme.onSurface),
                        ),
                      ),
                      const Divider(height: 1),
                    ],
                    if (c.address != null && c.address!.isNotEmpty) ...[
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.location_on_outlined, color: scheme.primary),
                        title: Text(
                          c.address!,
                          style: theme.textTheme.bodyLarge?.copyWith(color: scheme.onSurface),
                        ),
                      ),
                      const Divider(height: 1),
                    ],
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.schedule_outlined, color: scheme.primary),
                      title: Text(
                        'Payment terms: ${c.paymentTerms} days',
                        style: theme.textTheme.bodyLarge?.copyWith(color: scheme.onSurface),
                      ),
                    ),
                    if (c.creditLimit != null) ...[
                      const Divider(height: 1),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.credit_card_outlined, color: scheme.primary),
                        title: Text(
                          'Credit limit: \$${c.creditLimit}',
                          style: theme.textTheme.bodyLarge?.copyWith(color: scheme.onSurface),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppTokens.space24),

              // Section Header
              Text(
                'Orders',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppTokens.space8),

              // Orders Card List
              Consumer(builder: (context, ref, _) {
                final orders = ref.watch(customerOrdersProvider(customerId));
                return orders.maybeWhen(
                  data: (list) {
                    if (list.isEmpty) {
                      return const AppCard(
                        padding: EdgeInsets.all(24),
                        child: Center(
                          child: Text('No orders yet'),
                        ),
                      );
                    }
                    return AppCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          for (int i = 0; i < list.length; i++) ...[
                            ListTile(
                              title: Text(
                                list[i].soNumber,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: scheme.onSurface,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Row(
                                  children: [
                                    _buildStatusBadge(context, list[i].status),
                                  ],
                                ),
                              ),
                              trailing: Text(
                                money(list[i].totalAmount),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: scheme.onSurface,
                                ),
                              ),
                            ),
                            if (i < list.length - 1) const Divider(height: 1),
                          ],
                        ],
                      ),
                    );
                  },
                  orElse: () => const SizedBox.shrink(),
                );
              }),
              const SizedBox(height: AppTokens.space24),

              // Edit Button
              OutlinedButton.icon(
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit'),
                onPressed: () async {
                  await Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => AddEditCustomerScreen(existing: c)));
                  ref.invalidate(customerProvider(customerId));
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
