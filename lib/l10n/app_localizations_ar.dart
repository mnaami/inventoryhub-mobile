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

  @override
  String get onboardingSkip => 'تخطي';

  @override
  String get onboardingSlide1Title => 'اعرف مخزونك';

  @override
  String get onboardingSlide1Body =>
      'تتبّع كل منتج وفئة وحركة مخزون — فورًا، وبدون اتصال بالإنترنت.';

  @override
  String get onboardingSlide2Title => 'بِع وأعد التخزين';

  @override
  String get onboardingSlide2Body =>
      'أنشئ طلبات بيع وشراء، وسجّل المدفوعات، وحافظ على تزامن المخزون تلقائيًا.';

  @override
  String get onboardingSlide3Title => 'صنّع وأدر';

  @override
  String get onboardingSlide3Body =>
      'حوّل المكونات إلى منتجات باستخدام الوصفات، وتابع كل ذلك من لوحات معلومات حية.';

  @override
  String get onboardingNext => 'التالي';

  @override
  String get onboardingGetStarted => 'ابدأ الآن';

  @override
  String get coreStatusLow => 'منخفض';

  @override
  String get coreStatusOut => 'نفد';

  @override
  String get coreSearchHint => 'بحث';

  @override
  String get coreCancel => 'إلغاء';

  @override
  String get coreDelete => 'حذف';

  @override
  String get coreRetry => 'إعادة المحاولة';

  @override
  String get coreNothingHere => 'لا يوجد شيء هنا بعد.';

  @override
  String get coreSomethingWrong => 'حدث خطأ ما.';

  @override
  String get coreCouldntLoadMore => 'تعذّر تحميل المزيد. إعادة المحاولة';

  @override
  String get navProducts => 'المنتجات';

  @override
  String get navSales => 'المبيعات';

  @override
  String get navPurchasing => 'المشتريات';

  @override
  String get navMore => 'المزيد';

  @override
  String get navMoreFeaturesTitle => 'المزيد من الميزات';

  @override
  String get navStock => 'المخزون';

  @override
  String get navProduction => 'الإنتاج';

  @override
  String get navSuppliers => 'الموردون';

  @override
  String get navCustomers => 'العملاء';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get categoryEditTitle => 'تعديل الفئة';

  @override
  String get categoryNewTitle => 'فئة جديدة';

  @override
  String get categoryDetailsHeading => 'تفاصيل الفئة';

  @override
  String get categoryNameLabel => 'الاسم';

  @override
  String get categoryNameRequired => 'الاسم مطلوب';

  @override
  String get categoryParentLabel => 'الفئة الأم (اختياري)';

  @override
  String get categoryParentNone => '— بدون —';

  @override
  String get categorySave => 'حفظ';

  @override
  String get categoriesTitle => 'الفئات';

  @override
  String get categoryEmptyTitle => 'لا توجد فئات بعد';

  @override
  String get categoryEmptySubtitle => 'نظّم منتجاتك باستخدام الفئات.';

  @override
  String get categoryEmptyAction => 'إضافة فئة';

  @override
  String get categoryDeleteTitle => 'حذف الفئة';

  @override
  String categoryDeleteConfirm(String name) {
    return 'حذف \"$name\"؟';
  }

  @override
  String get unitEditTitle => 'تعديل الوحدة';

  @override
  String get unitNewTitle => 'وحدة جديدة';

  @override
  String get unitBasicInfoHeading => 'معلومات أساسية';

  @override
  String get unitNameLabel => 'الاسم';

  @override
  String get unitFieldRequired => 'مطلوب';

  @override
  String get unitSymbolLabel => 'الرمز';

  @override
  String get unitTypeLabel => 'النوع';

  @override
  String get unitConversionHeading => 'التحويل';

  @override
  String get unitBaseUnitLabel => 'وحدة أساسية';

  @override
  String get unitConversionFactorLabel => 'معامل التحويل (إلى الوحدة الأساسية)';

  @override
  String get unitSave => 'حفظ';

  @override
  String get unitsTitle => 'الوحدات';

  @override
  String get unitEmptyTitle => 'لا توجد وحدات بعد';

  @override
  String get unitEmptySubtitle => 'عرّف وحدات مثل قطعة أو كجم أو لتر.';

  @override
  String get unitEmptyAction => 'إضافة وحدة';

  @override
  String get unitBaseTag => 'أساسية';

  @override
  String unitConversionFactorSuffix(String factor) {
    return 'معامل تحويل × $factor';
  }

  @override
  String get unitDeleteTitle => 'حذف الوحدة';

  @override
  String unitDeleteConfirm(String name) {
    return 'حذف \"$name\"؟';
  }

  @override
  String get productEditTitle => 'تعديل المنتج';

  @override
  String get productNewTitle => 'منتج جديد';

  @override
  String get productDetailsHeading => 'التفاصيل';

  @override
  String get productNameLabel => 'الاسم';

  @override
  String get productNameRequired => 'الاسم مطلوب';

  @override
  String get productDescriptionLabel => 'الوصف';

  @override
  String get productCategoryLabel => 'الفئة';

  @override
  String get productCategoryNone => '— بدون —';

  @override
  String get productUnitLabel => 'الوحدة';

  @override
  String get productPricingHeading => 'التسعير';

  @override
  String get productPurchasePriceLabel => 'سعر الشراء';

  @override
  String get productSellingPriceLabel => 'سعر البيع';

  @override
  String get productStockIdHeading => 'المخزون والتعريف';

  @override
  String get productMinimumStockLabel => 'الحد الأدنى للمخزون';

  @override
  String get productBarcodeLabel => 'الباركود';

  @override
  String get productSave => 'حفظ';

  @override
  String get productChangePhoto => 'تغيير الصورة';

  @override
  String get productAddPhoto => 'إضافة صورة';

  @override
  String get productTitle => 'المنتج';

  @override
  String get productNotFound => 'المنتج غير موجود.';

  @override
  String get productSellingPriceRow => 'سعر البيع';

  @override
  String get productPricingDetailsHeading => 'التسعير والتفاصيل';

  @override
  String get productPurchasePriceRow => 'سعر الشراء';

  @override
  String get productBarcodeRow => 'الباركود';

  @override
  String get productRecordStockMovement => 'تسجيل حركة مخزون';

  @override
  String get productViewStockHistory => 'عرض سجل المخزون';

  @override
  String get productStockLevelHeading => 'مستوى المخزون';

  @override
  String get productCurrentStockLabel => 'المخزون الحالي';

  @override
  String get productMinRequiredLabel => 'الحد الأدنى المطلوب';

  @override
  String get productUnitSuffixPcs => 'قطعة';

  @override
  String get productHealthyBadge => 'جيد';

  @override
  String get productValuationHeading => 'تقييم المخزون';

  @override
  String productValuationBasedOn(String qty, String price) {
    return 'بناءً على $qty قطعة بسعر شراء $price';
  }

  @override
  String get productsTitle => 'المنتجات';

  @override
  String get productSearchHint => 'ابحث باسم المنتج أو الباركود';

  @override
  String get productFilterLowStock => 'مخزون منخفض';

  @override
  String get productFilterLowStockOnly => 'المخزون المنخفض فقط';

  @override
  String get productFilterOutOfStock => 'نفد المخزون';

  @override
  String get productFilterOutOfStockOnly => 'نافد المخزون فقط';

  @override
  String get productFilterCategory => 'الفئة';

  @override
  String get productFilterAllCategories => 'كل الفئات';

  @override
  String get productFilterAll => 'الكل';

  @override
  String get productEmptyTitle => 'لا توجد منتجات بعد';

  @override
  String get productDashboardTitle => 'لوحة معلومات المخزون';

  @override
  String productDashboardErrorLoading(String error) {
    return 'خطأ في تحميل لوحة المعلومات: $error';
  }

  @override
  String get productDashboardRetry => 'إعادة المحاولة';

  @override
  String get productDashboardRestockRequiredTitle => 'يلزم إعادة التخزين';

  @override
  String productDashboardRestockRequiredSubtitle(int count) {
    return '$count منتجات نفد مخزونها. اضغط لإعادة التخزين.';
  }

  @override
  String get productDashboardLowStockAlertTitle => 'تنبيه انخفاض المخزون';

  @override
  String productDashboardLowStockAlertSubtitle(int count) {
    return '$count منتجات مخزونها منخفض. اضغط للمراجعة.';
  }

  @override
  String get productDashboardHealthyTitle => 'مستويات المخزون جيدة';

  @override
  String get productDashboardHealthySubtitle =>
      'جميع المنتجات مخزّنة بشكل جيد. لا تنبيهات.';

  @override
  String get productDashboardBreakdownHeading => 'توزيع حالة المخزون';

  @override
  String get productDashboardWellStocked => 'مخزون جيد';

  @override
  String get productDashboardLowStock => 'مخزون منخفض';

  @override
  String get productDashboardOutOfStock => 'نفد المخزون';

  @override
  String get productDashboardQuickActionsHeading => 'إجراءات سريعة';

  @override
  String get productDashboardManageProducts => 'إدارة المنتجات';

  @override
  String get productStatTotalValue => 'القيمة الإجمالية';

  @override
  String get productStatActiveProducts => 'المنتجات النشطة';

  @override
  String get productStatLowStockItems => 'عناصر منخفضة المخزون';

  @override
  String get productStatOutOfStock => 'نفد المخزون';

  @override
  String get productStatInventorySummary => 'ملخص المخزون';

  @override
  String get productStatStockAlerts => 'تنبيهات المخزون';

  @override
  String get productStatStatistics => 'الإحصائيات';

  @override
  String get barcodeScanTitle => 'مسح الباركود';

  @override
  String get barcodeScanHint => 'ضع الباركود داخل الإطار';

  @override
  String stockMovementScreenTitle(String productName) {
    return 'المخزون — $productName';
  }

  @override
  String get stockMovementTypeHeading => 'نوع الحركة';

  @override
  String get stockMovementTypeIn => 'وارد';

  @override
  String get stockMovementTypeOut => 'صادر';

  @override
  String get stockMovementTypeAdjust => 'تسوية';

  @override
  String get stockMovementDetailsHeading => 'التفاصيل';

  @override
  String get stockMovementQuantityAdjustLabel => 'الكمية (استخدم − للتقليل)';

  @override
  String get stockMovementQuantityLabel => 'الكمية';

  @override
  String get stockMovementQuantityInvalid => 'أدخل رقمًا';

  @override
  String get stockMovementQuantityZero => 'يجب ألا تكون الكمية صفرًا';

  @override
  String get stockMovementNotesLabel => 'ملاحظات (اختياري)';

  @override
  String get stockMovementRecordButton => 'تسجيل';

  @override
  String get stockMovementsTitle => 'حركات المخزون';

  @override
  String get stockMovementEmptyTitle => 'لا توجد حركات مخزون بعد';

  @override
  String get stockMovementEmptySubtitle =>
      'سجّل حركة مخزون واردة أو صادرة لعرض السجل.';
}
