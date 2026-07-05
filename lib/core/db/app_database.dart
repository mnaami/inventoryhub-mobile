import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'core_tables.dart';
import '../../features/inventory/category/data/category_table.dart';
import '../../features/inventory/category/data/category_dao.dart';
import '../../features/inventory/unit/data/unit_table.dart';
import '../../features/inventory/unit/data/unit_dao.dart';
import '../../features/inventory/product/data/product_table.dart';
import '../../features/inventory/product/data/product_dao.dart';
import '../../features/inventory/stock_movement/data/stock_movement_table.dart';
import '../../features/inventory/stock_movement/data/stock_movement_dao.dart';
import '../../features/sales/customer/data/customer_table.dart';
import '../../features/sales/customer/data/customer_dao.dart';
import '../../features/sales/sale_order/data/document_counter_table.dart';
import '../../features/sales/sale_order/data/document_counter_dao.dart';
import '../../features/sales/sale_order/data/sale_order_tables.dart';
import '../../features/sales/sale_order/data/sale_order_dao.dart';
import '../../features/sales/sale_order/data/sale_order_payment_dao.dart';
import '../../features/sales/sale_order/data/sale_order_shipping_dao.dart';
import '../../features/purchasing/supplier/data/supplier_table.dart';
import '../../features/purchasing/supplier/data/supplier_dao.dart';
import '../../features/purchasing/purchase_order/data/purchase_order_tables.dart';
import '../../features/purchasing/purchase_order/data/purchase_order_dao.dart';
import '../../features/purchasing/purchase_order/data/purchase_order_payment_dao.dart';
import '../../features/purchasing/purchase_order/data/purchase_order_receipt_dao.dart';
import '../../features/production/recipe/data/production_recipe_tables.dart';
import '../../features/production/recipe/data/production_recipe_dao.dart';
import '../../features/production/production_order/data/production_order_tables.dart';
import '../../features/production/production_order/data/production_order_dao.dart';
import '../../features/employees/employee/data/employee_table.dart';
import '../../features/employees/employee/data/employee_dao.dart';
import '../../features/employees/rate/data/production_pay_rate_table.dart';
import '../../features/employees/rate/data/production_pay_rate_dao.dart';
import '../../features/employees/earning/data/production_earning_table.dart';
import '../../features/employees/payment/data/employee_payment_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Organizations, Users, Categories, Units, Products, StockMovements,
    Customers, DocumentCounters, SaleOrders, SaleOrderItems,
    SaleOrderPayments, SaleOrderShippings, SaleOrderShippingItems,
    Suppliers, PurchaseOrders, PurchaseOrderItems, PurchaseOrderReceipts,
    PurchaseOrderReceiptItems, PurchaseOrderPayments,
    ProductionRecipes, ProductionRecipeItems, ProductionOrders,
    Employees, ProductionPayRates, ProductionEarnings, EmployeePayments,
  ],
  daos: [CategoryDao, UnitDao, ProductDao, StockMovementDao, DocumentCounterDao, CustomerDao, SaleOrderDao, SaleOrderPaymentDao, SaleOrderShippingDao, SupplierDao, PurchaseOrderDao, PurchaseOrderPaymentDao, PurchaseOrderReceiptDao, ProductionRecipeDao, ProductionOrderDao, EmployeeDao, ProductionPayRateDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// In-memory database for tests.
  AppDatabase.forTesting() : super(NativeDatabase.memory());

  /// On-device database for the running app.
  factory AppDatabase.open() =>
      AppDatabase(driftDatabase(name: 'inventoryhub'));

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(customers);
            await m.createTable(documentCounters);
            await m.createTable(saleOrders);
            await m.createTable(saleOrderItems);
            await m.createTable(saleOrderPayments);
            await m.createTable(saleOrderShippings);
            await m.createTable(saleOrderShippingItems);
          }
          if (from < 3) {
            await m.createTable(suppliers);
            await m.createTable(purchaseOrders);
            await m.createTable(purchaseOrderItems);
            await m.createTable(purchaseOrderReceipts);
            await m.createTable(purchaseOrderReceiptItems);
            await m.createTable(purchaseOrderPayments);
          }
          if (from < 4) {
            await m.createTable(productionRecipes);
            await m.createTable(productionRecipeItems);
            await m.createTable(productionOrders);
          }
          if (from < 5) {
            // `products` has carried is_sample since slice 1, and the
            // createTable steps above build tables from current definitions
            // (which already include is_sample). Add the column only where it
            // is genuinely missing so the upgrade is safe from any prior
            // version. See migration_v4_to_v5_test.
            await _addColumnIfAbsent(m, products, products.isSample);
            await _addColumnIfAbsent(m, categories, categories.isSample);
            await _addColumnIfAbsent(m, units, units.isSample);
            await _addColumnIfAbsent(m, customers, customers.isSample);
            await _addColumnIfAbsent(m, suppliers, suppliers.isSample);
            await _addColumnIfAbsent(m, stockMovements, stockMovements.isSample);
            await _addColumnIfAbsent(m, saleOrders, saleOrders.isSample);
            await _addColumnIfAbsent(m, saleOrderItems, saleOrderItems.isSample);
            await _addColumnIfAbsent(
                m, saleOrderPayments, saleOrderPayments.isSample);
            await _addColumnIfAbsent(
                m, saleOrderShippings, saleOrderShippings.isSample);
            await _addColumnIfAbsent(
                m, saleOrderShippingItems, saleOrderShippingItems.isSample);
            await _addColumnIfAbsent(m, purchaseOrders, purchaseOrders.isSample);
            await _addColumnIfAbsent(
                m, purchaseOrderItems, purchaseOrderItems.isSample);
            await _addColumnIfAbsent(
                m, purchaseOrderReceipts, purchaseOrderReceipts.isSample);
            await _addColumnIfAbsent(m, purchaseOrderReceiptItems,
                purchaseOrderReceiptItems.isSample);
            await _addColumnIfAbsent(
                m, purchaseOrderPayments, purchaseOrderPayments.isSample);
          }
          if (from < 6) {
            await m.createTable(employees);
            await m.createTable(productionPayRates);
            await m.createTable(productionEarnings);
            await m.createTable(employeePayments);
            await _addColumnIfAbsent(
                m, productionOrders, productionOrders.employeeId);
          }
        },
      );

  /// Adds [column] to [table] only if it is not already present, making the
  /// migration idempotent and safe regardless of the device's prior schema
  /// version (some tables are created above from definitions that already
  /// carry the column).
  Future<void> _addColumnIfAbsent(
      Migrator m, TableInfo table, GeneratedColumn column) async {
    final info =
        await customSelect('PRAGMA table_info(${table.actualTableName})').get();
    final present =
        info.any((row) => row.read<String>('name') == column.name);
    if (!present) {
      await m.addColumn(table, column);
    }
  }
}
