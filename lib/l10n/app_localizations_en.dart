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

  @override
  String get coreStatusLow => 'Low';

  @override
  String get coreStatusOut => 'Out';

  @override
  String get coreSearchHint => 'Search';

  @override
  String get coreCancel => 'Cancel';

  @override
  String get coreDelete => 'Delete';

  @override
  String get coreRetry => 'Retry';

  @override
  String get coreNothingHere => 'Nothing here yet.';

  @override
  String get coreSomethingWrong => 'Something went wrong.';

  @override
  String get coreCouldntLoadMore => 'Couldn\'t load more. Retry';

  @override
  String get navProducts => 'Products';

  @override
  String get navSales => 'Sales';

  @override
  String get navPurchasing => 'Purchasing';

  @override
  String get navMore => 'More';

  @override
  String get navMoreFeaturesTitle => 'More Features';

  @override
  String get navStock => 'Stock';

  @override
  String get navProduction => 'Production';

  @override
  String get navSuppliers => 'Suppliers';

  @override
  String get navCustomers => 'Customers';

  @override
  String get navSettings => 'Settings';

  @override
  String get categoryEditTitle => 'Edit category';

  @override
  String get categoryNewTitle => 'New category';

  @override
  String get categoryDetailsHeading => 'Category Details';

  @override
  String get categoryNameLabel => 'Name';

  @override
  String get categoryNameRequired => 'Name is required';

  @override
  String get categoryParentLabel => 'Parent (optional)';

  @override
  String get categoryParentNone => '— None —';

  @override
  String get categorySave => 'Save';

  @override
  String get categoriesTitle => 'Categories';

  @override
  String get categoryEmptyTitle => 'No categories yet';

  @override
  String get categoryEmptySubtitle => 'Group your products with categories.';

  @override
  String get categoryEmptyAction => 'Add category';

  @override
  String get categoryDeleteTitle => 'Delete category';

  @override
  String categoryDeleteConfirm(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get unitEditTitle => 'Edit unit';

  @override
  String get unitNewTitle => 'New unit';

  @override
  String get unitBasicInfoHeading => 'Basic info';

  @override
  String get unitNameLabel => 'Name';

  @override
  String get unitFieldRequired => 'Required';

  @override
  String get unitSymbolLabel => 'Symbol';

  @override
  String get unitTypeLabel => 'Type';

  @override
  String get unitConversionHeading => 'Conversion';

  @override
  String get unitBaseUnitLabel => 'Base unit';

  @override
  String get unitConversionFactorLabel => 'Conversion factor (to base)';

  @override
  String get unitSave => 'Save';

  @override
  String get unitsTitle => 'Units';

  @override
  String get unitEmptyTitle => 'No units yet';

  @override
  String get unitEmptySubtitle => 'Define units like piece, kg, or litre.';

  @override
  String get unitEmptyAction => 'Add unit';

  @override
  String get unitBaseTag => 'BASE';

  @override
  String unitConversionFactorSuffix(String factor) {
    return '× $factor conversion factor';
  }

  @override
  String get unitDeleteTitle => 'Delete unit';

  @override
  String unitDeleteConfirm(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get productEditTitle => 'Edit product';

  @override
  String get productNewTitle => 'New product';

  @override
  String get productDetailsHeading => 'Details';

  @override
  String get productNameLabel => 'Name';

  @override
  String get productNameRequired => 'Name is required';

  @override
  String get productDescriptionLabel => 'Description';

  @override
  String get productCategoryLabel => 'Category';

  @override
  String get productCategoryNone => '— None —';

  @override
  String get productUnitLabel => 'Unit';

  @override
  String get productPricingHeading => 'Pricing';

  @override
  String get productPurchasePriceLabel => 'Purchase price';

  @override
  String get productSellingPriceLabel => 'Selling price';

  @override
  String get productStockIdHeading => 'Stock & Identification';

  @override
  String get productMinimumStockLabel => 'Minimum stock';

  @override
  String get productBarcodeLabel => 'Barcode';

  @override
  String get productSave => 'Save';

  @override
  String get productChangePhoto => 'Change photo';

  @override
  String get productAddPhoto => 'Add photo';

  @override
  String get productTitle => 'Product';

  @override
  String get productNotFound => 'Product not found.';

  @override
  String get productSellingPriceRow => 'Selling Price';

  @override
  String get productPricingDetailsHeading => 'Pricing & Details';

  @override
  String get productPurchasePriceRow => 'Purchase Price';

  @override
  String get productBarcodeRow => 'Barcode';

  @override
  String get productRecordStockMovement => 'Record stock movement';

  @override
  String get productViewStockHistory => 'View stock history';

  @override
  String get productStockLevelHeading => 'Stock Level';

  @override
  String get productCurrentStockLabel => 'Current Stock';

  @override
  String get productMinRequiredLabel => 'Min Required';

  @override
  String get productUnitSuffixPcs => 'pcs';

  @override
  String get productHealthyBadge => 'HEALTHY';

  @override
  String get productValuationHeading => 'Inventory Valuation';

  @override
  String productValuationBasedOn(String qty, String price) {
    return 'Based on $qty pcs @ $price purchase price';
  }

  @override
  String get productsTitle => 'Products';

  @override
  String get productSearchHint => 'Search product name or barcode';

  @override
  String get productFilterLowStock => 'Low Stock';

  @override
  String get productFilterLowStockOnly => 'Low Stock Only';

  @override
  String get productFilterOutOfStock => 'Out of Stock';

  @override
  String get productFilterOutOfStockOnly => 'Out of Stock Only';

  @override
  String get productFilterCategory => 'Category';

  @override
  String get productFilterAllCategories => 'All Categories';

  @override
  String get productFilterAll => 'All';

  @override
  String get productEmptyTitle => 'No products yet';

  @override
  String get productDashboardTitle => 'Inventory Dashboard';

  @override
  String productDashboardErrorLoading(String error) {
    return 'Error loading dashboard: $error';
  }

  @override
  String get productDashboardRetry => 'Retry';

  @override
  String get productDashboardRestockRequiredTitle => 'Restock Required';

  @override
  String productDashboardRestockRequiredSubtitle(int count) {
    return '$count products are out of stock. Tap to restock.';
  }

  @override
  String get productDashboardLowStockAlertTitle => 'Low Stock Alert';

  @override
  String productDashboardLowStockAlertSubtitle(int count) {
    return '$count products are running low. Tap to review.';
  }

  @override
  String get productDashboardHealthyTitle => 'Stock Levels Healthy';

  @override
  String get productDashboardHealthySubtitle =>
      'All products are well stocked. No alerts.';

  @override
  String get productDashboardBreakdownHeading => 'Stock Status Breakdown';

  @override
  String get productDashboardWellStocked => 'Well Stocked';

  @override
  String get productDashboardLowStock => 'Low Stock';

  @override
  String get productDashboardOutOfStock => 'Out of Stock';

  @override
  String get productDashboardQuickActionsHeading => 'Quick Actions';

  @override
  String get productDashboardManageProducts => 'Manage Products';

  @override
  String get productStatTotalValue => 'Total Value';

  @override
  String get productStatActiveProducts => 'Active Products';

  @override
  String get productStatLowStockItems => 'Low Stock Items';

  @override
  String get productStatOutOfStock => 'Out of Stock';

  @override
  String get productStatInventorySummary => 'Inventory Summary';

  @override
  String get productStatStockAlerts => 'Stock Alerts';

  @override
  String get productStatStatistics => 'Statistics';

  @override
  String get barcodeScanTitle => 'Scan barcode';

  @override
  String get barcodeScanHint => 'Align barcode within the frame';

  @override
  String stockMovementScreenTitle(String productName) {
    return 'Stock — $productName';
  }

  @override
  String get stockMovementTypeHeading => 'Movement type';

  @override
  String get stockMovementTypeIn => 'In';

  @override
  String get stockMovementTypeOut => 'Out';

  @override
  String get stockMovementTypeAdjust => 'Adjust';

  @override
  String get stockMovementDetailsHeading => 'Details';

  @override
  String get stockMovementQuantityAdjustLabel => 'Quantity (use − to reduce)';

  @override
  String get stockMovementQuantityLabel => 'Quantity';

  @override
  String get stockMovementQuantityInvalid => 'Enter a number';

  @override
  String get stockMovementQuantityZero => 'Quantity must not be zero';

  @override
  String get stockMovementNotesLabel => 'Notes (optional)';

  @override
  String get stockMovementRecordButton => 'Record';

  @override
  String get stockMovementsTitle => 'Stock movements';

  @override
  String get stockMovementEmptyTitle => 'No stock movements yet';

  @override
  String get stockMovementEmptySubtitle =>
      'Record stock in or out to see the ledger.';
}
