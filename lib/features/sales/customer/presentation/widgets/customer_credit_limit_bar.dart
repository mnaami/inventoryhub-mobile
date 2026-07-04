import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventoryhub_mobile/app/currency/currency_controller.dart';
import '../../../../../app/theme/app_tokens.dart';

/// Credit-limit usage bar for the customer detail page's header card.
/// Caller is responsible for only rendering this when a credit limit is
/// set (`customer.creditLimit != null`).
class CustomerCreditLimitBar extends ConsumerWidget {
  const CustomerCreditLimitBar({
    super.key,
    required this.outstanding,
    required this.creditLimit,
  });

  final double outstanding;
  final double creditLimit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final money = ref.watch(moneyFormatterProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final ratio = creditLimit <= 0 ? 1.0 : outstanding / creditLimit;
    final color = ratio > 1.0
        ? AppTokens.outFg
        : (ratio >= 0.7 ? AppTokens.lowFg : AppTokens.inFg);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Credit limit used',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
            Text(
              '${money(outstanding)} / ${money(creditLimit)}',
              style: theme.textTheme.bodySmall
                  ?.copyWith(fontWeight: FontWeight.w600, color: color),
            ),
          ],
        ),
        const SizedBox(height: AppTokens.space4),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          child: LinearProgressIndicator(
            value: ratio.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: scheme.surfaceContainerHigh,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
