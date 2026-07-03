// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'InventoryHub';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get sectionAppearance => 'المظهر';

  @override
  String get sectionLanguage => 'اللغة';

  @override
  String get sectionCatalog => 'الكتالوج';

  @override
  String get sectionAbout => 'حول التطبيق';

  @override
  String get sectionAccount => 'الحساب';

  @override
  String get themeSystem => 'النظام';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get languageSystem => 'لغة النظام';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get catalogCategories => 'الفئات';

  @override
  String get catalogUnits => 'الوحدات';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get logoutConfirmTitle => 'تسجيل الخروج؟';

  @override
  String get logoutConfirmMessage =>
      'ستحتاج إلى تسجيل الدخول مرة أخرى للمتابعة.';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get authSignInSubtitle => 'سجّل الدخول للمتابعة';

  @override
  String get authUsernameLabel => 'اسم المستخدم';

  @override
  String get authPasswordLabel => 'كلمة المرور';

  @override
  String get authInvalidCredentials => 'اسم المستخدم أو كلمة المرور غير صحيحة';

  @override
  String get authSignInButton => 'تسجيل الدخول';

  @override
  String get authDemoHint => 'اضغط لتعبئة بيانات تجريبية: admin / admin';
}
