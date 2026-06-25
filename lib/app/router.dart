import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/inventory/category/presentation/category_management_screen.dart';
import '../features/inventory/product/presentation/product_list_screen.dart';
import '../features/inventory/stock_movement/presentation/stock_movements_screen.dart';
import '../features/inventory/unit/presentation/units_management_screen.dart';
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
    CategoryManagementScreen(),
    UnitsManagementScreen(),
    StockMovementsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.inventory_2_outlined), label: 'Products'),
          NavigationDestination(
              icon: Icon(Icons.category_outlined), label: 'Categories'),
          NavigationDestination(
              icon: Icon(Icons.straighten), label: 'Units'),
          NavigationDestination(
              icon: Icon(Icons.swap_vert), label: 'Stock'),
          NavigationDestination(
              icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
    );
  }
}
