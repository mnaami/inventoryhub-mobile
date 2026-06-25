import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../domain/stock_movement.dart';
import 'stock_providers.dart';

class StockMovementsScreen extends ConsumerWidget {
  const StockMovementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ledger = ref.watch(stockLedgerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Stock movements')),
      body: AsyncValueView<List<StockMovement>>(
        value: ledger,
        data: (list) => list.isEmpty
            ? const Center(child: Text('No stock movements yet.'))
            : ListView.builder(
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final m = list[i];
                  final positive = m.quantity >= 0;
                  return ListTile(
                    leading: Icon(
                      positive ? Icons.arrow_downward : Icons.arrow_upward,
                      color: positive ? Colors.green : Colors.red,
                    ),
                    title: Text('${m.type.name} · ${m.quantity}'),
                    subtitle: m.notes == null ? null : Text(m.notes!),
                    trailing:
                        Text('${m.createdAt.toLocal()}'.split('.').first),
                  );
                },
              ),
      ),
    );
  }
}
