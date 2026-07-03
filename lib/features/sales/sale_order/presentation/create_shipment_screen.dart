import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/result/app_exception.dart';
import '../../../../core/l10n/l10n_ext.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../app/theme/app_tokens.dart';
import '../domain/sale_order.dart';
import '../domain/sale_order_usecases.dart';
import 'sale_order_providers.dart';

class CreateShipmentScreen extends ConsumerStatefulWidget {
  const CreateShipmentScreen({super.key, required this.order});
  final SaleOrder order;
  @override
  ConsumerState<CreateShipmentScreen> createState() => _CreateShipmentState();
}

class _CreateShipmentState extends ConsumerState<CreateShipmentScreen> {
  final Map<String, double> _qty = {}; // saleOrderItemId -> ship qty
  String? _error;

  Future<void> _save() async {
    setState(() => _error = null);
    final items = await ref.read(saleOrderItemsProvider(widget.order.id).future);
    final lines = <ShipLine>[];
    for (final item in items) {
      final q = _qty[item.id] ?? 0;
      if (q > 0) lines.add(ShipLine(item: item, quantity: q));
    }
    try {
      await ref
          .read(saleOrderServiceProvider)
          .createShipment(widget.order, lines: lines);
      if (mounted) Navigator.of(context).pop(true);
    } on AppException catch (e) {
      setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = ref.watch(saleOrderItemsProvider(widget.order.id));
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.soCreateShipmentTitle)),
      body: AsyncValueView(
        value: items,
        data: (list) => ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // Header Context Card
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.local_shipping_outlined, color: scheme.primary, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.soShippingForOrder,
                          style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.order.soNumber,
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTokens.space24),

            // Section Header
            Text(
              l10n.soSelectQtyToShipHeading,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppTokens.space8),

            // Products list card
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (int i = 0; i < list.length; i++) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  list[i].productName,
                                  style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  l10n.poRemainingQty('${list[i].remainingQuantity}'),
                                  style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          SizedBox(
                            width: 90,
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                labelText: l10n.soShipQtyLabel,
                                filled: true,
                                fillColor: scheme.surfaceContainerLow,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                              ),
                              onChanged: (v) =>
                                  _qty[list[i].id] = double.tryParse(v) ?? 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (i < list.length - 1)
                      const Divider(),
                  ],
                ],
              ),
            ),

            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _error!,
                  style: TextStyle(color: scheme.error, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: AppTokens.space24),

            // Ship button
            FilledButton(
              onPressed: _save,
              child: Text(l10n.soShipButton),
            ),
          ],
        ),
      ),
    );
  }
}
