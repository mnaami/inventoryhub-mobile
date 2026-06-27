import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/async_value_view.dart';
import 'create_production_order_screen.dart';
import 'production_order_detail_screen.dart';
import 'production_order_providers.dart';

class ProductionOrderListScreen extends ConsumerWidget {
  const ProductionOrderListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(productionOrdersProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Production orders')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const CreateProductionOrderScreen())),
        child: const Icon(Icons.add),
      ),
      body: AsyncValueView(
        value: orders,
        data: (list) => list.isEmpty
            ? const Center(child: Text('No production orders yet.'))
            : ListView.builder(
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final o = list[i];
                  return ListTile(
                    title: Text(o.orderNumber),
                    subtitle: Text(
                        '${o.quantity} units · ${productionStatusLabel(o.status)}'),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) =>
                            ProductionOrderDetailScreen(orderId: o.id))),
                  );
                },
              ),
      ),
    );
  }
}
