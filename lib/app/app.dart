import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

class InventoryHubApp extends ConsumerWidget {
  const InventoryHubApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'InventoryHub',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ref.watch(themeControllerProvider),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
