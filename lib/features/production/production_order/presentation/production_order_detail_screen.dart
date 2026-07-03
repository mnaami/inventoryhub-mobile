import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/l10n/l10n_ext.dart';
import '../../../../core/result/app_exception.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../../l10n/app_localizations.dart';
import '../domain/production_order.dart';
import 'production_order_providers.dart';

class ProductionOrderDetailScreen extends ConsumerWidget {
  const ProductionOrderDetailScreen({super.key, required this.orderId});
  final String orderId;

  Future<void> _run(BuildContext context, WidgetRef ref,
      Future<void> Function() action) async {
    final l10n = context.l10n;
    try {
      await action();
      ref.invalidate(productionOrderProvider(orderId));
      ref.invalidate(productionOrdersProvider);
      ref.invalidate(productionDashboardProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.productionActionDone)));
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
    final l10n = context.l10n;
    final order = ref.watch(productionOrderProvider(orderId));
    final service = ref.read(productionOrderServiceProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.productionOrderDetailTitle)),
      body: AsyncValueView(
        value: order,
        data: (o) {
          if (o == null) {
            return Center(child: Text(l10n.productionOrderNotFound));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(o.orderNumber,
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(l10n.productionOutputProductValue(o.productId)),
              Text(l10n.productionQuantityValue('${o.quantity}')),
              Text(l10n
                  .productionStatusValue(productionStatusLabel(l10n, o.status))),
              if (o.startDate != null)
                Text(l10n.productionStartedValue('${o.startDate}')),
              if (o.completionDate != null)
                Text(l10n.productionCompletedValue('${o.completionDate}')),
              const SizedBox(height: 24),
              ..._actions(context, ref, service, o, l10n),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _actions(BuildContext context, WidgetRef ref, dynamic service,
      ProductionOrder o, AppLocalizations l10n) {
    return [
      if (o.canStart)
        FilledButton.icon(
          icon: const Icon(Icons.play_arrow),
          label: Text(l10n.productionStartButton),
          onPressed: () => _run(context, ref, () => service.start(o)),
        ),
      if (o.canComplete) ...[
        const SizedBox(height: 8),
        FilledButton.icon(
          icon: const Icon(Icons.check),
          label: Text(l10n.productionCompleteButton),
          onPressed: () => _run(context, ref, () => service.complete(o)),
        ),
      ],
      if (!o.isTerminal) ...[
        const SizedBox(height: 8),
        OutlinedButton.icon(
          icon: const Icon(Icons.cancel_outlined),
          label: Text(l10n.productionCancelOrderButton),
          onPressed: () => _run(context, ref, () => service.cancel(o)),
        ),
      ],
    ];
  }
}
