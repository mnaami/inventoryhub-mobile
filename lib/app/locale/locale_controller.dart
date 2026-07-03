import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/theme_controller.dart' show sharedPrefsProvider;

/// App locale override. `null` means "follow the device language".
///
/// Mirrors [ThemeController]: prefs-backed, reuses [sharedPrefsProvider].
final localeControllerProvider =
    NotifierProvider<LocaleController, Locale?>(LocaleController.new);

class LocaleController extends Notifier<Locale?> {
  static const _key = 'locale';

  @override
  Locale? build() => _read(ref.watch(sharedPrefsProvider));

  static Locale? _read(SharedPreferences p) {
    switch (p.getString(_key)) {
      case 'en':
        return const Locale('en');
      case 'ar':
        return const Locale('ar');
      default:
        return null; // follow device
    }
  }

  /// Set the locale override. Pass `null` to follow the device language.
  Future<void> set(Locale? locale) async {
    state = locale;
    final prefs = ref.read(sharedPrefsProvider);
    if (locale == null) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(_key, locale.languageCode);
    }
  }
}
