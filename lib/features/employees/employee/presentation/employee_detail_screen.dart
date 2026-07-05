import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/currency/currency_controller.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../core/db/app_database.dart';
import '../../../../core/format/date_format.dart';
import '../../../../core/format/quantity_format.dart';
import '../../../../core/l10n/l10n_ext.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../inventory/product/presentation/product_providers.dart';
import '../../../production/production_order/presentation/production_order_detail_screen.dart';
import '../../payment/domain/employee_payment.dart';
import '../../payment/presentation/record_employee_payment_sheet.dart';
import '../../rate/presentation/employee_rate_sheet.dart';
import '../domain/employee.dart';
import 'add_edit_employee_screen.dart';
import 'employee_detail_providers.dart';
import 'employee_providers.dart';

class EmployeeDetailScreen extends ConsumerWidget {
  const EmployeeDetailScreen({super.key, required this.employeeId});
  final String employeeId;

  Future<void> _openRecordPayment(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => RecordEmployeePaymentSheet(employeeId: employeeId),
    );
  }

  Future<void> _openEdit(
      BuildContext context, WidgetRef ref, Employee employee) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddEditEmployeeScreen(existing: employee),
      ),
    );
    if (saved == true) {
      ref.invalidate(employeeProvider(employeeId));
    }
  }

  Future<void> _toggleActive(
      WidgetRef ref, Employee employee, bool active) async {
    await ref.read(employeeServiceProvider).setActive(employee.id, active);
    ref.invalidate(employeeProvider(employeeId));
    ref.invalidate(employeeListProvider);
  }

  Future<void> _openAddRate(
      BuildContext context, WidgetRef ref, List<ProductionPayRateRow> existingRates) async {
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => EmployeeRateSheet(
        employeeId: employeeId,
        existingProductIds: existingRates.map((r) => r.productId).toList(),
      ),
    );
  }

  Future<void> _openEditRate(
      BuildContext context, WidgetRef ref, ProductionPayRateRow rate) async {
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => EmployeeRateSheet(employeeId: employeeId, existing: rate),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final money = ref.watch(moneyFormatterProvider);
    final employeeAsync = ref.watch(employeeProvider(employeeId));
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.employeeDetailTitle),
        actions: [
          if (employeeAsync.asData?.value != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () =>
                  _openEdit(context, ref, employeeAsync.asData!.value!),
            ),
        ],
      ),
      body: AsyncValueView<Employee?>(
        value: employeeAsync,
        data: (employee) {
          if (employee == null) {
            return Center(child: Text(l10n.employeeNotFound));
          }
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              // Header card: name, balance, active toggle.
              AppCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: scheme.primary.withOpacity(0.08),
                      child: Text(
                        employee.name.isNotEmpty
                            ? employee.name[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          color: scheme.primary,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      employee.name,
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    Consumer(builder: (context, ref, _) {
                      final balance =
                          ref.watch(employeeBalanceProvider(employeeId));
                      return balance.maybeWhen(
                        data: (v) {
                          final owed = v > 0;
                          final label = owed
                              ? l10n.employeeOwedLabel
                              : l10n.employeeCreditLabel;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                label,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                money(v.abs()),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: owed ? scheme.error : scheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          );
                        },
                        orElse: () => const SizedBox.shrink(),
                      );
                    }),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.employeeActiveLabel),
                      value: employee.isActive,
                      onChanged: (v) => _toggleActive(ref, employee, v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTokens.space16),

              // Quick action: Record Payment.
              AppCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.payments_outlined, color: scheme.primary),
                  title: Text(l10n.employeeRecordPaymentAction),
                  onTap: () => _openRecordPayment(context, ref),
                ),
              ),
              const SizedBox(height: AppTokens.space24),

              // Earnings section.
              Text(
                l10n.employeeEarningsHeading,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppTokens.space8),
              Consumer(builder: (context, ref, _) {
                final earnings = ref.watch(employeeEarningsProvider(employeeId));
                return earnings.maybeWhen(
                  data: (list) {
                    if (list.isEmpty) {
                      return AppCard(
                        padding: const EdgeInsets.all(24),
                        child: Center(child: Text(l10n.employeeEarningsEmpty)),
                      );
                    }
                    return AppCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          for (int i = 0; i < list.length; i++) ...[
                            _EarningTile(earning: list[i]),
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

              // Payments section.
              Text(
                l10n.employeePaymentsHeading,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppTokens.space8),
              Consumer(builder: (context, ref, _) {
                final payments = ref.watch(employeePaymentsProvider(employeeId));
                return payments.maybeWhen(
                  data: (list) {
                    if (list.isEmpty) {
                      return AppCard(
                        padding: const EdgeInsets.all(24),
                        child: Center(child: Text(l10n.employeePaymentsEmpty)),
                      );
                    }
                    return AppCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          for (int i = 0; i < list.length; i++) ...[
                            _PaymentTile(payment: list[i]),
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

              // Piece-rate overrides section.
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.employeeRatesHeading,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  Consumer(builder: (context, ref, _) {
                    final rates = ref.watch(employeeRatesProvider(employeeId));
                    return TextButton.icon(
                      onPressed: () => _openAddRate(
                          context, ref, rates.asData?.value ?? const []),
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(l10n.employeeRateAddAction),
                    );
                  }),
                ],
              ),
              const SizedBox(height: AppTokens.space8),
              Consumer(builder: (context, ref, _) {
                final rates = ref.watch(employeeRatesProvider(employeeId));
                return rates.maybeWhen(
                  data: (list) {
                    if (list.isEmpty) {
                      return AppCard(
                        padding: const EdgeInsets.all(24),
                        child: Center(child: Text(l10n.employeeRatesEmpty)),
                      );
                    }
                    return AppCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          for (int i = 0; i < list.length; i++) ...[
                            _RateTile(
                              rate: list[i],
                              onTap: () =>
                                  _openEditRate(context, ref, list[i]),
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
            ],
          );
        },
      ),
    );
  }
}

class _EarningTile extends ConsumerWidget {
  const _EarningTile({required this.earning});
  final ProductionEarningRow earning;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final money = ref.watch(moneyFormatterProvider);
    final product = ref.watch(productProvider(earning.productId));
    final theme = Theme.of(context);

    return ListTile(
      title: Text(product.asData?.value?.name ?? ''),
      subtitle: Text(l10n.employeeQtyRateLine(
          formatQty(earning.quantity), money(earning.rate))),
      trailing: Text(
        money(earning.amount),
        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ProductionOrderDetailScreen(orderId: earning.productionOrderId),
          ),
        );
      },
    );
  }
}

class _PaymentTile extends ConsumerWidget {
  const _PaymentTile({required this.payment});
  final EmployeePayment payment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final money = ref.watch(moneyFormatterProvider);
    final theme = Theme.of(context);
    return ListTile(
      title: Text(payment.paymentNumber),
      subtitle: Text(formatDateTime(payment.paymentDate)),
      trailing: Text(
        money(payment.amount),
        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _RateTile extends ConsumerWidget {
  const _RateTile({required this.rate, required this.onTap});
  final ProductionPayRateRow rate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final money = ref.watch(moneyFormatterProvider);
    final product = ref.watch(productProvider(rate.productId));

    return ListTile(
      title: Text(product.asData?.value?.name ?? ''),
      trailing: Text(money(rate.rate)),
      onTap: onTap,
    );
  }
}
