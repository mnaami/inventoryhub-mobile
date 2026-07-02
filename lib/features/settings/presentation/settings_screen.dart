import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../app/theme/theme_controller.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../inventory/category/presentation/category_management_screen.dart';
import '../../inventory/unit/presentation/units_management_screen.dart';
import 'sample_data_section.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Widget _navTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget destination,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => destination),
      ),
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
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will need to sign in again to continue.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('settings_logout_confirm'),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await ref.read(authControllerProvider.notifier).logout();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeControllerProvider);
    final controller = ref.read(themeControllerProvider.notifier);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          const SectionHeader('Appearance'),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: RadioGroup<ThemeMode>(
              groupValue: mode,
              onChanged: (m) => controller.set(m!),
              child: Column(
                children: [
                  RadioListTile<ThemeMode>(
                    title: Text(
                      'System',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                    value: ThemeMode.system,
                    groupValue: mode,
                    onChanged: (m) => controller.set(m!),
                    activeColor: scheme.primary,
                    controlAffinity: ListTileControlAffinity.trailing,
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  RadioListTile<ThemeMode>(
                    title: Text(
                      'Light',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                    value: ThemeMode.light,
                    groupValue: mode,
                    onChanged: (m) => controller.set(m!),
                    activeColor: scheme.primary,
                    controlAffinity: ListTileControlAffinity.trailing,
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  RadioListTile<ThemeMode>(
                    title: Text(
                      'Dark',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                    value: ThemeMode.dark,
                    groupValue: mode,
                    onChanged: (m) => controller.set(m!),
                    activeColor: scheme.primary,
                    controlAffinity: ListTileControlAffinity.trailing,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTokens.space24),
          const SectionHeader('Catalog'),
          _navTile(
            context,
            icon: Icons.category_outlined,
            title: 'Categories',
            destination: const CategoryManagementScreen(),
          ),
          const SizedBox(height: AppTokens.space8),
          _navTile(
            context,
            icon: Icons.straighten_rounded,
            title: 'Units',
            destination: const UnitsManagementScreen(),
          ),
          const SizedBox(height: AppTokens.space24),
          const SampleDataSection(),
          const SizedBox(height: AppTokens.space24),
          const SectionHeader('About'),
          AppCard(
            padding: const EdgeInsets.all(4),
            child: AboutListTile(
              applicationName: 'InventoryHub',
              applicationIcon: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: scheme.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  color: scheme.primary,
                  size: 22,
                ),
              ),
              applicationVersion: '0.1.0 (inventory core)',
              dense: false,
            ),
          ),
          const SizedBox(height: AppTokens.space24),
          const SectionHeader('Account'),
          AppCard(
            key: const Key('settings_logout'),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            onTap: () => _confirmLogout(context, ref),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: scheme.error.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.logout_rounded,
                      color: scheme.error, size: 18),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Log out',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: scheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
