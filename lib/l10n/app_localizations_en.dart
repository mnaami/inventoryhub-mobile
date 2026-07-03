// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'InventoryHub';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get sectionAppearance => 'Appearance';

  @override
  String get sectionLanguage => 'Language';

  @override
  String get sectionCatalog => 'Catalog';

  @override
  String get sectionAbout => 'About';

  @override
  String get sectionAccount => 'Account';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get languageSystem => 'System default';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get catalogCategories => 'Categories';

  @override
  String get catalogUnits => 'Units';

  @override
  String get logout => 'Log out';

  @override
  String get logoutConfirmTitle => 'Log out?';

  @override
  String get logoutConfirmMessage =>
      'You will need to sign in again to continue.';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get authSignInSubtitle => 'Sign in to continue';

  @override
  String get authUsernameLabel => 'Username';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authInvalidCredentials => 'Invalid username or password';

  @override
  String get authSignInButton => 'Sign in';

  @override
  String get authDemoHint => 'Tap to fill demo: admin / admin';
}
