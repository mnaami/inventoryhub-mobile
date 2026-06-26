import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/inventory/category/presentation/category_management_screen.dart';
import '../features/inventory/product/presentation/product_list_screen.dart';
import '../features/inventory/stock_movement/presentation/stock_movements_screen.dart';
import '../features/inventory/unit/presentation/units_management_screen.dart';
import '../features/sales/customer/presentation/customer_list_screen.dart';
import '../features/sales/sale_order/presentation/sale_order_dashboard_screen.dart';
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
    StockMovementsScreen(),
  ];

  void _openMore() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.people_outline),
              title: const Text('Customers'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const CustomerListScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.category_outlined),
              title: const Text('Categories'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const CategoryManagementScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.straighten),
              title: const Text('Units'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const UnitsManagementScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const SettingsScreen()));
              },
            ),
          ],
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
          NavigationDestination(icon: Icon(Icons.swap_vert), label: 'Stock'),
          NavigationDestination(icon: Icon(Icons.more_horiz), label: 'More'),
        ],
      ),
    );
  }
}
