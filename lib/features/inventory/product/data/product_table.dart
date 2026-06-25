import 'package:drift/drift.dart';

@DataClassName('ProductRow')
class Products extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text().named('organization_id')();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get categoryId => text().named('category_id').nullable()();
  TextColumn get unitId => text().named('unit_id')();
  RealColumn get purchasePrice =>
      real().named('purchase_price').withDefault(const Constant(0))();
  RealColumn get sellingPrice =>
      real().named('selling_price').withDefault(const Constant(0))();
  RealColumn get currentStock =>
      real().named('current_stock').withDefault(const Constant(0))();
  RealColumn get minimumStock =>
      real().named('minimum_stock').withDefault(const Constant(0))();
  TextColumn get barcode => text().nullable()();
  TextColumn get imagePath => text().named('image_path').nullable()();
  TextColumn get supplierId => text().named('supplier_id').nullable()();
  BoolColumn get isActive =>
      boolean().named('is_active').withDefault(const Constant(true))();
  BoolColumn get isSample =>
      boolean().named('is_sample').withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column> get primaryKey => {id};
}
