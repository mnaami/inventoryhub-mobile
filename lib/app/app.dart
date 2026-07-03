import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventoryhub_mobile/l10n/app_localizations.dart';
import 'locale/locale_controller.dart';
import 'router.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

class InventoryHubApp extends ConsumerWidget {
  const InventoryHubApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeOverride = ref.watch(localeControllerProvider);
    final arabic = _isArabic(localeOverride, View.of(context).platformDispatcher.locale);

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: buildAppTheme(brightness: Brightness.light, arabic: arabic),
      darkTheme: buildAppTheme(brightness: Brightness.dark, arabic: arabic),
      themeMode: ref.watch(themeControllerProvider),
      locale: localeOverride,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: ref.watch(routerProvider),
    );
  }

  /// Resolves whether the effective UI locale is Arabic, so the theme can
  /// pick the Arabic font. Mirrors MaterialApp's own locale resolution:
  /// an explicit override wins; otherwise fall back to the device locale,
  /// defaulting to English for anything unsupported.
  static bool _isArabic(Locale? override, Locale deviceLocale) {
    final effective = override ?? deviceLocale;
    return effective.languageCode == 'ar';
  }
}
