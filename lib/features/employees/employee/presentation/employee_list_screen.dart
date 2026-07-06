import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/currency/currency_controller.dart';
import '../../../../core/l10n/l10n_ext.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../../core/widgets/empty_state.dart';
import '../domain/employee.dart';
import 'employee_providers.dart';

class EmployeeListScreen extends ConsumerWidget {
  const EmployeeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final employees = ref.watch(employeeListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.employeesTitle)),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () => context.push('/employees/new'),
        child: const Icon(Icons.add),
      ),
      body: AsyncValueView<List<Employee>>(
        value: employees,
        data: (list) {
          if (list.isEmpty) {
            return EmptyState(
              icon: Icons.badge_outlined,
              title: l10n.employeesEmpty,
            );
          }
          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) => _EmployeeTile(employee: list[i]),
          );
        },
      ),
    );
  }
}

class _EmployeeTile extends ConsumerWidget {
  const _EmployeeTile({required this.employee});
  final Employee employee;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final money = ref.watch(moneyFormatterProvider);
    final balance = ref.watch(employeeBalanceProvider(employee.id));

    return ListTile(
      title: Text(employee.name),
      subtitle: employee.isActive ? null : Text(l10n.employeeInactive),
      trailing: balance.when(
        data: (v) => Text(money(v)),
        loading: () => const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        error: (_, __) => const Icon(Icons.error_outline, size: 18),
      ),
      onTap: () => context.push('/employees/${employee.id}'),
    );
  }
}
