import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../core/format/quantity_format.dart';
import '../../../../core/l10n/l10n_ext.dart';
import '../../../../core/result/app_exception.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../inventory/product/presentation/product_providers.dart';
import '../../../inventory/unit/presentation/unit_providers.dart';
import '../../recipe/domain/production_recipe.dart';
import '../../recipe/presentation/production_recipe_providers.dart';
import '../domain/production_order.dart';
import '../domain/production_order_enums.dart';
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
      ref.invalidate(productionOrderListProvider);
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

  Color _statusColor(ProductionOrderStatus s) => switch (s) {
        ProductionOrderStatus.planned => Colors.blue.shade700,
        ProductionOrderStatus.inProgress => Colors.indigo.shade600,
        ProductionOrderStatus.completed => Colors.green.shade700,
        ProductionOrderStatus.cancelled => Colors.red.shade700,
      };

  Widget _buildStatusBadge(
      BuildContext context, ProductionOrderStatus status, AppLocalizations l10n) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        productionStatusLabel(l10n, status),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final order = ref.watch(productionOrderProvider(orderId));
    final service = ref.read(productionOrderServiceProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.productionOrderDetailTitle)),
      body: AsyncValueView(
        value: order,
        data: (o) {
          if (o == null) {
            return Center(child: Text(l10n.productionOrderNotFound));
          }
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              // Summary Header Card
              AppCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          o.orderNumber,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: scheme.onSurface,
                          ),
                        ),
                        _buildStatusBadge(context, o.status, l10n),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 16, color: scheme.onSurfaceVariant),
                        const SizedBox(width: 8),
                        Text(
                          l10n.productionCreatedValue(o.createdAt
                              .toLocal()
                              .toString()
                              .substring(0, 16)),
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                    if (o.startDate != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.play_arrow_outlined,
                              size: 16, color: scheme.onSurfaceVariant),
                          const SizedBox(width: 8),
                          Text(
                            l10n.productionStartedValue(o.startDate!
                                .toLocal()
                                .toString()
                                .substring(0, 16)),
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ],
                    if (o.completionDate != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.check_circle_outline,
                              size: 16, color: scheme.onSurfaceVariant),
                          const SizedBox(width: 8),
                          Text(
                            l10n.productionCompletedValue(o.completionDate!
                                .toLocal()
                                .toString()
                                .substring(0, 16)),
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppTokens.space24),

              // Output Product Section
              Text(
                l10n.productionOutputProductHeading,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppTokens.space8),
              Consumer(
                builder: (context, ref, _) {
                  final productVal = ref.watch(productProvider(o.productId));
                  return AsyncValueView(
                    value: productVal,
                    data: (p) {
                      if (p == null) {
                        return AppCard(
                          child: Text(l10n.productionProductNotFound),
                        );
                      }
                      final unitSymbol =
                          ref.watch(unitSymbolProvider(p.unitId)).value ?? '';
                      final qtyText = unitSymbol.isEmpty
                          ? formatQty(o.quantity)
                          : '${formatQty(o.quantity)} $unitSymbol';
                      final stockText = unitSymbol.isEmpty
                          ? formatQty(p.currentStock)
                          : '${formatQty(p.currentStock)} $unitSymbol';
                      return AppCard(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: scheme.primary.withAlpha(20),
                              child: Icon(Icons.precision_manufacturing_outlined,
                                  color: scheme.primary),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.name,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: scheme.onSurface,
                                    ),
                                  ),
                                  if (p.barcode != null && p.barcode!.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      l10n.productionBarcodeValue(p.barcode!),
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                              color: scheme.onSurfaceVariant),
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        l10n.productionTargetQuantityLabel,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                                color: scheme.onSurfaceVariant),
                                      ),
                                      Text(
                                        qtyText,
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                                fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        l10n.productionOnHandStockLabel,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                                color: scheme.onSurfaceVariant),
                                      ),
                                      Text(
                                        stockText,
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: p.currentStock > 0
                                              ? scheme.primary
                                              : AppTokens.outFg,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: AppTokens.space24),

              // Required Ingredients Section
              Text(
                l10n.productionRequiredIngredientsHeading,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppTokens.space8),
              Consumer(
                builder: (context, ref, _) {
                  final recipeAsync =
                      ref.watch(activeRecipeForProductProvider(o.productId));
                  return recipeAsync.when(
                    data: (recipe) {
                      if (recipe == null) {
                        if (!o.isTerminal) {
                          return AppCard(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Icon(Icons.warning_amber_rounded,
                                    color: AppTokens.outFg, size: 28),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.productionNoActiveRecipeTitle,
                                        style:
                                            theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppTokens.outFg,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        l10n.productionNoActiveRecipeBody,
                                        style:
                                            theme.textTheme.bodyMedium?.copyWith(
                                          color: scheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return AppCard(
                            child: Text(l10n.productionNoRecipeDetailsTerminal),
                          );
                        }
                      }

                      final itemsAsync =
                          ref.watch(recipeItemsProvider(recipe.id));
                      return AsyncValueView(
                        value: itemsAsync,
                        data: (items) {
                          if (items.isEmpty) {
                            return AppCard(
                              child: Text(l10n.productionRecipeNoIngredients),
                            );
                          }
                          return AppCard(
                            padding: EdgeInsets.zero,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        l10n.productionRecipeNameValue(
                                            recipe.name),
                                        style:
                                            theme.textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: scheme.primary,
                                        ),
                                      ),
                                      Text(
                                        l10n.productionIngredientsChecklist,
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: scheme.onSurfaceVariant,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(height: 1),
                                for (int idx = 0; idx < items.length; idx++) ...[
                                  _IngredientItemRow(
                                    order: o,
                                    item: items[idx],
                                  ),
                                  if (idx < items.length - 1)
                                    const Divider(height: 1),
                                ],
                              ],
                            ),
                          );
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, _) => AppCard(
                        child: Text(l10n.productionRecipeLoadError('$err'))),
                  );
                },
              ),
              const SizedBox(height: 32),

              // Actions
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
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton.icon(
            icon: const Icon(Icons.play_arrow),
            label: Text(l10n.productionStartButton),
            onPressed: () => _run(context, ref, () => service.start(o)),
          ),
        ),
      if (o.canComplete) ...[
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton.icon(
            icon: const Icon(Icons.check),
            label: Text(l10n.productionCompleteButton),
            onPressed: () => _run(context, ref, () => service.complete(o)),
          ),
        ),
      ],
      if (!o.isTerminal) ...[
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.cancel_outlined),
            label: Text(l10n.productionCancelOrderButton),
            onPressed: () => _run(context, ref, () => service.cancel(o)),
          ),
        ),
      ],
    ];
  }
}

