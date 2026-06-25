import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../domain/stock_movement.dart';
import 'stock_providers.dart';

class ProductHistoryView extends ConsumerWidget {
  const ProductHistoryView({super.key, required this.productId});
  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(productHistoryProvider(productId));
    return Scaffold(
      appBar: AppBar(title: const Text('Stock history')),
      body: AsyncValueView<List<StockMovement>>(
        value: history,
        data: (list) => list.isEmpty
            ? const Center(child: Text('No movements yet.'))
            : ListView.builder(
                itemCount: list.length,
                itemBuilder: (_, i) => _tile(list[i]),
              ),
      ),
    );
  }

  Widget _tile(StockMovement m) {
    final positive = m.quantity >= 0;
    return ListTile(
      leading: Icon(
        positive ? Icons.arrow_downward : Icons.arrow_upward,
        color: positive ? Colors.green : Colors.red,
      ),
      title: Text('${m.type.name} · ${m.quantity}'),
      subtitle: m.notes == null ? null : Text(m.notes!),
      trailing: Text('${m.createdAt.toLocal()}'.split('.').first),
    );
  }
}
