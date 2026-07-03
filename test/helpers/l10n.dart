import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:inventoryhub_mobile/l10n/app_localizations.dart';

/// Localization delegates for widget tests that pump a screen inside a bare
/// [MaterialApp]. Screens call `context.l10n`, which needs [AppLocalizations]
/// in the tree — the real app wires these in `InventoryHubApp`.
const List<LocalizationsDelegate<Object>> testLocalizationDelegates = [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

const List<Locale> testSupportedLocales = AppLocalizations.supportedLocales;

/// Wraps [home] in a localized [MaterialApp]. Pass [locale] to force a specific
/// language (e.g. `Locale('ar')`) for RTL / translation assertions.
MaterialApp localizedApp({required Widget home, Locale? locale}) => MaterialApp(
      locale: locale,
      localizationsDelegates: testLocalizationDelegates,
      supportedLocales: testSupportedLocales,
      home: home,
    );
