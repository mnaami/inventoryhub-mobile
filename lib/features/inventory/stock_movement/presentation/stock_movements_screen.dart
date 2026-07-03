import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/l10n/l10n_ext.dart';
import '../domain/stock_movement.dart';
import 'stock_providers.dart';

class StockMovementsScreen extends ConsumerWidget {
  const StockMovementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final ledger = ref.watch(stockLedgerProvider);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.stockMovementsTitle)),
      body: AsyncValueView<List<StockMovement>>(
        value: ledger,
        data: (list) => list.isEmpty
            ? EmptyState(
                icon: Icons.swap_vert,
                title: l10n.stockMovementEmptyTitle,
                subtitle: l10n.stockMovementEmptySubtitle,
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTokens.space16,
                  vertical: AppTokens.space12,
                ),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final m = list[i];
                  final positive = m.quantity >= 0;
                  final color = positive ? AppTokens.inFg : AppTokens.outFg;
                  final icon =
                      positive ? Icons.arrow_downward : Icons.arrow_upward;
                  return Padding(
                    padding:
                        const EdgeInsets.only(bottom: AppTokens.space8),
                    child: AppCard(
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: positive ? AppTokens.inBg : AppTokens.outBg,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(icon, color: color, size: 18),
                          ),
                          const SizedBox(width: AppTokens.space12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${m.type.name} · ${m.quantity}',
                                  style: theme.textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                if (m.notes != null) ...[
                                  const SizedBox(height: AppTokens.space2),
                                  Text(
                                    m.notes!,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: AppTokens.space8),
                          Text(
                            '${m.createdAt.toLocal()}'.split('.').first,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
