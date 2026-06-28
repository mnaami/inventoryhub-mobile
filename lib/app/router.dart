import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/inventory/product/presentation/product_list_screen.dart';
import '../features/inventory/stock_movement/presentation/stock_movements_screen.dart';
import '../features/sales/customer/presentation/customer_list_screen.dart';
import '../features/sales/sale_order/presentation/sale_order_dashboard_screen.dart';
import '../features/purchasing/purchase_order/presentation/purchase_order_dashboard_screen.dart';
import '../features/purchasing/supplier/presentation/supplier_list_screen.dart';
import '../features/production/presentation/production_home_screen.dart';
import '../features/settings/presentation/settings_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, __) => const MainScaffold()),
    ],
  );
});

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});
  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _index = 0;

  static const _tabs = [
    ProductListScreen(),
    SaleOrderDashboardScreen(),
    PurchaseOrderDashboardScreen(),
  ];

  void _push(Widget screen) {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  Widget _sheetTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: scheme.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: scheme.primary, size: 18),
            ),
            const SizedBox(width: 14),
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
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _openMore() {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: scheme.onSurfaceVariant.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'More Features',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _sheetTile(
                icon: Icons.swap_vert_rounded,
                title: 'Stock',
                onTap: () {
                  Navigator.pop(ctx);
                  _push(const StockMovementsScreen());
                },
              ),
              const Divider(height: 1, indent: 20, endIndent: 20),
              _sheetTile(
                icon: Icons.precision_manufacturing_outlined,
                title: 'Production',
                onTap: () {
                  Navigator.pop(ctx);
                  _push(const ProductionHomeScreen());
                },
              ),
              const Divider(height: 1, indent: 20, endIndent: 20),
              _sheetTile(
                icon: Icons.local_shipping_outlined,
                title: 'Suppliers',
                onTap: () {
                  Navigator.pop(ctx);
                  _push(const SupplierListScreen());
                },
              ),
              const Divider(height: 1, indent: 20, endIndent: 20),
              _sheetTile(
                icon: Icons.people_outline_rounded,
                title: 'Customers',
                onTap: () {
                  Navigator.pop(ctx);
                  _push(const CustomerListScreen());
                },
              ),
              const Divider(height: 1, indent: 20, endIndent: 20),
              _sheetTile(
                icon: Icons.settings_outlined,
                title: 'Settings',
                onTap: () {
                  Navigator.pop(ctx);
                  _push(const SettingsScreen());
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) {
          if (i == 3) {
            _openMore();
          } else {
            setState(() => _index = i);
          }
        },
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.inventory_2_outlined), label: 'Products'),
          NavigationDestination(
              icon: Icon(Icons.point_of_sale_outlined), label: 'Sales'),
          NavigationDestination(
              icon: Icon(Icons.shopping_cart_outlined), label: 'Purchasing'),
          NavigationDestination(icon: Icon(Icons.more_horiz), label: 'More'),
        ],
      ),
    );
  }
}