class _IngredientItemRow extends ConsumerWidget {
  const _IngredientItemRow({
    required this.order,
    required this.item,
  });

  final ProductionOrder order;
  final ProductionRecipeItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final productAsync = ref.watch(productProvider(item.ingredientProductId));

    return AsyncValueView(
      value: productAsync,
      data: (p) {
        if (p == null) {
          return ListTile(
            title: Text(l10n.productionIngredientNotFound),
          );
        }

        final totalNeeded = item.quantityPerUnit * order.quantity;
        final isSufficient = p.currentStock >= totalNeeded;
        final isTerminal = order.isTerminal;

        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Text(
            p.name,
            style:
                theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                l10n.productionIngredientRequired(
                  formatQty(totalNeeded),
                  item.unit,
                  formatQty(item.quantityPerUnit),
                  formatQty(order.quantity),
                ),
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
              if (!isTerminal) ...[
                const SizedBox(height: 2),
                Text(
                  l10n.productionIngredientAvailable(
                      formatQty(p.currentStock), item.unit),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isSufficient
                        ? scheme.onSurfaceVariant
                        : AppTokens.outFg,
                  ),
                ),
              ],
            ],
          ),
          trailing: isTerminal
              ? Text(
                  l10n.productionIngredientConsumed,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                )
              : Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSufficient ? AppTokens.inBg : AppTokens.outBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSufficient ? Icons.check_circle : Icons.warning_amber_rounded,
                        size: 14,
                        color: isSufficient ? AppTokens.inFg : AppTokens.outFg,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isSufficient
                            ? l10n.productionIngredientInStock
                            : l10n.productionIngredientNeed(
                                formatQty(totalNeeded - p.currentStock)),
                        style: TextStyle(
                          color: isSufficient ? AppTokens.inFg : AppTokens.outFg,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
