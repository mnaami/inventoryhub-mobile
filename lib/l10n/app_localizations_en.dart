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
  String get sectionCurrency => 'Currency';

  @override
  String get sectionCatalog => 'Catalog';

  @override
  String get sectionAbout => 'About';

  @override
  String get sectionAccount => 'Account';

  @override
  String get currencyUsd => 'US Dollar (\$)';

  @override
  String get currencyDzd => 'Algerian Dinar (دج)';

  @override
  String get currencySelectTitle => 'Choose your currency';

  @override
  String get currencySelectSubtitle =>
      'All prices and totals will be shown in this currency. You can change it later in Settings.';

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
  String get navDashboard => 'Dashboard';

  @override
  String get homeDashboardTitle => 'Dashboard';

  @override
  String get homeSalesToday => 'Today\'s Sales';

  @override
  String get homeSalesThisWeek => 'This Week\'s Sales';

  @override
  String get homeSalesThisMonth => 'This Month\'s Sales';

  @override
  String get homeStatOrders => 'Orders';

  @override
  String get homeStatRevenue => 'Revenue';

  @override
  String get homeSalesTrendToday => 'Sales Trend — Today';

  @override
  String get homeSalesTrend7d => 'Sales Trend — 7 Days';

  @override
  String get homeSalesTrend30d => 'Sales Trend — 30 Days';

  @override
  String get homeSalesTrendEmpty => 'No sales in this period yet';

  @override
  String get homeMoneyHeading => 'Money In & Out';

  @override
  String get homeReceivables => 'Customers Owe You';

  @override
  String get homePayables => 'You Owe Suppliers';

  @override
  String get homeStockHeading => 'Stock Snapshot';

  @override
  String get homeStockValue => 'Total Stock Value';

  @override
  String get homeLowStock => 'Low Stock Items';

  @override
  String get homeOutOfStock => 'Out of Stock Items';

  @override
  String get homeOpenWorkHeading => 'Open Work';

  @override
  String get homeOpenSaleOrders => 'Open Sale Orders';

  @override
  String get homeUnshipped => 'Awaiting Shipment';

  @override
  String get homeOpenPurchaseOrders => 'Open Purchase Orders';

  @override
  String get homeUnreceived => 'Awaiting Receipt';

  @override
  String get homeInProduction => 'In Production';

  @override
  String homeErrorLoading(String error) {
    return 'Error loading dashboard: $error';
  }

  @override
  String get homeRetry => 'Retry';

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

  @override
  String get productionHomeTitle => 'Production';

  @override
  String get productionStatusPlanned => 'Planned';

  @override
  String get productionStatusInProgress => 'In progress';

  @override
  String get productionStatusCompleted => 'Completed';

  @override
  String get productionStatusCancelled => 'Cancelled';

  @override
  String get productionOrdersButton => 'Production orders';

  @override
  String get recipesButton => 'Recipes';

  @override
  String get productionOrderCreateTitle => 'New production order';

  @override
  String get productionOutputProductLabel => 'Output product';

  @override
  String get productionQuantityLabel => 'Quantity';

  @override
  String get productionCreateButton => 'Create';

  @override
  String get productionChooseOutputProductError => 'Choose an output product.';

  @override
  String get productionEnterValidQuantityError => 'Enter a valid quantity.';

  @override
  String get productionActionDone => 'Done.';

  @override
  String get productionOrderDetailTitle => 'Production order';

  @override
  String get productionOrderNotFound => 'Order not found.';

  @override
  String productionOutputProductValue(String productId) {
    return 'Output product: $productId';
  }

  @override
  String productionQuantityValue(String quantity) {
    return 'Quantity: $quantity';
  }

  @override
  String productionStatusValue(String status) {
    return 'Status: $status';
  }

  @override
  String productionStartedValue(String date) {
    return 'Started: $date';
  }

  @override
  String productionCompletedValue(String date) {
    return 'Completed: $date';
  }

  @override
  String get productionStartButton => 'Start';

  @override
  String get productionCompleteButton => 'Complete (consume + produce)';

  @override
  String get productionCancelOrderButton => 'Cancel order';

  @override
  String get productionOrdersListTitle => 'Production orders';

  @override
  String get productionOrdersEmpty => 'No production orders yet.';

  @override
  String productionOrderListSubtitle(String quantity, String status) {
    return '$quantity units · $status';
  }

  @override
  String get recipesListTitle => 'Recipes';

  @override
  String get recipesEmpty => 'No recipes yet. Tap + to add one.';

  @override
  String get recipeActive => 'Active';

  @override
  String get recipeInactive => 'Inactive';

  @override
  String get recipeDetailTitle => 'Recipe';

  @override
  String get recipeMakeActiveTooltip => 'Make active';

  @override
  String get recipeNotFound => 'Recipe not found.';

  @override
  String get recipeActiveLabel => 'Active recipe';

  @override
  String get recipeIngredientsHeading => 'Ingredients';

  @override
  String recipeQuantityPerUnit(String quantity, String unit) {
    return '$quantity $unit / unit';
  }

  @override
  String get recipeCreateTitle => 'New recipe';

  @override
  String get recipeNameLabel => 'Recipe name';

  @override
  String get recipeMakeActiveSwitchLabel => 'Make this the active recipe';

  @override
  String get poStatusDraft => 'Draft';

  @override
  String get poStatusSent => 'Sent';

  @override
  String get poStatusConfirmed => 'Confirmed';

  @override
  String get poStatusReceived => 'Received';

  @override
  String get poStatusCancelled => 'Cancelled';

  @override
  String get poReceiptStatusNotReceived => 'Not received';

  @override
  String get poReceiptStatusPartial => 'Partially received';

  @override
  String get poReceiptStatusFullyReceived => 'Fully received';

  @override
  String get poPaymentStatusNotPaid => 'Not paid';

  @override
  String get poPaymentStatusPartial => 'Partial';

  @override
  String get poPaymentStatusPaid => 'Paid';

  @override
  String get poDashboardTitle => 'Purchasing Dashboard';

  @override
  String get poViewAllOrdersTooltip => 'View All Orders';

  @override
  String get poOutstandingPayables => 'Outstanding Payables';

  @override
  String get poAllPaymentsCleared => 'All Payments Cleared';

  @override
  String get poPaymentStatusBreakdown => 'Payment Status Breakdown';

  @override
  String get poReceiptStatusBreakdown => 'Receipt Status Breakdown';

  @override
  String get poSearchHint => 'Search PO number';

  @override
  String get poClearAllFiltersTooltip => 'Clear all filters';

  @override
  String get poListTitle => 'Purchase Orders';

  @override
  String get poListEmpty => 'No purchase orders yet. Tap + to create one.';

  @override
  String get poUnknownSupplier => 'Unknown Supplier';

  @override
  String get poLoadingSupplier => 'Loading supplier...';

  @override
  String get poClearAll => 'Clear All';

  @override
  String get poFilterStatusLabel => 'Status';

  @override
  String get poFilterAnyStatus => 'Any status';

  @override
  String get poFilterDateLabel => 'Date';

  @override
  String get poFilterPaymentLabel => 'Payment';

  @override
  String get poFilterAnyPayment => 'Any payment';

  @override
  String get poFilterReceiptLabel => 'Receipt';

  @override
  String get poFilterAnyReceipt => 'Any receipt';

  @override
  String get poDateToday => 'Today';

  @override
  String get poDateWeek => 'This week';

  @override
  String get poDateMonth => 'This month';

  @override
  String get poDateAllDates => 'All dates';

  @override
  String get poDateAll => 'All';

  @override
  String get poSelectSupplierTitle => 'Select Supplier';

  @override
  String get poSelectProductTitle => 'Select Product';

  @override
  String poPriceEach(String price) {
    return '$price each';
  }

  @override
  String get poPickSupplierError => 'Pick a supplier.';

  @override
  String get poCreateTitle => 'New Purchase Order';

  @override
  String get poSupplierLabel => 'Supplier';

  @override
  String get poSelectSupplierPlaceholder => 'Select supplier...';

  @override
  String get poOrderItemsHeading => 'Order Items';

  @override
  String get poNoProductsAdded => 'No products added yet.';

  @override
  String get poQtyLabel => 'Qty';

  @override
  String get poAddProductButton => 'Add Product';

  @override
  String get poEstimatedTotal => 'Estimated Total';

  @override
  String get poCreateDraftButton => 'Create draft';

  @override
  String get poDetailTitle => 'Purchase Order';

  @override
  String get poNotFound => 'Not found';

  @override
  String get poLinesHeading => 'Lines';

  @override
  String poLineQtyOrderedReceived(String ordered, String received) {
    return 'Qty ordered: $ordered · received: $received';
  }

  @override
  String get poReceiptsHeading => 'Receipts';

  @override
  String get poNoReceiptsYet => 'No receipts recorded yet.';

  @override
  String get poPostButton => 'Post';

  @override
  String get poPaymentsHeading => 'Payments';

  @override
  String get poNoPaymentsYet => 'No payments recorded yet.';

  @override
  String get poSendButton => 'Send';

  @override
  String get poConfirmButton => 'Confirm';

  @override
  String get poReceiveGoodsButton => 'Receive goods';

  @override
  String get poAddPaymentButton => 'Add payment';

  @override
  String get poCancelOrderButton => 'Cancel order';

  @override
  String poCancelOrderConfirm(String orderNumber) {
    return 'Cancel $orderNumber?';
  }

  @override
  String get poReceiveGoodsTitle => 'Receive Goods (draft)';

  @override
  String get poReceivingForOrder => 'Receiving for order:';

  @override
  String get poSelectQuantitiesHeading => 'Select quantities to receive';

  @override
  String poRemainingQty(String qty) {
    return 'Remaining: $qty';
  }

  @override
  String get poReceiveLabel => 'Receive';

  @override
  String get poSaveDraftReceiptButton => 'Save draft receipt';

  @override
  String get poRecordPaymentTitle => 'Record Payment (draft)';

  @override
  String get poRecordingPaymentFor => 'Recording payment for:';

  @override
  String poOrderTotalLine(String orderNumber, String total) {
    return '$orderNumber · Order Total: $total';
  }

  @override
  String get poPaymentInfoHeading => 'Payment Information';

  @override
  String get poAmountLabel => 'Amount';

  @override
  String get poMethodLabel => 'Method';

  @override
  String get poInvalidAmountError => 'Enter a valid amount.';

  @override
  String get poSaveDraftPaymentButton => 'Save draft payment';

  @override
  String get poStatsDaily => 'Daily Statistics';

  @override
  String get poStatsWeekly => 'Weekly Statistics';

  @override
  String get poStatsMonthly => 'Monthly Statistics';

  @override
  String get poStatsYearly => 'Yearly Statistics';

  @override
  String get poStatsDefault => 'Statistics';

  @override
  String get poStatTotalOrders => 'Total Orders';

  @override
  String get poStatTotalPurchases => 'Total Purchases';

  @override
  String get soStatusDraft => 'Draft';

  @override
  String get soStatusConfirmed => 'Confirmed';

  @override
  String get soStatusProcessing => 'Processing';

  @override
  String get soStatusShipped => 'Shipped';

  @override
  String get soStatusDelivered => 'Delivered';

  @override
  String get soStatusCancelled => 'Cancelled';

  @override
  String get soPaymentStatusNotPaid => 'Not paid';

  @override
  String get soPaymentStatusPartial => 'Partial';

  @override
  String get soPaymentStatusPaid => 'Paid';

  @override
  String get soShippingStatusNotShipped => 'Not shipped';

  @override
  String get soShippingStatusPartiallyShipped => 'Partially shipped';

  @override
  String get soShippingStatusFullyShipped => 'Fully shipped';

  @override
  String get soDashboardTitle => 'Sales Dashboard';

  @override
  String get soViewAllOrdersTooltip => 'View All Orders';

  @override
  String get soOutstandingReceivables => 'Outstanding Receivables';

  @override
  String get soAllPaymentsCleared => 'All Payments Cleared';

  @override
  String get soPaymentStatusBreakdown => 'Payment Status Breakdown';

  @override
  String get soShippingStatusBreakdown => 'Shipping Status Breakdown';

  @override
  String get soSearchHint => 'Search SO number';

  @override
  String get soClearAllFiltersTooltip => 'Clear all filters';

  @override
  String get soListTitle => 'Sale Orders';

  @override
  String get soListEmpty => 'No sale orders yet. Tap + to create one.';

  @override
  String get soUnknownCustomer => 'Unknown Customer';

  @override
  String get soLoadingCustomer => 'Loading customer...';

  @override
  String get soClearAll => 'Clear All';

  @override
  String get soFilterStatusLabel => 'Status';

  @override
  String get soFilterAnyStatus => 'Any status';

  @override
  String get soFilterDateLabel => 'Date';

  @override
  String get soFilterPaymentLabel => 'Payment';

  @override
  String get soFilterAnyPayment => 'Any payment';

  @override
  String get soFilterShippingLabel => 'Shipping';

  @override
  String get soFilterAnyShipping => 'Any shipping';

  @override
  String get soDateToday => 'Today';

  @override
  String get soDateWeek => 'This week';

  @override
  String get soDateMonth => 'This month';

  @override
  String get soDateAllDates => 'All dates';

  @override
  String get soDateAll => 'All';

  @override
  String get soSelectCustomerTitle => 'Select Customer';

  @override
  String get soPickCustomerError => 'Pick a customer.';

  @override
  String get soCreateTitle => 'New Sale Order';

  @override
  String get soCustomerLabel => 'Customer';

  @override
  String get soSelectCustomerPlaceholder => 'Select customer...';

  @override
  String get soDetailTitle => 'Order Details';

  @override
  String get soOrderNotFound => 'Order not found';

  @override
  String get soLineItemsHeading => 'Line Items';

  @override
  String soLineQtyOrderedShipped(String ordered, String shipped) {
    return 'Qty ordered: $ordered · shipped: $shipped';
  }

  @override
  String get soShipmentsHeading => 'Shipments';

  @override
  String get soNoShipmentsYet => 'No shipments recorded yet.';

  @override
  String get soConfirmOrderButton => 'Confirm Order';

  @override
  String get soStartProcessingButton => 'Start Processing';

  @override
  String get soAddPaymentButton => 'Add Payment';

  @override
  String get soShipItemsButton => 'Ship Items';

  @override
  String get soCreateShipmentTitle => 'Create Shipment';

  @override
  String get soCancelOrderLabel => 'Cancel Order';

  @override
  String get soShippingForOrder => 'Shipping for order:';

  @override
  String get soSelectQtyToShipHeading => 'Select quantities to ship';

  @override
  String get soShipQtyLabel => 'Ship Qty';

  @override
  String get soShipButton => 'Ship';

  @override
  String get soRecordPaymentTitle => 'Record Payment';

  @override
  String get soAmountPaidLabel => 'Amount Paid';

  @override
  String get soPaymentMethodLabel => 'Payment Method';

  @override
  String get soSavePaymentButton => 'Save Payment';

  @override
  String get salesDashboardQuickActionsHeading => 'Quick Actions';

  @override
  String get salesDashboardCustomersAction => 'Customers';

  @override
  String get salesDashboardOrdersAction => 'Orders';

  @override
  String get purchasingDashboardQuickActionsHeading => 'Quick Actions';

  @override
  String get purchasingDashboardSuppliersAction => 'Suppliers';

  @override
  String get purchasingDashboardOrdersAction => 'Orders';

  @override
  String get soStatTotalSales => 'Total Sales';
}
