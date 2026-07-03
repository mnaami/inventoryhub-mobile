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

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingSlide1Title => 'Know your stock';

  @override
  String get onboardingSlide1Body =>
      'Track every product, category, and stock movement — instantly, and fully offline.';

  @override
  String get onboardingSlide2Title => 'Sell and restock';

  @override
  String get onboardingSlide2Body =>
      'Raise sale and purchase orders, record payments, and keep stock in sync automatically.';

  @override
  String get onboardingSlide3Title => 'Make and manage';

  @override
  String get onboardingSlide3Body =>
      'Turn ingredients into products with recipes, and track it all from live dashboards.';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingGetStarted => 'Get started';
}
