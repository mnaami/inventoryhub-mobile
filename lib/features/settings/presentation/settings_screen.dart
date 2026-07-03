import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/locale/locale_controller.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../app/theme/theme_controller.dart';
import '../../../core/l10n/l10n_ext.dart';
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

  Widget _radioTile<T>(
    BuildContext context, {
    required String title,
    required T value,
    required T groupValue,
    required ValueChanged<T?> onChanged,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return RadioListTile<T>(
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
        ),
      ),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: scheme.primary,
      controlAffinity: ListTileControlAffinity.trailing,
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.logoutConfirmTitle),
        content: Text(l10n.logoutConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            key: const Key('settings_logout_confirm'),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.logout),
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
    final l10n = context.l10n;
    final mode = ref.watch(themeControllerProvider);
    final themeController = ref.read(themeControllerProvider.notifier);
    final locale = ref.watch(localeControllerProvider);
    final localeController = ref.read(localeControllerProvider.notifier);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          SectionHeader(l10n.sectionAppearance),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: RadioGroup<ThemeMode>(
              groupValue: mode,
              onChanged: (m) => themeController.set(m!),
              child: Column(
                children: [
                  _radioTile<ThemeMode>(
                    context,
                    title: l10n.themeSystem,
                    value: ThemeMode.system,
                    groupValue: mode,
                    onChanged: (m) => themeController.set(m!),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _radioTile<ThemeMode>(
                    context,
                    title: l10n.themeLight,
                    value: ThemeMode.light,
                    groupValue: mode,
                    onChanged: (m) => themeController.set(m!),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _radioTile<ThemeMode>(
                    context,
                    title: l10n.themeDark,
                    value: ThemeMode.dark,
                    groupValue: mode,
                    onChanged: (m) => themeController.set(m!),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTokens.space24),
          SectionHeader(l10n.sectionLanguage),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: RadioGroup<Locale?>(
              groupValue: locale,
              onChanged: (l) => localeController.set(l),
              child: Column(
                children: [
                  _radioTile<Locale?>(
                    context,
                    title: l10n.languageSystem,
                    value: null,
                    groupValue: locale,
                    onChanged: (l) => localeController.set(l),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _radioTile<Locale?>(
                    context,
                    title: l10n.languageEnglish,
                    value: const Locale('en'),
                    groupValue: locale,
                    onChanged: (l) => localeController.set(l),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _radioTile<Locale?>(
                    context,
                    title: l10n.languageArabic,
                    value: const Locale('ar'),
                    groupValue: locale,
                    onChanged: (l) => localeController.set(l),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTokens.space24),
          SectionHeader(l10n.sectionCatalog),
          _navTile(
            context,
            icon: Icons.category_outlined,
            title: l10n.catalogCategories,
            destination: const CategoryManagementScreen(),
          ),
          const SizedBox(height: AppTokens.space8),
          _navTile(
            context,
            icon: Icons.straighten_rounded,
            title: l10n.catalogUnits,
            destination: const UnitsManagementScreen(),
          ),
          const SizedBox(height: AppTokens.space24),
          const SampleDataSection(),
          const SizedBox(height: AppTokens.space24),
          SectionHeader(l10n.sectionAbout),
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
          SectionHeader(l10n.sectionAccount),
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
                    l10n.logout,
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
