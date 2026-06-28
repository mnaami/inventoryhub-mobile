import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/format/quantity_format.dart';
import '../../../../core/providers.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../production/production_order/presentation/production_order_detail_screen.dart';
import '../../../purchasing/purchase_order/presentation/purchase_order_detail_screen.dart';
import '../../../sales/sale_order/presentation/sale_order_detail_screen.dart';
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
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(productHistoryProvider(productId));
          await ref.read(productHistoryProvider(productId).future);
        },
        child: AsyncValueView<List<StockMovement>>(
          value: history,
          data: (list) => list.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 220),
                    Center(child: Text('No movements yet.')),
                  ],
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) =>
                      _MovementTile(movement: list[i]),
                ),
        ),
      ),
    );
  }
}

class _MovementTile extends ConsumerWidget {
  const _MovementTile({required this.movement});
  final StockMovement movement;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final positive = movement.quantity >= 0;
    final color = positive ? Colors.green.shade700 : Colors.red.shade700;
    final tappable = _sourceLabel(movement) != null;

    return ListTile(
      leading: Icon(
        positive ? Icons.south_west : Icons.north_east,
        color: color,
      ),
      title: Text(_title(movement)),
      subtitle: Text(_subtitle(movement)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${positive ? '+' : '-'}${formatQty(movement.quantity.abs())}',
            style: TextStyle(fontWeight: FontWeight.w600, color: color),
          ),
          if (tappable)
            const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Icon(Icons.chevron_right, size: 18),
            ),
        ],
      ),
      onTap: tappable ? () => _openSource(context, ref, movement) : null,
    );
  }

  // Friendly heading for the row, derived from the source document and
  // direction rather than the raw 'in'/'out' wire value.
  String _title(StockMovement m) {
    switch (m.referenceType) {
      case 'purchase_order_receipt':
        return 'Received';
      case 'sale_order_shipping':
        return 'Shipped';
      case 'production_order':
        return m.quantity >= 0 ? 'Produced' : 'Consumed';
      default:
        switch (m.type) {
          case MovementType.inbound:
            return 'Stock in';
          case MovementType.outbound:
            return 'Stock out';
          case MovementType.adjustment:
            return 'Adjustment';
        }
    }
  }

  String _subtitle(StockMovement m) {
    final parts = <String>[_fmtDate(m.createdAt)];
    final src = _sourceLabel(m);
    if (src != null) parts.add(src);
    if (m.notes != null && m.notes!.isNotEmpty) parts.add(m.notes!);
    return parts.join('  ·  ');
  }

  // A human label for the source document, or null when there is nothing to
  // navigate to (e.g. a manual adjustment).
  String? _sourceLabel(StockMovement m) {
    if (m.referenceId == null) return null;
    switch (m.referenceType) {
      case 'purchase_order_receipt':
        return 'Purchase order';
      case 'sale_order_shipping':
        return 'Sale order';
      case 'production_order':
        return 'Production order';
      default:
        return null;
    }
  }

  String _fmtDate(DateTime dt) {
    final l = dt.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${l.year}-${two(l.month)}-${two(l.day)} '
        '${two(l.hour)}:${two(l.minute)}';
  }

  // Resolves the movement's source document to an order and opens its detail
  // screen. Receipts/shipments are looked up to their parent order.
  Future<void> _openSource(
      BuildContext context, WidgetRef ref, StockMovement m) async {
    final db = ref.read(appDatabaseProvider);
    Widget? screen;
    switch (m.referenceType) {
      case 'purchase_order_receipt':
        final poId =
            await db.purchaseOrderReceiptDao.purchaseOrderIdFor(m.referenceId!);
        if (poId != null) screen = PurchaseOrderDetailScreen(orderId: poId);
        break;
      case 'sale_order_shipping':
        final soId =
            await db.saleOrderShippingDao.saleOrderIdFor(m.referenceId!);
        if (soId != null) screen = SaleOrderDetailScreen(orderId: soId);
        break;
      case 'production_order':
        screen = ProductionOrderDetailScreen(orderId: m.referenceId!);
        break;
    }
    if (!context.mounted) return;
    if (screen != null) {
      final target = screen;
      await Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => target));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Source document no longer exists.')),
      );
    }
  }
}
