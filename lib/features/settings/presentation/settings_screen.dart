import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../app/theme/theme_controller.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/section_header.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeControllerProvider);
    final controller = ref.read(themeControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(AppTokens.space16),
        children: [
          const SectionHeader('Appearance'),
          AppCard(
            child: RadioGroup<ThemeMode>(
              groupValue: mode,
              onChanged: (m) => controller.set(m!),
              child: const Column(
                children: [
                  RadioListTile<ThemeMode>(
                    title: Text('System'),
                    value: ThemeMode.system,
                  ),
                  RadioListTile<ThemeMode>(
                    title: Text('Light'),
                    value: ThemeMode.light,
                  ),
                  RadioListTile<ThemeMode>(
                    title: Text('Dark'),
                    value: ThemeMode.dark,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTokens.space24),
          const SectionHeader('About'),
          const AppCard(
            child: AboutListTile(
              applicationName: 'InventoryHub',
              applicationVersion: '0.1.0 (inventory core)',
            ),
          ),
        ],
      ),
    );
  }
}
