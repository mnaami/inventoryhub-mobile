import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/l10n_ext.dart';
import '../../purchasing/purchase_order/presentation/purchase_order_dashboard_screen.dart';
import '../../inventory/stock_movement/presentation/stock_movements_screen.dart';
import '../../inventory/category/presentation/category_management_screen.dart';
import '../../inventory/unit/presentation/units_management_screen.dart';
import '../../settings/presentation/settings_screen.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navMoreFeaturesTitle),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          _moreTile(
            context,
            icon: Icons.shopping_cart_outlined,
            title: l10n.navPurchasing,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const PurchaseOrderDashboardScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          _moreTile(
            context,
            icon: Icons.swap_vert_rounded,
            title: l10n.navStock,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const StockMovementsScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          _moreTile(
            context,
            icon: Icons.category_outlined,
            title: l10n.catalogCategories,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const CategoryManagementScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          _moreTile(
            context,
            icon: Icons.straighten_rounded,
            title: l10n.catalogUnits,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const UnitsManagementScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          _moreTile(
            context,
            icon: Icons.badge_outlined,
            title: l10n.moreEmployees,
            onTap: () => context.push('/employees'),
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          _moreTile(
            context,
            icon: Icons.settings_outlined,
            title: l10n.navSettings,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _moreTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: scheme.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: scheme.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: scheme.onSurfaceVariant.withOpacity(0.3),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
