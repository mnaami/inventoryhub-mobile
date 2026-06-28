import 'package:flutter/material.dart';
import '../../app/theme/app_tokens.dart';

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding, this.onTap});
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    return Material(
      color: scheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppTokens.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        child: Container(
          padding: padding ?? const EdgeInsets.all(AppTokens.space16),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppTokens.radiusLg),
            border: isLight ? null : Border.all(color: scheme.outlineVariant),
            boxShadow: isLight
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: child,
        ),
      ),
    );
  }
}
