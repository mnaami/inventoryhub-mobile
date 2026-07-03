import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/currency/currency_controller.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../core/format/money_format.dart';
import '../../../core/l10n/l10n_ext.dart';
import '../../../core/widgets/app_card.dart';

/// First-launch gate: forces the user to pick a display currency before
/// reaching login/the app. Selecting one persists it via
/// [currencyControllerProvider], which advances the router gate.
class CurrencySelectScreen extends ConsumerWidget {
  const CurrencySelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.payments_outlined, size: 96, color: scheme.primary),
              const SizedBox(height: AppTokens.space24),
              Text(
                l10n.currencySelectTitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppTokens.space12),
              Text(
                l10n.currencySelectSubtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: AppTokens.space24),
              _choice(context, ref, Currency.usd, l10n.currencyUsd),
              const SizedBox(height: AppTokens.space12),
              _choice(context, ref, Currency.dzd, l10n.currencyDzd),
            ],
          ),
        ),
      ),
    );
  }

  Widget _choice(
    BuildContext context,
    WidgetRef ref,
    Currency currency,
    String label,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return AppCard(
      key: Key('currency_choice_${currency.code}'),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      onTap: () => ref.read(currencyControllerProvider.notifier).set(currency),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scheme.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Text(
              currency.symbol,
              style: theme.textTheme.titleMedium?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: scheme.onSurfaceVariant.withOpacity(0.3),
            size: 20,
          ),
        ],
      ),
    );
  }
}
