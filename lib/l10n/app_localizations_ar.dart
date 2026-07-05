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
  String get sectionCurrency => 'العملة';

  @override
  String get sectionCatalog => 'الكتالوج';

  @override
  String get sectionAbout => 'حول التطبيق';

  @override
  String get sectionAccount => 'الحساب';

  @override
  String get currencyUsd => 'الدولار الأمريكي (\$)';

  @override
  String get currencyDzd => 'الدينار الجزائري (دج)';

  @override
  String get currencySelectTitle => 'اختر عملتك';

  @override
  String get currencySelectSubtitle =>
      'ستظهر جميع الأسعار والمجاميع بهذه العملة. يمكنك تغييرها لاحقًا من الإعدادات.';

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
  String get navDashboard => 'الرئيسية';

  @override
  String get homeDashboardTitle => 'لوحة المعلومات';

  @override
  String get homeSalesToday => 'مبيعات اليوم';

  @override
  String get homeSalesThisWeek => 'مبيعات هذا الأسبوع';

  @override
  String get homeSalesThisMonth => 'مبيعات هذا الشهر';

  @override
  String get homeStatOrders => 'الطلبات';

  @override
  String get homeStatRevenue => 'الإيرادات';

  @override
  String get homeSalesTrendToday => 'اتجاه المبيعات — اليوم';

  @override
  String get homeSalesTrend7d => 'اتجاه المبيعات — 7 أيام';

  @override
  String get homeSalesTrend30d => 'اتجاه المبيعات — 30 يومًا';

  @override
  String get homeSalesTrendEmpty => 'لا توجد مبيعات في هذه الفترة بعد';

  @override
  String get homeMoneyHeading => 'الأموال الواردة والصادرة';

  @override
  String get homeReceivables => 'مستحقات لك من العملاء';

  @override
  String get homePayables => 'مستحقات عليك للموردين';

  @override
  String get homeStockHeading => 'لمحة عن المخزون';

  @override
  String get homeStockValue => 'إجمالي قيمة المخزون';

  @override
  String get homeLowStock => 'منتجات منخفضة المخزون';

  @override
  String get homeOutOfStock => 'منتجات نفدت من المخزون';

  @override
  String get homeOpenWorkHeading => 'الأعمال المفتوحة';

  @override
  String get homeOpenSaleOrders => 'طلبات بيع مفتوحة';

  @override
  String get homeUnshipped => 'بانتظار الشحن';

  @override
  String get homeOpenPurchaseOrders => 'طلبات شراء مفتوحة';

  @override
  String get homeUnreceived => 'بانتظار الاستلام';

  @override
  String get homeInProduction => 'قيد الإنتاج';

  @override
  String homeErrorLoading(String error) {
    return 'خطأ في تحميل لوحة المعلومات: $error';
  }

  @override
  String get homeRetry => 'إعادة المحاولة';

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

  @override
  String get productionHomeTitle => 'الإنتاج';

  @override
  String get productionStatusPlanned => 'مخطط';

  @override
  String get productionStatusInProgress => 'قيد التنفيذ';

  @override
  String get productionStatusCompleted => 'مكتمل';

  @override
  String get productionStatusCancelled => 'ملغى';

  @override
  String get productionOrdersButton => 'أوامر الإنتاج';

  @override
  String get recipesButton => 'الوصفات';

  @override
  String get productionOrderCreateTitle => 'أمر إنتاج جديد';

  @override
  String get productionOutputProductLabel => 'المنتج الناتج';

  @override
  String get productionQuantityLabel => 'الكمية';

  @override
  String get productionCreateButton => 'إنشاء';

  @override
  String get productionChooseOutputProductError => 'اختر منتجًا ناتجًا.';

  @override
  String get productionEnterValidQuantityError => 'أدخل كمية صحيحة.';

  @override
  String get productionActionDone => 'تم.';

  @override
  String get productionOrderDetailTitle => 'أمر الإنتاج';

  @override
  String get productionOrderNotFound => 'الأمر غير موجود.';

  @override
  String productionOutputProductValue(String productId) {
    return 'المنتج الناتج: $productId';
  }

  @override
  String productionQuantityValue(String quantity) {
    return 'الكمية: $quantity';
  }

  @override
  String productionStatusValue(String status) {
    return 'الحالة: $status';
  }

  @override
  String productionStartedValue(String date) {
    return 'بدأ: $date';
  }

  @override
  String productionCompletedValue(String date) {
    return 'اكتمل: $date';
  }

  @override
  String get productionStartButton => 'بدء';

  @override
  String get productionCompleteButton => 'إكمال (استهلاك + إنتاج)';

  @override
  String get productionCancelOrderButton => 'إلغاء الأمر';

  @override
  String productionCreatedValue(String date) {
    return 'أُنشئ: $date';
  }

  @override
  String get productionOutputProductHeading => 'المنتج الناتج';

  @override
  String get productionProductNotFound => 'المنتج غير موجود';

  @override
  String productionBarcodeValue(String barcode) {
    return 'الباركود: $barcode';
  }

  @override
  String get productionTargetQuantityLabel => 'الكمية المستهدفة';

  @override
  String get productionOnHandStockLabel => 'المخزون المتاح';

  @override
  String get productionRequiredIngredientsHeading => 'المكونات المطلوبة';

  @override
  String get productionNoActiveRecipeTitle => 'لا توجد وصفة نشطة';

  @override
  String get productionNoActiveRecipeBody =>
      'لا توجد وصفة نشطة لهذا المنتج. يلزم وجود وصفة نشطة لإكمال الإنتاج.';

  @override
  String get productionNoRecipeDetailsTerminal =>
      'لا تتوفر تفاصيل الوصفة (الأمر مكتمل أو ملغى).';

  @override
  String productionRecipeNameValue(String name) {
    return 'الوصفة: $name';
  }

  @override
  String get productionIngredientsChecklist => 'قائمة المكونات';

  @override
  String get productionRecipeNoIngredients =>
      'الوصفة النشطة لا تحتوي على مكونات.';

  @override
  String productionRecipeLoadError(String error) {
    return 'خطأ في تحميل تفاصيل الوصفة: $error';
  }

  @override
  String get productionIngredientNotFound => 'منتج المكوّن غير موجود';

  @override
  String productionIngredientRequired(
    String total,
    String unit,
    String per,
    String qty,
  ) {
    return 'مطلوب: $total $unit ($per × $qty)';
  }

  @override
  String productionIngredientAvailable(String stock, String unit) {
    return 'متاح: $stock $unit';
  }

  @override
  String get productionIngredientConsumed => 'مُستهلك';

  @override
  String get productionIngredientInStock => 'متوفر';

  @override
  String productionIngredientNeed(String amount) {
    return 'ينقص $amount';
  }

  @override
  String get productionSearchHint => 'ابحث برقم الأمر';

  @override
  String get productionClearAllFiltersTooltip => 'مسح كل عوامل التصفية';

  @override
  String get productionUnknownProduct => 'منتج غير معروف';

  @override
  String get productionClearAll => 'مسح الكل';

  @override
  String get productionFilterStatusLabel => 'الحالة';

  @override
  String get productionFilterAnyStatus => 'أي حالة';

  @override
  String get productionOrdersListTitle => 'أوامر الإنتاج';

  @override
  String get productionOrdersEmpty => 'لا توجد أوامر إنتاج بعد.';

  @override
  String productionOrderListSubtitle(String quantity, String status) {
    return '$quantity وحدة · $status';
  }

  @override
  String get recipesListTitle => 'الوصفات';

  @override
  String get recipesEmpty => 'لا توجد وصفات بعد. اضغط + لإضافة واحدة.';

  @override
  String get recipeActive => 'نشط';

  @override
  String get recipeInactive => 'غير نشط';

  @override
  String get recipeDetailTitle => 'الوصفة';

  @override
  String get recipeMakeActiveTooltip => 'تفعيل';

  @override
  String get recipeNotFound => 'الوصفة غير موجودة.';

  @override
  String get recipeActiveLabel => 'الوصفة النشطة';

  @override
  String get recipeIngredientsHeading => 'المكونات';

  @override
  String recipeQuantityPerUnit(String quantity, String unit) {
    return '$quantity $unit / وحدة';
  }

  @override
  String recipeForOutputProduct(String name) {
    return 'لمنتج ناتج: $name';
  }

  @override
  String get recipeIngredientLoading => 'جارٍ تحميل المكوّن…';

  @override
  String get recipeNoIngredientsYet => 'لا توجد مكونات بعد — اضغط + للإضافة.';

  @override
  String get recipeAddIngredientTitle => 'إضافة مكوّن';

  @override
  String get recipeEditIngredientTitle => 'تعديل المكوّن';

  @override
  String get recipeIngredientProductLabel => 'منتج المكوّن';

  @override
  String get recipeIngredientQuantityLabel => 'الكمية لكل وحدة منتَجة';

  @override
  String get recipeIngredientQuantityHelper => 'لكل وحدة من الناتج';

  @override
  String get recipeSaveIngredientButton => 'حفظ';

  @override
  String get recipeRemoveIngredientButton => 'إزالة';

  @override
  String get recipeSelectIngredientError => 'اختر منتج المكوّن.';

  @override
  String get recipeNoProductsToAdd => 'لا توجد منتجات أخرى متاحة للإضافة.';

  @override
  String get recipeCreateTitle => 'وصفة جديدة';

  @override
  String get recipeNameLabel => 'اسم الوصفة';

  @override
  String get recipeMakeActiveSwitchLabel => 'اجعل هذه الوصفة نشطة';

  @override
  String get poStatusDraft => 'مسودة';

  @override
  String get poStatusSent => 'مُرسل';

  @override
  String get poStatusConfirmed => 'مؤكد';

  @override
  String get poStatusReceived => 'مستلم';

  @override
  String get poStatusCancelled => 'ملغى';

  @override
  String get poReceiptStatusNotReceived => 'لم يُستلم';

  @override
  String get poReceiptStatusPartial => 'استلام جزئي';

  @override
  String get poReceiptStatusFullyReceived => 'استلام كامل';

  @override
  String get poPaymentStatusNotPaid => 'غير مدفوع';

  @override
  String get poPaymentStatusPartial => 'جزئي';

  @override
  String get poPaymentStatusPaid => 'مدفوع';

  @override
  String get poDashboardTitle => 'لوحة المشتريات';

  @override
  String get poViewAllOrdersTooltip => 'عرض جميع الطلبات';

  @override
  String get poOutstandingPayables => 'مستحقات معلقة';

  @override
  String get poAllPaymentsCleared => 'جميع المدفوعات مسددة';

  @override
  String get poPaymentStatusBreakdown => 'توزيع حالة الدفع';

  @override
  String get poReceiptStatusBreakdown => 'توزيع حالة الاستلام';

  @override
  String get poSearchHint => 'ابحث برقم أمر الشراء';

  @override
  String get poClearAllFiltersTooltip => 'مسح جميع الفلاتر';

  @override
  String get poListTitle => 'أوامر الشراء';

  @override
  String get poListEmpty => 'لا توجد أوامر شراء بعد. اضغط + لإنشاء واحد.';

  @override
  String get poUnknownSupplier => 'مورد غير معروف';

  @override
  String get poLoadingSupplier => 'جارٍ تحميل المورد...';

  @override
  String get poClearAll => 'مسح الكل';

  @override
  String get poFilterStatusLabel => 'الحالة';

  @override
  String get poFilterAnyStatus => 'أي حالة';

  @override
  String get poFilterDateLabel => 'التاريخ';

  @override
  String get poFilterPaymentLabel => 'الدفع';

  @override
  String get poFilterAnyPayment => 'أي دفعة';

  @override
  String get poFilterReceiptLabel => 'الاستلام';

  @override
  String get poFilterAnyReceipt => 'أي استلام';

  @override
  String get poDateToday => 'اليوم';

  @override
  String get poDateWeek => 'هذا الأسبوع';

  @override
  String get poDateMonth => 'هذا الشهر';

  @override
  String get poDateAllDates => 'كل التواريخ';

  @override
  String get poDateAll => 'الكل';

  @override
  String get poSelectSupplierTitle => 'اختر المورد';

  @override
  String get poSelectProductTitle => 'اختر المنتج';

  @override
  String poPriceEach(String price) {
    return '$price للقطعة';
  }

  @override
  String get poPickSupplierError => 'اختر موردًا.';

  @override
  String get poCreateTitle => 'أمر شراء جديد';

  @override
  String get poSupplierLabel => 'المورد';

  @override
  String get poSelectSupplierPlaceholder => 'اختر موردًا...';

  @override
  String get poOrderItemsHeading => 'عناصر الطلب';

  @override
  String get poNoProductsAdded => 'لم تتم إضافة منتجات بعد.';

  @override
  String get poQtyLabel => 'الكمية';

  @override
  String get poAddProductButton => 'إضافة منتج';

  @override
  String get poEstimatedTotal => 'الإجمالي التقديري';

  @override
  String get poCreateDraftButton => 'إنشاء مسودة';

  @override
  String get poDetailTitle => 'أمر الشراء';

  @override
  String get poNotFound => 'غير موجود';

  @override
  String get poLinesHeading => 'البنود';

  @override
  String poLineQtyOrderedReceived(String ordered, String received) {
    return 'الكمية المطلوبة: $ordered · المستلمة: $received';
  }

  @override
  String get poReceiptsHeading => 'الإيصالات';

  @override
  String get poNoReceiptsYet => 'لا توجد إيصالات مسجلة بعد.';

  @override
  String get poPostButton => 'ترحيل';

  @override
  String get poPaymentsHeading => 'المدفوعات';

  @override
  String get poNoPaymentsYet => 'لا توجد مدفوعات مسجلة بعد.';

  @override
  String get poSendButton => 'إرسال';

  @override
  String get poConfirmButton => 'تأكيد';

  @override
  String get poReceiveGoodsButton => 'استلام البضائع';

  @override
  String get poAddPaymentButton => 'إضافة دفعة';

  @override
  String get poCancelOrderButton => 'إلغاء الأمر';

  @override
  String poCancelOrderConfirm(String orderNumber) {
    return 'إلغاء $orderNumber؟';
  }

  @override
  String get poReceiveGoodsTitle => 'استلام البضائع (مسودة)';

  @override
  String get poReceivingForOrder => 'الاستلام لأمر:';

  @override
  String get poSelectQuantitiesHeading => 'اختر الكميات المراد استلامها';

  @override
  String poRemainingQty(String qty) {
    return 'المتبقي: $qty';
  }

  @override
  String get poReceiveLabel => 'استلام';

  @override
  String get poSaveDraftReceiptButton => 'حفظ مسودة الإيصال';

  @override
  String get poRecordPaymentTitle => 'تسجيل دفعة (مسودة)';

  @override
  String get poRecordingPaymentFor => 'تسجيل دفعة لـ:';

  @override
  String poOrderTotalLine(String orderNumber, String total) {
    return '$orderNumber · إجمالي الطلب: $total';
  }

  @override
  String get poPaymentInfoHeading => 'معلومات الدفع';

  @override
  String get poAmountLabel => 'المبلغ';

  @override
  String get poMethodLabel => 'طريقة الدفع';

  @override
  String get poInvalidAmountError => 'أدخل مبلغًا صحيحًا.';

  @override
  String get poSaveDraftPaymentButton => 'حفظ مسودة الدفعة';

  @override
  String get poStatsDaily => 'إحصاءات يومية';

  @override
  String get poStatsWeekly => 'إحصاءات أسبوعية';

  @override
  String get poStatsMonthly => 'إحصاءات شهرية';

  @override
  String get poStatsYearly => 'إحصاءات سنوية';

  @override
  String get poStatsDefault => 'إحصاءات';

  @override
  String get poStatTotalOrders => 'إجمالي الطلبات';

  @override
  String get poStatTotalPurchases => 'إجمالي المشتريات';

  @override
  String get soStatusDraft => 'مسودة';

  @override
  String get soStatusConfirmed => 'مؤكد';

  @override
  String get soStatusProcessing => 'قيد المعالجة';

  @override
  String get soStatusShipped => 'تم الشحن';

  @override
  String get soStatusDelivered => 'تم التسليم';

  @override
  String get soStatusCancelled => 'ملغى';

  @override
  String get soPaymentStatusNotPaid => 'غير مدفوع';

  @override
  String get soPaymentStatusPartial => 'جزئي';

  @override
  String get soPaymentStatusPaid => 'مدفوع';

  @override
  String get soShippingStatusNotShipped => 'لم يُشحن';

  @override
  String get soShippingStatusPartiallyShipped => 'شحن جزئي';

  @override
  String get soShippingStatusFullyShipped => 'شحن كامل';

  @override
  String get soDashboardTitle => 'لوحة المبيعات';

  @override
  String get soViewAllOrdersTooltip => 'عرض جميع الطلبات';

  @override
  String get soOutstandingReceivables => 'مستحقات معلقة';

  @override
  String get soAllPaymentsCleared => 'جميع المدفوعات مسددة';

  @override
  String get soPaymentStatusBreakdown => 'توزيع حالة الدفع';

  @override
  String get soShippingStatusBreakdown => 'توزيع حالة الشحن';

  @override
  String get soSearchHint => 'ابحث برقم أمر البيع';

  @override
  String get soClearAllFiltersTooltip => 'مسح جميع الفلاتر';

  @override
  String get soListTitle => 'أوامر البيع';

  @override
  String get soListEmpty => 'لا توجد أوامر بيع بعد. اضغط + لإنشاء واحد.';

  @override
  String get soUnknownCustomer => 'عميل غير معروف';

  @override
  String get soLoadingCustomer => 'جارٍ تحميل العميل...';

  @override
  String get soClearAll => 'مسح الكل';

  @override
  String get soFilterStatusLabel => 'الحالة';

  @override
  String get soFilterAnyStatus => 'أي حالة';

  @override
  String get soFilterDateLabel => 'التاريخ';

  @override
  String get soFilterPaymentLabel => 'الدفع';

  @override
  String get soFilterAnyPayment => 'أي دفعة';

  @override
  String get soFilterShippingLabel => 'الشحن';

  @override
  String get soFilterAnyShipping => 'أي شحن';

  @override
  String get soDateToday => 'اليوم';

  @override
  String get soDateWeek => 'هذا الأسبوع';

  @override
  String get soDateMonth => 'هذا الشهر';

  @override
  String get soDateAllDates => 'كل التواريخ';

  @override
  String get soDateAll => 'الكل';

  @override
  String get soSelectCustomerTitle => 'اختر العميل';

  @override
  String get soPickCustomerError => 'اختر عميلاً.';

  @override
  String get soCreateTitle => 'أمر بيع جديد';

  @override
  String get soCustomerLabel => 'العميل';

  @override
  String get soSelectCustomerPlaceholder => 'اختر عميلاً...';

  @override
  String get soDetailTitle => 'تفاصيل الطلب';

  @override
  String get soOrderNotFound => 'الطلب غير موجود';

  @override
  String get soLineItemsHeading => 'بنود الطلب';

  @override
  String soLineQtyOrderedShipped(String ordered, String shipped) {
    return 'الكمية المطلوبة: $ordered · المشحونة: $shipped';
  }

  @override
  String get soShipmentsHeading => 'الشحنات';

  @override
  String get soNoShipmentsYet => 'لا توجد شحنات مسجلة بعد.';

  @override
  String get soConfirmOrderButton => 'تأكيد الطلب';

  @override
  String get soStartProcessingButton => 'بدء المعالجة';

  @override
  String get soAddPaymentButton => 'إضافة دفعة';

  @override
  String get soShipItemsButton => 'شحن العناصر';

  @override
  String get soCreateShipmentTitle => 'إنشاء شحنة';

  @override
  String get soCancelOrderLabel => 'إلغاء الطلب';

  @override
  String get soShippingForOrder => 'الشحن لأمر:';

  @override
  String get soSelectQtyToShipHeading => 'اختر الكميات المراد شحنها';

  @override
  String get soShipQtyLabel => 'كمية الشحن';

  @override
  String get soShipButton => 'شحن';

  @override
  String get soRecordPaymentTitle => 'تسجيل دفعة';

  @override
  String get soAmountPaidLabel => 'المبلغ المدفوع';

  @override
  String get soPaymentMethodLabel => 'طريقة الدفع';

  @override
  String get soSavePaymentButton => 'حفظ الدفعة';

  @override
  String get salesDashboardQuickActionsHeading => 'إجراءات سريعة';

  @override
  String get salesDashboardCustomersAction => 'العملاء';

  @override
  String get salesDashboardOrdersAction => 'الطلبات';

  @override
  String get purchasingDashboardQuickActionsHeading => 'إجراءات سريعة';

  @override
  String get purchasingDashboardSuppliersAction => 'الموردين';

  @override
  String get purchasingDashboardOrdersAction => 'الطلبات';

  @override
  String get soStatTotalSales => 'إجمالي المبيعات';

  @override
  String get moreEmployees => 'الموظفون';

  @override
  String get employeesTitle => 'الموظفون';

  @override
  String get employeesEmpty => 'لا يوجد موظفون بعد. اضغط + لإضافة موظف.';

  @override
  String get employeeInactive => 'غير نشط';

  @override
  String get employeeDetailTitle => 'الموظف';

  @override
  String get employeeNotFound => 'الموظف غير موجود';

  @override
  String get employeeOwedLabel => 'مستحق';

  @override
  String get employeeCreditLabel => 'رصيد';

  @override
  String get employeeActiveLabel => 'نشط';

  @override
  String get employeeRecordPaymentAction => 'تسجيل دفعة';

  @override
  String get employeeEarningsHeading => 'الأرباح';

  @override
  String get employeeEarningsEmpty => 'لا توجد أرباح بعد.';

  @override
  String get employeePaymentsHeading => 'الدفعات';

  @override
  String get employeePaymentsEmpty => 'لا توجد دفعات بعد.';

  @override
  String get employeeRatesHeading => 'أسعار القطعة (استثناءات)';

  @override
  String get employeeRatesEmpty => 'لا توجد استثناءات بعد.';

  @override
  String get employeeRateAddAction => 'إضافة استثناء';

  @override
  String employeeQtyRateLine(String qty, String rate) {
    return '$qty × $rate';
  }

  @override
  String get employeeNewTitle => 'موظف جديد';

  @override
  String get employeeEditTitle => 'تعديل الموظف';

  @override
  String get employeeNameLabel => 'الاسم';

  @override
  String get employeePhoneLabel => 'الهاتف';

  @override
  String get employeeNotesLabel => 'ملاحظات';

  @override
  String get employeeSaveButton => 'حفظ';

  @override
  String get employeeNameRequiredError => 'اسم الموظف مطلوب.';

  @override
  String get employeeRecordPaymentTitle => 'تسجيل دفعة';

  @override
  String get employeePaymentAmountLabel => 'المبلغ';

  @override
  String get employeePaymentDateLabel => 'التاريخ';

  @override
  String get employeePaymentNotesLabel => 'ملاحظات';

  @override
  String get employeePaymentInvalidAmountError =>
      'أدخل مبلغًا صحيحًا أكبر من صفر.';

  @override
  String get employeeRateSheetAddTitle => 'إضافة استثناء سعر القطعة';

  @override
  String get employeeRateSheetEditTitle => 'تعديل استثناء سعر القطعة';

  @override
  String get employeeRateProductLabel => 'المنتج';

  @override
  String get employeeRateRateLabel => 'السعر';

  @override
  String employeeRateDefaultHint(String rate) {
    return 'السعر الافتراضي للمنتج: $rate';
  }

  @override
  String get employeeRateRemoveAction => 'إزالة الاستثناء';

  @override
  String get employeeRateInvalidError => 'اختر منتجًا وأدخل سعرًا أكبر من صفر.';

  @override
  String get employeeRateNoProductsAvailable =>
      'جميع المنتجات لديها بالفعل استثناء لهذا الموظف.';
}
