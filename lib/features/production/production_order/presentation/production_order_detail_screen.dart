import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/result/app_exception.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../domain/production_order.dart';
import 'production_order_providers.dart';

class ProductionOrderDetailScreen extends ConsumerWidget {
  const ProductionOrderDetailScreen({super.key, required this.orderId});
  final String orderId;

  Future<void> _run(BuildContext context, WidgetRef ref,
      Future<void> Function() action) async {
    try {
      await action();
      ref.invalidate(productionOrderProvider(orderId));
      ref.invalidate(productionOrdersProvider);
      ref.invalidate(productionDashboardProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Done.')));
      }
    } on AppException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(productionOrderProvider(orderId));
    final service = ref.read(productionOrderServiceProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Production order')),
      body: AsyncValueView(
        value: order,
        data: (o) {
          if (o == null) return const Center(child: Text('Order not found.'));
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(o.orderNumber,
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text('Output product: ${o.productId}'),
              Text('Quantity: ${o.quantity}'),
              Text('Status: ${productionStatusLabel(o.status)}'),
              if (o.startDate != null) Text('Started: ${o.startDate}'),
              if (o.completionDate != null)
                Text('Completed: ${o.completionDate}'),
              const SizedBox(height: 24),
              ..._actions(context, ref, service, o),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _actions(BuildContext context, WidgetRef ref,
      dynamic service, ProductionOrder o) {
    return [
      if (o.canStart)
        FilledButton.icon(
          icon: const Icon(Icons.play_arrow),
          label: const Text('Start'),
          onPressed: () => _run(context, ref, () => service.start(o)),
        ),
      if (o.canComplete) ...[
        const SizedBox(height: 8),
        FilledButton.icon(
          icon: const Icon(Icons.check),
          label: const Text('Complete (consume + produce)'),
          onPressed: () => _run(context, ref, () => service.complete(o)),
        ),
      ],
      if (!o.isTerminal) ...[
        const SizedBox(height: 8),
        OutlinedButton.icon(
          icon: const Icon(Icons.cancel_outlined),
          label: const Text('Cancel order'),
          onPressed: () => _run(context, ref, () => service.cancel(o)),
        ),
      ],
    ];
  }
}
