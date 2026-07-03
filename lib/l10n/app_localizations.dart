import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// Application name, shown as the app title.
  ///
  /// In en, this message translates to:
  /// **'InventoryHub'**
  String get appTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @sectionAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get sectionAppearance;

  /// No description provided for @sectionLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get sectionLanguage;

  /// No description provided for @sectionCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get sectionCurrency;

  /// No description provided for @sectionCatalog.
  ///
  /// In en, this message translates to:
  /// **'Catalog'**
  String get sectionCatalog;

  /// No description provided for @sectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get sectionAbout;

  /// No description provided for @sectionAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get sectionAccount;

  /// No description provided for @currencyUsd.
  ///
  /// In en, this message translates to:
  /// **'US Dollar (\$)'**
  String get currencyUsd;

  /// No description provided for @currencyDzd.
  ///
  /// In en, this message translates to:
  /// **'Algerian Dinar (دج)'**
  String get currencyDzd;

  /// No description provided for @currencySelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your currency'**
  String get currencySelectTitle;

  /// No description provided for @currencySelectSubtitle.
  ///
  /// In en, this message translates to:
  /// **'All prices and totals will be shown in this currency. You can change it later in Settings.'**
  String get currencySelectSubtitle;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @catalogCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get catalogCategories;

  /// No description provided for @catalogUnits.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get catalogUnits;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out?'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'You will need to sign in again to continue.'**
  String get logoutConfirmMessage;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @authSignInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get authSignInSubtitle;

  /// No description provided for @authUsernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get authUsernameLabel;

  /// No description provided for @authPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// No description provided for @authInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid username or password'**
  String get authInvalidCredentials;

  /// No description provided for @authSignInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignInButton;

  /// No description provided for @authDemoHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to fill demo: admin / admin'**
  String get authDemoHint;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingSlide1Title.
  ///
  /// In en, this message translates to:
  /// **'Know your stock'**
  String get onboardingSlide1Title;

  /// No description provided for @onboardingSlide1Body.
  ///
  /// In en, this message translates to:
  /// **'Track every product, category, and stock movement — instantly, and fully offline.'**
  String get onboardingSlide1Body;

  /// No description provided for @onboardingSlide2Title.
  ///
  /// In en, this message translates to:
  /// **'Sell and restock'**
  String get onboardingSlide2Title;

  /// No description provided for @onboardingSlide2Body.
  ///
  /// In en, this message translates to:
  /// **'Raise sale and purchase orders, record payments, and keep stock in sync automatically.'**
  String get onboardingSlide2Body;

  /// No description provided for @onboardingSlide3Title.
  ///
  /// In en, this message translates to:
  /// **'Make and manage'**
  String get onboardingSlide3Title;

  /// No description provided for @onboardingSlide3Body.
  ///
  /// In en, this message translates to:
  /// **'Turn ingredients into products with recipes, and track it all from live dashboards.'**
  String get onboardingSlide3Body;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingGetStarted;

  /// No description provided for @coreStatusLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get coreStatusLow;

  /// No description provided for @coreStatusOut.
  ///
  /// In en, this message translates to:
  /// **'Out'**
  String get coreStatusOut;

  /// No description provided for @coreSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get coreSearchHint;

  /// No description provided for @coreCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get coreCancel;

  /// No description provided for @coreDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get coreDelete;

  /// No description provided for @coreRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get coreRetry;

  /// No description provided for @coreNothingHere.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet.'**
  String get coreNothingHere;

  /// No description provided for @coreSomethingWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get coreSomethingWrong;

  /// No description provided for @coreCouldntLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load more. Retry'**
  String get coreCouldntLoadMore;

  /// No description provided for @navProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get navProducts;

  /// No description provided for @navSales.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get navSales;

  /// No description provided for @navPurchasing.
  ///
  /// In en, this message translates to:
  /// **'Purchasing'**
  String get navPurchasing;

  /// No description provided for @navMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navMore;

  /// No description provided for @navMoreFeaturesTitle.
  ///
  /// In en, this message translates to:
  /// **'More Features'**
  String get navMoreFeaturesTitle;

  /// No description provided for @navStock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get navStock;

  /// No description provided for @navProduction.
  ///
  /// In en, this message translates to:
  /// **'Production'**
  String get navProduction;

  /// No description provided for @navSuppliers.
  ///
  /// In en, this message translates to:
  /// **'Suppliers'**
  String get navSuppliers;

  /// No description provided for @navCustomers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get navCustomers;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @categoryEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get categoryEditTitle;

  /// No description provided for @categoryNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New category'**
  String get categoryNewTitle;

  /// No description provided for @categoryDetailsHeading.
  ///
  /// In en, this message translates to:
  /// **'Category Details'**
  String get categoryDetailsHeading;

  /// No description provided for @categoryNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get categoryNameLabel;

  /// No description provided for @categoryNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get categoryNameRequired;

  /// No description provided for @categoryParentLabel.
  ///
  /// In en, this message translates to:
  /// **'Parent (optional)'**
  String get categoryParentLabel;

  /// No description provided for @categoryParentNone.
  ///
  /// In en, this message translates to:
  /// **'— None —'**
  String get categoryParentNone;

  /// No description provided for @categorySave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get categorySave;

  /// No description provided for @categoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categoriesTitle;

  /// No description provided for @categoryEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No categories yet'**
  String get categoryEmptyTitle;

  /// No description provided for @categoryEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Group your products with categories.'**
  String get categoryEmptySubtitle;

  /// No description provided for @categoryEmptyAction.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get categoryEmptyAction;

  /// No description provided for @categoryDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete category'**
  String get categoryDeleteTitle;

  /// No description provided for @categoryDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String categoryDeleteConfirm(String name);

  /// No description provided for @unitEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit unit'**
  String get unitEditTitle;

  /// No description provided for @unitNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New unit'**
  String get unitNewTitle;

  /// No description provided for @unitBasicInfoHeading.
  ///
  /// In en, this message translates to:
  /// **'Basic info'**
  String get unitBasicInfoHeading;

  /// No description provided for @unitNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get unitNameLabel;

  /// No description provided for @unitFieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get unitFieldRequired;

  /// No description provided for @unitSymbolLabel.
  ///
  /// In en, this message translates to:
  /// **'Symbol'**
  String get unitSymbolLabel;

  /// No description provided for @unitTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get unitTypeLabel;

  /// No description provided for @unitConversionHeading.
  ///
  /// In en, this message translates to:
  /// **'Conversion'**
  String get unitConversionHeading;

  /// No description provided for @unitBaseUnitLabel.
  ///
  /// In en, this message translates to:
  /// **'Base unit'**
  String get unitBaseUnitLabel;

  /// No description provided for @unitConversionFactorLabel.
  ///
  /// In en, this message translates to:
  /// **'Conversion factor (to base)'**
  String get unitConversionFactorLabel;

  /// No description provided for @unitSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get unitSave;

  /// No description provided for @unitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get unitsTitle;

  /// No description provided for @unitEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No units yet'**
  String get unitEmptyTitle;

  /// No description provided for @unitEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Define units like piece, kg, or litre.'**
  String get unitEmptySubtitle;

  /// No description provided for @unitEmptyAction.
  ///
  /// In en, this message translates to:
  /// **'Add unit'**
  String get unitEmptyAction;

  /// No description provided for @unitBaseTag.
  ///
  /// In en, this message translates to:
  /// **'BASE'**
  String get unitBaseTag;

  /// No description provided for @unitConversionFactorSuffix.
  ///
  /// In en, this message translates to:
  /// **'× {factor} conversion factor'**
  String unitConversionFactorSuffix(String factor);

  /// No description provided for @unitDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete unit'**
  String get unitDeleteTitle;

  /// No description provided for @unitDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String unitDeleteConfirm(String name);

  /// No description provided for @productEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit product'**
  String get productEditTitle;

  /// No description provided for @productNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New product'**
  String get productNewTitle;

  /// No description provided for @productDetailsHeading.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get productDetailsHeading;

  /// No description provided for @productNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get productNameLabel;

  /// No description provided for @productNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get productNameRequired;

  /// No description provided for @productDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get productDescriptionLabel;

  /// No description provided for @productCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get productCategoryLabel;

  /// No description provided for @productCategoryNone.
  ///
  /// In en, this message translates to:
  /// **'— None —'**
  String get productCategoryNone;

  /// No description provided for @productUnitLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get productUnitLabel;

  /// No description provided for @productPricingHeading.
  ///
  /// In en, this message translates to:
  /// **'Pricing'**
  String get productPricingHeading;

  /// No description provided for @productPurchasePriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Purchase price'**
  String get productPurchasePriceLabel;

  /// No description provided for @productSellingPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Selling price'**
  String get productSellingPriceLabel;

  /// No description provided for @productStockIdHeading.
  ///
  /// In en, this message translates to:
  /// **'Stock & Identification'**
  String get productStockIdHeading;

  /// No description provided for @productMinimumStockLabel.
  ///
  /// In en, this message translates to:
  /// **'Minimum stock'**
  String get productMinimumStockLabel;

  /// No description provided for @productBarcodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get productBarcodeLabel;

  /// No description provided for @productSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get productSave;

  /// No description provided for @productChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get productChangePhoto;

  /// No description provided for @productAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get productAddPhoto;

  /// No description provided for @productTitle.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get productTitle;

  /// No description provided for @productNotFound.
  ///
  /// In en, this message translates to:
  /// **'Product not found.'**
  String get productNotFound;

  /// No description provided for @productSellingPriceRow.
  ///
  /// In en, this message translates to:
  /// **'Selling Price'**
  String get productSellingPriceRow;

  /// No description provided for @productPricingDetailsHeading.
  ///
  /// In en, this message translates to:
  /// **'Pricing & Details'**
  String get productPricingDetailsHeading;

  /// No description provided for @productPurchasePriceRow.
  ///
  /// In en, this message translates to:
  /// **'Purchase Price'**
  String get productPurchasePriceRow;

  /// No description provided for @productBarcodeRow.
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get productBarcodeRow;

  /// No description provided for @productRecordStockMovement.
  ///
  /// In en, this message translates to:
  /// **'Record stock movement'**
  String get productRecordStockMovement;

  /// No description provided for @productViewStockHistory.
  ///
  /// In en, this message translates to:
  /// **'View stock history'**
  String get productViewStockHistory;

  /// No description provided for @productStockLevelHeading.
  ///
  /// In en, this message translates to:
  /// **'Stock Level'**
  String get productStockLevelHeading;

  /// No description provided for @productCurrentStockLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Stock'**
  String get productCurrentStockLabel;

  /// No description provided for @productMinRequiredLabel.
  ///
  /// In en, this message translates to:
  /// **'Min Required'**
  String get productMinRequiredLabel;

  /// No description provided for @productUnitSuffixPcs.
  ///
  /// In en, this message translates to:
  /// **'pcs'**
  String get productUnitSuffixPcs;

  /// No description provided for @productHealthyBadge.
  ///
  /// In en, this message translates to:
  /// **'HEALTHY'**
  String get productHealthyBadge;

  /// No description provided for @productValuationHeading.
  ///
  /// In en, this message translates to:
  /// **'Inventory Valuation'**
  String get productValuationHeading;

  /// No description provided for @productValuationBasedOn.
  ///
  /// In en, this message translates to:
  /// **'Based on {qty} pcs @ {price} purchase price'**
  String productValuationBasedOn(String qty, String price);

  /// No description provided for @productsTitle.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get productsTitle;

  /// No description provided for @productSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search product name or barcode'**
  String get productSearchHint;

  /// No description provided for @productFilterLowStock.
  ///
  /// In en, this message translates to:
  /// **'Low Stock'**
  String get productFilterLowStock;

  /// No description provided for @productFilterLowStockOnly.
  ///
  /// In en, this message translates to:
  /// **'Low Stock Only'**
  String get productFilterLowStockOnly;

  /// No description provided for @productFilterOutOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get productFilterOutOfStock;

  /// No description provided for @productFilterOutOfStockOnly.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock Only'**
  String get productFilterOutOfStockOnly;

  /// No description provided for @productFilterCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get productFilterCategory;

  /// No description provided for @productFilterAllCategories.
  ///
  /// In en, this message translates to:
  /// **'All Categories'**
  String get productFilterAllCategories;

  /// No description provided for @productFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get productFilterAll;

  /// No description provided for @productEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No products yet'**
  String get productEmptyTitle;

  /// No description provided for @productDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Inventory Dashboard'**
  String get productDashboardTitle;

  /// No description provided for @productDashboardErrorLoading.
  ///
  /// In en, this message translates to:
  /// **'Error loading dashboard: {error}'**
  String productDashboardErrorLoading(String error);

  /// No description provided for @productDashboardRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get productDashboardRetry;

  /// No description provided for @productDashboardRestockRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Restock Required'**
  String get productDashboardRestockRequiredTitle;

  /// No description provided for @productDashboardRestockRequiredSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} products are out of stock. Tap to restock.'**
  String productDashboardRestockRequiredSubtitle(int count);

  /// No description provided for @productDashboardLowStockAlertTitle.
  ///
  /// In en, this message translates to:
  /// **'Low Stock Alert'**
  String get productDashboardLowStockAlertTitle;

  /// No description provided for @productDashboardLowStockAlertSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} products are running low. Tap to review.'**
  String productDashboardLowStockAlertSubtitle(int count);

  /// No description provided for @productDashboardHealthyTitle.
  ///
  /// In en, this message translates to:
  /// **'Stock Levels Healthy'**
  String get productDashboardHealthyTitle;

  /// No description provided for @productDashboardHealthySubtitle.
  ///
  /// In en, this message translates to:
  /// **'All products are well stocked. No alerts.'**
  String get productDashboardHealthySubtitle;

  /// No description provided for @productDashboardBreakdownHeading.
  ///
  /// In en, this message translates to:
  /// **'Stock Status Breakdown'**
  String get productDashboardBreakdownHeading;

  /// No description provided for @productDashboardWellStocked.
  ///
  /// In en, this message translates to:
  /// **'Well Stocked'**
  String get productDashboardWellStocked;

  /// No description provided for @productDashboardLowStock.
  ///
  /// In en, this message translates to:
  /// **'Low Stock'**
  String get productDashboardLowStock;

  /// No description provided for @productDashboardOutOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get productDashboardOutOfStock;

  /// No description provided for @productDashboardQuickActionsHeading.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get productDashboardQuickActionsHeading;

  /// No description provided for @productDashboardManageProducts.
  ///
  /// In en, this message translates to:
  /// **'Manage Products'**
  String get productDashboardManageProducts;

  /// No description provided for @productStatTotalValue.
  ///
  /// In en, this message translates to:
  /// **'Total Value'**
  String get productStatTotalValue;

  /// No description provided for @productStatActiveProducts.
  ///
  /// In en, this message translates to:
  /// **'Active Products'**
  String get productStatActiveProducts;

  /// No description provided for @productStatLowStockItems.
  ///
  /// In en, this message translates to:
  /// **'Low Stock Items'**
  String get productStatLowStockItems;

  /// No description provided for @productStatOutOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get productStatOutOfStock;

  /// No description provided for @productStatInventorySummary.
  ///
  /// In en, this message translates to:
  /// **'Inventory Summary'**
  String get productStatInventorySummary;

  /// No description provided for @productStatStockAlerts.
  ///
  /// In en, this message translates to:
  /// **'Stock Alerts'**
  String get productStatStockAlerts;

  /// No description provided for @productStatStatistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get productStatStatistics;

  /// No description provided for @barcodeScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan barcode'**
  String get barcodeScanTitle;

  /// No description provided for @barcodeScanHint.
  ///
  /// In en, this message translates to:
  /// **'Align barcode within the frame'**
  String get barcodeScanHint;

  /// No description provided for @stockMovementScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Stock — {productName}'**
  String stockMovementScreenTitle(String productName);

  /// No description provided for @stockMovementTypeHeading.
  ///
  /// In en, this message translates to:
  /// **'Movement type'**
  String get stockMovementTypeHeading;

  /// No description provided for @stockMovementTypeIn.
  ///
  /// In en, this message translates to:
  /// **'In'**
  String get stockMovementTypeIn;

  /// No description provided for @stockMovementTypeOut.
  ///
  /// In en, this message translates to:
  /// **'Out'**
  String get stockMovementTypeOut;

  /// No description provided for @stockMovementTypeAdjust.
  ///
  /// In en, this message translates to:
  /// **'Adjust'**
  String get stockMovementTypeAdjust;

  /// No description provided for @stockMovementDetailsHeading.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get stockMovementDetailsHeading;

  /// No description provided for @stockMovementQuantityAdjustLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity (use − to reduce)'**
  String get stockMovementQuantityAdjustLabel;

  /// No description provided for @stockMovementQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get stockMovementQuantityLabel;

  /// No description provided for @stockMovementQuantityInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a number'**
  String get stockMovementQuantityInvalid;

  /// No description provided for @stockMovementQuantityZero.
  ///
  /// In en, this message translates to:
  /// **'Quantity must not be zero'**
  String get stockMovementQuantityZero;

  /// No description provided for @stockMovementNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get stockMovementNotesLabel;

  /// No description provided for @stockMovementRecordButton.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get stockMovementRecordButton;

  /// No description provided for @stockMovementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Stock movements'**
  String get stockMovementsTitle;

  /// No description provided for @stockMovementEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No stock movements yet'**
  String get stockMovementEmptyTitle;

  /// No description provided for @stockMovementEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Record stock in or out to see the ledger.'**
  String get stockMovementEmptySubtitle;

  /// No description provided for @productionHomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Production'**
  String get productionHomeTitle;

  /// No description provided for @productionStatusPlanned.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get productionStatusPlanned;

  /// No description provided for @productionStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get productionStatusInProgress;

  /// No description provided for @productionStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get productionStatusCompleted;

  /// No description provided for @productionStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get productionStatusCancelled;

  /// No description provided for @productionOrdersButton.
  ///
  /// In en, this message translates to:
  /// **'Production orders'**
  String get productionOrdersButton;

  /// No description provided for @recipesButton.
  ///
  /// In en, this message translates to:
  /// **'Recipes'**
  String get recipesButton;

  /// No description provided for @productionOrderCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'New production order'**
  String get productionOrderCreateTitle;

  /// No description provided for @productionOutputProductLabel.
  ///
  /// In en, this message translates to:
  /// **'Output product'**
  String get productionOutputProductLabel;

  /// No description provided for @productionQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get productionQuantityLabel;

  /// No description provided for @productionCreateButton.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get productionCreateButton;

  /// No description provided for @productionChooseOutputProductError.
  ///
  /// In en, this message translates to:
  /// **'Choose an output product.'**
  String get productionChooseOutputProductError;

  /// No description provided for @productionEnterValidQuantityError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid quantity.'**
  String get productionEnterValidQuantityError;

  /// No description provided for @productionActionDone.
  ///
  /// In en, this message translates to:
  /// **'Done.'**
  String get productionActionDone;

  /// No description provided for @productionOrderDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Production order'**
  String get productionOrderDetailTitle;

  /// No description provided for @productionOrderNotFound.
  ///
  /// In en, this message translates to:
  /// **'Order not found.'**
  String get productionOrderNotFound;

  /// No description provided for @productionOutputProductValue.
  ///
  /// In en, this message translates to:
  /// **'Output product: {productId}'**
  String productionOutputProductValue(String productId);

  /// No description provided for @productionQuantityValue.
  ///
  /// In en, this message translates to:
  /// **'Quantity: {quantity}'**
  String productionQuantityValue(String quantity);

  /// No description provided for @productionStatusValue.
  ///
  /// In en, this message translates to:
  /// **'Status: {status}'**
  String productionStatusValue(String status);

  /// No description provided for @productionStartedValue.
  ///
  /// In en, this message translates to:
  /// **'Started: {date}'**
  String productionStartedValue(String date);

  /// No description provided for @productionCompletedValue.
  ///
  /// In en, this message translates to:
  /// **'Completed: {date}'**
  String productionCompletedValue(String date);

  /// No description provided for @productionStartButton.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get productionStartButton;

  /// No description provided for @productionCompleteButton.
  ///
  /// In en, this message translates to:
  /// **'Complete (consume + produce)'**
  String get productionCompleteButton;

  /// No description provided for @productionCancelOrderButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel order'**
  String get productionCancelOrderButton;

  /// No description provided for @productionOrdersListTitle.
  ///
  /// In en, this message translates to:
  /// **'Production orders'**
  String get productionOrdersListTitle;

  /// No description provided for @productionOrdersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No production orders yet.'**
  String get productionOrdersEmpty;

  /// No description provided for @productionOrderListSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{quantity} units · {status}'**
  String productionOrderListSubtitle(String quantity, String status);

  /// No description provided for @recipesListTitle.
  ///
  /// In en, this message translates to:
  /// **'Recipes'**
  String get recipesListTitle;

  /// No description provided for @recipesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No recipes yet. Tap + to add one.'**
  String get recipesEmpty;

  /// No description provided for @recipeActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get recipeActive;

  /// No description provided for @recipeInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get recipeInactive;

  /// No description provided for @recipeDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Recipe'**
  String get recipeDetailTitle;

  /// No description provided for @recipeMakeActiveTooltip.
  ///
  /// In en, this message translates to:
  /// **'Make active'**
  String get recipeMakeActiveTooltip;

  /// No description provided for @recipeNotFound.
  ///
  /// In en, this message translates to:
  /// **'Recipe not found.'**
  String get recipeNotFound;

  /// No description provided for @recipeActiveLabel.
  ///
  /// In en, this message translates to:
  /// **'Active recipe'**
  String get recipeActiveLabel;

  /// No description provided for @recipeIngredientsHeading.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get recipeIngredientsHeading;

  /// No description provided for @recipeQuantityPerUnit.
  ///
  /// In en, this message translates to:
  /// **'{quantity} {unit} / unit'**
  String recipeQuantityPerUnit(String quantity, String unit);

  /// No description provided for @recipeCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'New recipe'**
  String get recipeCreateTitle;

  /// No description provided for @recipeNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Recipe name'**
  String get recipeNameLabel;

  /// No description provided for @recipeMakeActiveSwitchLabel.
  ///
  /// In en, this message translates to:
  /// **'Make this the active recipe'**
  String get recipeMakeActiveSwitchLabel;

  /// No description provided for @poStatusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get poStatusDraft;

  /// No description provided for @poStatusSent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get poStatusSent;

  /// No description provided for @poStatusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get poStatusConfirmed;

  /// No description provided for @poStatusReceived.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get poStatusReceived;

  /// No description provided for @poStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get poStatusCancelled;

  /// No description provided for @poReceiptStatusNotReceived.
  ///
  /// In en, this message translates to:
  /// **'Not received'**
  String get poReceiptStatusNotReceived;

  /// No description provided for @poReceiptStatusPartial.
  ///
  /// In en, this message translates to:
  /// **'Partially received'**
  String get poReceiptStatusPartial;

  /// No description provided for @poReceiptStatusFullyReceived.
  ///
  /// In en, this message translates to:
  /// **'Fully received'**
  String get poReceiptStatusFullyReceived;

  /// No description provided for @poPaymentStatusNotPaid.
  ///
  /// In en, this message translates to:
  /// **'Not paid'**
  String get poPaymentStatusNotPaid;

  /// No description provided for @poPaymentStatusPartial.
  ///
  /// In en, this message translates to:
  /// **'Partial'**
  String get poPaymentStatusPartial;

  /// No description provided for @poPaymentStatusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get poPaymentStatusPaid;

  /// No description provided for @poDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Purchasing Dashboard'**
  String get poDashboardTitle;

  /// No description provided for @poViewAllOrdersTooltip.
  ///
  /// In en, this message translates to:
  /// **'View All Orders'**
  String get poViewAllOrdersTooltip;

  /// No description provided for @poOutstandingPayables.
  ///
  /// In en, this message translates to:
  /// **'Outstanding Payables'**
  String get poOutstandingPayables;

  /// No description provided for @poAllPaymentsCleared.
  ///
  /// In en, this message translates to:
  /// **'All Payments Cleared'**
  String get poAllPaymentsCleared;

  /// No description provided for @poPaymentStatusBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Payment Status Breakdown'**
  String get poPaymentStatusBreakdown;

  /// No description provided for @poReceiptStatusBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Receipt Status Breakdown'**
  String get poReceiptStatusBreakdown;

  /// No description provided for @poSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search PO number'**
  String get poSearchHint;

  /// No description provided for @poClearAllFiltersTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear all filters'**
  String get poClearAllFiltersTooltip;

  /// No description provided for @poListTitle.
  ///
  /// In en, this message translates to:
  /// **'Purchase Orders'**
  String get poListTitle;

  /// No description provided for @poListEmpty.
  ///
  /// In en, this message translates to:
  /// **'No purchase orders yet. Tap + to create one.'**
  String get poListEmpty;

  /// No description provided for @poUnknownSupplier.
  ///
  /// In en, this message translates to:
  /// **'Unknown Supplier'**
  String get poUnknownSupplier;

  /// No description provided for @poLoadingSupplier.
  ///
  /// In en, this message translates to:
  /// **'Loading supplier...'**
  String get poLoadingSupplier;

  /// No description provided for @poClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get poClearAll;

  /// No description provided for @poFilterStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get poFilterStatusLabel;

  /// No description provided for @poFilterAnyStatus.
  ///
  /// In en, this message translates to:
  /// **'Any status'**
  String get poFilterAnyStatus;

  /// No description provided for @poFilterDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get poFilterDateLabel;

  /// No description provided for @poFilterPaymentLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get poFilterPaymentLabel;

  /// No description provided for @poFilterAnyPayment.
  ///
  /// In en, this message translates to:
  /// **'Any payment'**
  String get poFilterAnyPayment;

  /// No description provided for @poFilterReceiptLabel.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get poFilterReceiptLabel;

  /// No description provided for @poFilterAnyReceipt.
  ///
  /// In en, this message translates to:
  /// **'Any receipt'**
  String get poFilterAnyReceipt;

  /// No description provided for @poDateToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get poDateToday;

  /// No description provided for @poDateWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get poDateWeek;

  /// No description provided for @poDateMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get poDateMonth;

  /// No description provided for @poDateAllDates.
  ///
  /// In en, this message translates to:
  /// **'All dates'**
  String get poDateAllDates;

  /// No description provided for @poDateAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get poDateAll;

  /// No description provided for @poSelectSupplierTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Supplier'**
  String get poSelectSupplierTitle;

  /// No description provided for @poSelectProductTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Product'**
  String get poSelectProductTitle;

  /// No description provided for @poPriceEach.
  ///
  /// In en, this message translates to:
  /// **'{price} each'**
  String poPriceEach(String price);

  /// No description provided for @poPickSupplierError.
  ///
  /// In en, this message translates to:
  /// **'Pick a supplier.'**
  String get poPickSupplierError;

  /// No description provided for @poCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'New Purchase Order'**
  String get poCreateTitle;

  /// No description provided for @poSupplierLabel.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get poSupplierLabel;

  /// No description provided for @poSelectSupplierPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Select supplier...'**
  String get poSelectSupplierPlaceholder;

  /// No description provided for @poOrderItemsHeading.
  ///
  /// In en, this message translates to:
  /// **'Order Items'**
  String get poOrderItemsHeading;

  /// No description provided for @poNoProductsAdded.
  ///
  /// In en, this message translates to:
  /// **'No products added yet.'**
  String get poNoProductsAdded;

  /// No description provided for @poQtyLabel.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get poQtyLabel;

  /// No description provided for @poAddProductButton.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get poAddProductButton;

  /// No description provided for @poEstimatedTotal.
  ///
  /// In en, this message translates to:
  /// **'Estimated Total'**
  String get poEstimatedTotal;

  /// No description provided for @poCreateDraftButton.
  ///
  /// In en, this message translates to:
  /// **'Create draft'**
  String get poCreateDraftButton;

  /// No description provided for @poDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Purchase Order'**
  String get poDetailTitle;

  /// No description provided for @poNotFound.
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get poNotFound;

  /// No description provided for @poLinesHeading.
  ///
  /// In en, this message translates to:
  /// **'Lines'**
  String get poLinesHeading;

  /// No description provided for @poLineQtyOrderedReceived.
  ///
  /// In en, this message translates to:
  /// **'Qty ordered: {ordered} · received: {received}'**
  String poLineQtyOrderedReceived(String ordered, String received);

  /// No description provided for @poReceiptsHeading.
  ///
  /// In en, this message translates to:
  /// **'Receipts'**
  String get poReceiptsHeading;

  /// No description provided for @poNoReceiptsYet.
  ///
  /// In en, this message translates to:
  /// **'No receipts recorded yet.'**
  String get poNoReceiptsYet;

  /// No description provided for @poPostButton.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get poPostButton;

  /// No description provided for @poPaymentsHeading.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get poPaymentsHeading;

  /// No description provided for @poNoPaymentsYet.
  ///
  /// In en, this message translates to:
  /// **'No payments recorded yet.'**
  String get poNoPaymentsYet;

  /// No description provided for @poSendButton.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get poSendButton;

  /// No description provided for @poConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get poConfirmButton;

  /// No description provided for @poReceiveGoodsButton.
  ///
  /// In en, this message translates to:
  /// **'Receive goods'**
  String get poReceiveGoodsButton;

  /// No description provided for @poAddPaymentButton.
  ///
  /// In en, this message translates to:
  /// **'Add payment'**
  String get poAddPaymentButton;

  /// No description provided for @poCancelOrderButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel order'**
  String get poCancelOrderButton;

  /// No description provided for @poCancelOrderConfirm.
  ///
  /// In en, this message translates to:
  /// **'Cancel {orderNumber}?'**
  String poCancelOrderConfirm(String orderNumber);

  /// No description provided for @poReceiveGoodsTitle.
  ///
  /// In en, this message translates to:
  /// **'Receive Goods (draft)'**
  String get poReceiveGoodsTitle;

  /// No description provided for @poReceivingForOrder.
  ///
  /// In en, this message translates to:
  /// **'Receiving for order:'**
  String get poReceivingForOrder;

  /// No description provided for @poSelectQuantitiesHeading.
  ///
  /// In en, this message translates to:
  /// **'Select quantities to receive'**
  String get poSelectQuantitiesHeading;

  /// No description provided for @poRemainingQty.
  ///
  /// In en, this message translates to:
  /// **'Remaining: {qty}'**
  String poRemainingQty(String qty);

  /// No description provided for @poReceiveLabel.
  ///
  /// In en, this message translates to:
  /// **'Receive'**
  String get poReceiveLabel;

  /// No description provided for @poSaveDraftReceiptButton.
  ///
  /// In en, this message translates to:
  /// **'Save draft receipt'**
  String get poSaveDraftReceiptButton;

  /// No description provided for @poRecordPaymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Record Payment (draft)'**
  String get poRecordPaymentTitle;

  /// No description provided for @poRecordingPaymentFor.
  ///
  /// In en, this message translates to:
  /// **'Recording payment for:'**
  String get poRecordingPaymentFor;

  /// No description provided for @poOrderTotalLine.
  ///
  /// In en, this message translates to:
  /// **'{orderNumber} · Order Total: {total}'**
  String poOrderTotalLine(String orderNumber, String total);

  /// No description provided for @poPaymentInfoHeading.
  ///
  /// In en, this message translates to:
  /// **'Payment Information'**
  String get poPaymentInfoHeading;

  /// No description provided for @poAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get poAmountLabel;

  /// No description provided for @poMethodLabel.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get poMethodLabel;

  /// No description provided for @poInvalidAmountError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount.'**
  String get poInvalidAmountError;

  /// No description provided for @poSaveDraftPaymentButton.
  ///
  /// In en, this message translates to:
  /// **'Save draft payment'**
  String get poSaveDraftPaymentButton;

  /// No description provided for @poStatsDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily Statistics'**
  String get poStatsDaily;

  /// No description provided for @poStatsWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly Statistics'**
  String get poStatsWeekly;

  /// No description provided for @poStatsMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly Statistics'**
  String get poStatsMonthly;

  /// No description provided for @poStatsYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly Statistics'**
  String get poStatsYearly;

  /// No description provided for @poStatsDefault.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get poStatsDefault;

  /// No description provided for @poStatTotalOrders.
  ///
  /// In en, this message translates to:
  /// **'Total Orders'**
  String get poStatTotalOrders;

  /// No description provided for @poStatTotalPurchases.
  ///
  /// In en, this message translates to:
  /// **'Total Purchases'**
  String get poStatTotalPurchases;

  /// No description provided for @soStatusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get soStatusDraft;

  /// No description provided for @soStatusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get soStatusConfirmed;

  /// No description provided for @soStatusProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get soStatusProcessing;

  /// No description provided for @soStatusShipped.
  ///
  /// In en, this message translates to:
  /// **'Shipped'**
  String get soStatusShipped;

  /// No description provided for @soStatusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get soStatusDelivered;

  /// No description provided for @soStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get soStatusCancelled;

  /// No description provided for @soPaymentStatusNotPaid.
  ///
  /// In en, this message translates to:
  /// **'Not paid'**
  String get soPaymentStatusNotPaid;

  /// No description provided for @soPaymentStatusPartial.
  ///
  /// In en, this message translates to:
  /// **'Partial'**
  String get soPaymentStatusPartial;

  /// No description provided for @soPaymentStatusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get soPaymentStatusPaid;

  /// No description provided for @soShippingStatusNotShipped.
  ///
  /// In en, this message translates to:
  /// **'Not shipped'**
  String get soShippingStatusNotShipped;

  /// No description provided for @soShippingStatusPartiallyShipped.
  ///
  /// In en, this message translates to:
  /// **'Partially shipped'**
  String get soShippingStatusPartiallyShipped;

  /// No description provided for @soShippingStatusFullyShipped.
  ///
  /// In en, this message translates to:
  /// **'Fully shipped'**
  String get soShippingStatusFullyShipped;

  /// No description provided for @soDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Sales Dashboard'**
  String get soDashboardTitle;

  /// No description provided for @soViewAllOrdersTooltip.
  ///
  /// In en, this message translates to:
  /// **'View All Orders'**
  String get soViewAllOrdersTooltip;

  /// No description provided for @soOutstandingReceivables.
  ///
  /// In en, this message translates to:
  /// **'Outstanding Receivables'**
  String get soOutstandingReceivables;

  /// No description provided for @soAllPaymentsCleared.
  ///
  /// In en, this message translates to:
  /// **'All Payments Cleared'**
  String get soAllPaymentsCleared;

  /// No description provided for @soPaymentStatusBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Payment Status Breakdown'**
  String get soPaymentStatusBreakdown;

  /// No description provided for @soShippingStatusBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Shipping Status Breakdown'**
  String get soShippingStatusBreakdown;

  /// No description provided for @soSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search SO number'**
  String get soSearchHint;

  /// No description provided for @soClearAllFiltersTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear all filters'**
  String get soClearAllFiltersTooltip;

  /// No description provided for @soListTitle.
  ///
  /// In en, this message translates to:
  /// **'Sale Orders'**
  String get soListTitle;

  /// No description provided for @soListEmpty.
  ///
  /// In en, this message translates to:
  /// **'No sale orders yet. Tap + to create one.'**
  String get soListEmpty;

  /// No description provided for @soUnknownCustomer.
  ///
  /// In en, this message translates to:
  /// **'Unknown Customer'**
  String get soUnknownCustomer;

  /// No description provided for @soLoadingCustomer.
  ///
  /// In en, this message translates to:
  /// **'Loading customer...'**
  String get soLoadingCustomer;

  /// No description provided for @soClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get soClearAll;

  /// No description provided for @soFilterStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get soFilterStatusLabel;

  /// No description provided for @soFilterAnyStatus.
  ///
  /// In en, this message translates to:
  /// **'Any status'**
  String get soFilterAnyStatus;

  /// No description provided for @soFilterDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get soFilterDateLabel;

  /// No description provided for @soFilterPaymentLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get soFilterPaymentLabel;

  /// No description provided for @soFilterAnyPayment.
  ///
  /// In en, this message translates to:
  /// **'Any payment'**
  String get soFilterAnyPayment;

  /// No description provided for @soFilterShippingLabel.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get soFilterShippingLabel;

  /// No description provided for @soFilterAnyShipping.
  ///
  /// In en, this message translates to:
  /// **'Any shipping'**
  String get soFilterAnyShipping;

  /// No description provided for @soDateToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get soDateToday;

  /// No description provided for @soDateWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get soDateWeek;

  /// No description provided for @soDateMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get soDateMonth;

  /// No description provided for @soDateAllDates.
  ///
  /// In en, this message translates to:
  /// **'All dates'**
  String get soDateAllDates;

  /// No description provided for @soDateAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get soDateAll;

  /// No description provided for @soSelectCustomerTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Customer'**
  String get soSelectCustomerTitle;

  /// No description provided for @soPickCustomerError.
  ///
  /// In en, this message translates to:
  /// **'Pick a customer.'**
  String get soPickCustomerError;

  /// No description provided for @soCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'New Sale Order'**
  String get soCreateTitle;

  /// No description provided for @soCustomerLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get soCustomerLabel;

  /// No description provided for @soSelectCustomerPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Select customer...'**
  String get soSelectCustomerPlaceholder;

  /// No description provided for @soDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get soDetailTitle;

  /// No description provided for @soOrderNotFound.
  ///
  /// In en, this message translates to:
  /// **'Order not found'**
  String get soOrderNotFound;

  /// No description provided for @soLineItemsHeading.
  ///
  /// In en, this message translates to:
  /// **'Line Items'**
  String get soLineItemsHeading;

  /// No description provided for @soLineQtyOrderedShipped.
  ///
  /// In en, this message translates to:
  /// **'Qty ordered: {ordered} · shipped: {shipped}'**
  String soLineQtyOrderedShipped(String ordered, String shipped);

  /// No description provided for @soShipmentsHeading.
  ///
  /// In en, this message translates to:
  /// **'Shipments'**
  String get soShipmentsHeading;

  /// No description provided for @soNoShipmentsYet.
  ///
  /// In en, this message translates to:
  /// **'No shipments recorded yet.'**
  String get soNoShipmentsYet;

  /// No description provided for @soConfirmOrderButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm Order'**
  String get soConfirmOrderButton;

  /// No description provided for @soStartProcessingButton.
  ///
  /// In en, this message translates to:
  /// **'Start Processing'**
  String get soStartProcessingButton;

  /// No description provided for @soAddPaymentButton.
  ///
  /// In en, this message translates to:
  /// **'Add Payment'**
  String get soAddPaymentButton;

  /// No description provided for @soShipItemsButton.
  ///
  /// In en, this message translates to:
  /// **'Ship Items'**
  String get soShipItemsButton;

  /// No description provided for @soCreateShipmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Shipment'**
  String get soCreateShipmentTitle;

  /// No description provided for @soCancelOrderLabel.
  ///
  /// In en, this message translates to:
  /// **'Cancel Order'**
  String get soCancelOrderLabel;

  /// No description provided for @soShippingForOrder.
  ///
  /// In en, this message translates to:
  /// **'Shipping for order:'**
  String get soShippingForOrder;

  /// No description provided for @soSelectQtyToShipHeading.
  ///
  /// In en, this message translates to:
  /// **'Select quantities to ship'**
  String get soSelectQtyToShipHeading;

  /// No description provided for @soShipQtyLabel.
  ///
  /// In en, this message translates to:
  /// **'Ship Qty'**
  String get soShipQtyLabel;

  /// No description provided for @soShipButton.
  ///
  /// In en, this message translates to:
  /// **'Ship'**
  String get soShipButton;

  /// No description provided for @soRecordPaymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Record Payment'**
  String get soRecordPaymentTitle;

  /// No description provided for @soAmountPaidLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount Paid'**
  String get soAmountPaidLabel;

  /// No description provided for @soPaymentMethodLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get soPaymentMethodLabel;

  /// No description provided for @soSavePaymentButton.
  ///
  /// In en, this message translates to:
  /// **'Save Payment'**
  String get soSavePaymentButton;

  /// No description provided for @salesDashboardQuickActionsHeading.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get salesDashboardQuickActionsHeading;

  /// No description provided for @salesDashboardCustomersAction.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get salesDashboardCustomersAction;

  /// No description provided for @salesDashboardOrdersAction.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get salesDashboardOrdersAction;

  /// No description provided for @purchasingDashboardQuickActionsHeading.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get purchasingDashboardQuickActionsHeading;

  /// No description provided for @purchasingDashboardSuppliersAction.
  ///
  /// In en, this message translates to:
  /// **'Suppliers'**
  String get purchasingDashboardSuppliersAction;

  /// No description provided for @purchasingDashboardOrdersAction.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get purchasingDashboardOrdersAction;

  /// No description provided for @soStatTotalSales.
  ///
  /// In en, this message translates to:
  /// **'Total Sales'**
  String get soStatTotalSales;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
