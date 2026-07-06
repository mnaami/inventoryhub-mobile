import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../app/theme/app_tokens.dart';
import 'package:inventoryhub_mobile/app/currency/currency_controller.dart';
import '../../purchase_order/domain/purchase_order_enums.dart';
import '../../purchase_order/presentation/purchase_order_providers.dart';
import '../../../../l10n/app_localizations.dart';
import '../domain/supplier.dart';
import 'add_edit_supplier_screen.dart';
import 'supplier_providers.dart';
import '../../purchase_order/presentation/purchase_order_list_screen.dart';
import '../../purchase_order/presentation/purchase_order_detail_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class SupplierDetailScreen extends ConsumerWidget {
  const SupplierDetailScreen({super.key, required this.supplierId});
  final String supplierId;

  Widget _buildStatusBadge(BuildContext context, PurchaseOrderStatus status) {
    final color = switch (status) {
      PurchaseOrderStatus.draft => Colors.blueGrey,
      PurchaseOrderStatus.sent => Colors.blue,
      PurchaseOrderStatus.confirmed => Colors.indigo,
      PurchaseOrderStatus.received => Colors.green,
      PurchaseOrderStatus.cancelled => Colors.red,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        poStatusLabel(AppLocalizations.of(context), status),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showContactInfoSheet(BuildContext context, Supplier s) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: scheme.onSurfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Contact Details',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              if (s.contactPerson != null && s.contactPerson!.isNotEmpty) ...[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.person_outline, color: scheme.primary),
                  title: Text(
                    s.contactPerson!,
                    style: theme.textTheme.bodyLarge?.copyWith(color: scheme.onSurface),
                  ),
                ),
                const Divider(height: 1),
              ],
              if (s.email != null && s.email!.isNotEmpty) ...[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.email_outlined, color: scheme.primary),
                  title: Text(
                    s.email!,
                    style: theme.textTheme.bodyLarge?.copyWith(color: scheme.onSurface),
                  ),
                  onTap: () async {
                    final Uri uri = Uri(scheme: 'mailto', path: s.email);
                    try {
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      }
                    } catch (_) {}
                  },
                ),
                const Divider(height: 1),
              ],
              if (s.phones.isNotEmpty) ...[
                for (final phone in s.phones) ...[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.phone_outlined, color: scheme.primary),
                    title: Text(
                      phone,
                      style: theme.textTheme.bodyLarge?.copyWith(color: scheme.onSurface),
                    ),
                    trailing: Icon(Icons.phone_forwarded, color: scheme.primary.withOpacity(0.7), size: 20),
                    onTap: () async {
                      final Uri uri = Uri(scheme: 'tel', path: phone);
                      try {
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Could not launch phone call to $phone')),
                            );
                          }
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error launching call: $e')),
                          );
                        }
                      }
                    },
                  ),
                  const Divider(height: 1),
                ],
              ],
              if (s.address != null && s.address!.isNotEmpty) ...[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.location_on_outlined, color: scheme.primary),
                  title: Text(
                    s.address!,
                    style: theme.textTheme.bodyLarge?.copyWith(color: scheme.onSurface),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final money = ref.watch(moneyFormatterProvider);
    final supplier = ref.watch(supplierProvider(supplierId));
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final supplierObj = supplier.asData?.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Supplier'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: supplierObj == null
                ? null
                : () async {
                    final saved = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) => AddEditSupplierScreen(existing: supplierObj),
                      ),
                    );
                    if (saved == true) {
                      ref.invalidate(supplierProvider(supplierId));
                    }
                  },
          ),
        ],
      ),
      body: AsyncValueView<Supplier?>(
        value: supplier,
        data: (s) {
          if (s == null) return const Center(child: Text('Not found'));
          final initial = s.name.isNotEmpty ? s.name[0].toUpperCase() : '?';

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
                      s.name,
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
                      final outstanding = ref.watch(supplierOutstandingProvider(supplierId));
                      return outstanding.maybeWhen(
                        data: (v) => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Outstanding Payable',
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
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.contact_phone_outlined, color: scheme.primary),
                      title: Text(
                        'Contact Details',
                        style: theme.textTheme.bodyLarge?.copyWith(color: scheme.onSurface),
                      ),
                      subtitle: Text(
                        'Person, Phone, Email, Address',
                        style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                      trailing: Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
                      onTap: () => _showContactInfoSheet(context, s),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.schedule_outlined, color: scheme.primary),
                      title: Text(
                        'Payment terms: ${s.paymentTerms} days',
                        style: theme.textTheme.bodyLarge?.copyWith(color: scheme.onSurface),
                      ),
                    ),
                    if (s.creditLimit != null) ...[
                      const Divider(height: 1),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.credit_card_outlined, color: scheme.primary),
                        title: Text(
                          'Credit limit: \$${s.creditLimit}',
                          style: theme.textTheme.bodyLarge?.copyWith(color: scheme.onSurface),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppTokens.space24),

              // Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Purchase orders',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  Consumer(builder: (context, ref, _) {
                    final orders = ref.watch(supplierOrdersProvider(supplierId));
                    return orders.maybeWhen(
                      data: (list) {
                        if (list.isEmpty) return const SizedBox.shrink();
                        return TextButton(
                          onPressed: () {
                            ref.read(purchaseOrderCriteriaProvider.notifier).reset();
                            ref.read(purchaseOrderCriteriaProvider.notifier).setSupplierId(supplierId);
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const PurchaseOrderListScreen()),
                            );
                          },
                          child: const Text('View all'),
                        );
                      },
                      orElse: () => const SizedBox.shrink(),
                    );
                  }),
                ],
              ),
              const SizedBox(height: AppTokens.space8),

              // Purchase Orders Card List
              Consumer(builder: (context, ref, _) {
                final orders = ref.watch(supplierOrdersProvider(supplierId));
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
                    final displayList = list.take(5).toList();
                    return AppCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          for (int i = 0; i < displayList.length; i++) ...[
                            ListTile(
                              title: Text(
                                displayList[i].orderNumber,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: scheme.onSurface,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Row(
                                  children: [
                                    _buildStatusBadge(context, displayList[i].status),
                                  ],
                                ),
                              ),
                              trailing: Text(
                                money(displayList[i].totalAmount),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: scheme.onSurface,
                                ),
                              ),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => PurchaseOrderDetailScreen(orderId: displayList[i].id),
                                  ),
                                );
                              },
                            ),
                            if (i < displayList.length - 1) const Divider(height: 1),
                          ],
                        ],
                      ),
                    );
                  },
                  orElse: () => const SizedBox.shrink(),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
