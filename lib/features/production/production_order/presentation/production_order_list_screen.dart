import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/l10n/l10n_ext.dart';
import '../../../../core/widgets/async_value_view.dart';
import 'create_production_order_screen.dart';
import 'production_order_detail_screen.dart';
import 'production_order_providers.dart';

class ProductionOrderListScreen extends ConsumerWidget {
  const ProductionOrderListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final orders = ref.watch(productionOrdersProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.productionOrdersListTitle)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const CreateProductionOrderScreen())),
        child: const Icon(Icons.add),
      ),
      body: AsyncValueView(
        value: orders,
        data: (list) => list.isEmpty
            ? Center(child: Text(l10n.productionOrdersEmpty))
            : ListView.builder(
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final o = list[i];
                  return ListTile(
                    title: Text(o.orderNumber),
                    subtitle: Text(l10n.productionOrderListSubtitle(
                        '${o.quantity}', productionStatusLabel(l10n, o.status))),
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
