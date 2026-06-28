import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/app_card.dart';
import 'add_edit_customer_screen.dart';
import 'customer_detail_screen.dart';
import 'customer_providers.dart';

class CustomerListScreen extends ConsumerWidget {
  const CustomerListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customers = ref.watch(customersProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Customers')),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () async {
          await Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const AddEditCustomerScreen()));
        },
        child: const Icon(Icons.add),
      ),
      body: AsyncValueView(
        value: customers,
        data: (list) => list.isEmpty
            ? const EmptyState(
                icon: Icons.people_outline,
                title: 'No customers yet. Tap + to add one.')
            : ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final c = list[i];
                  final initial = c.name.isNotEmpty ? c.name[0].toUpperCase() : '?';
                  return AppCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => CustomerDetailScreen(customerId: c.id))),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: scheme.primary.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            initial,
                            style: TextStyle(
                              color: scheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: scheme.onSurface,
                                ),
                              ),
                              if (c.email != null && c.email!.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  c.email!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: scheme.onSurfaceVariant.withOpacity(0.5),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
