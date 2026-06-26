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

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Organizations, Users, Categories, Units, Products, StockMovements,
    Customers, DocumentCounters, SaleOrders, SaleOrderItems,
    SaleOrderPayments, SaleOrderShippings, SaleOrderShippingItems,
  ],
  daos: [CategoryDao, UnitDao, ProductDao, StockMovementDao, DocumentCounterDao, CustomerDao, SaleOrderDao, SaleOrderPaymentDao, SaleOrderShippingDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// In-memory database for tests.
  AppDatabase.forTesting() : super(NativeDatabase.memory());

  /// On-device database for the running app.
  factory AppDatabase.open() =>
      AppDatabase(driftDatabase(name: 'inventoryhub'));

  @override
  int get schemaVersion => 2;

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
        },
      );
}
