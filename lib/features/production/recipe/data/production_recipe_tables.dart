import 'package:drift/drift.dart';

@DataClassName('ProductionRecipeRow')
class ProductionRecipes extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text().named('organization_id')();
  TextColumn get productId => text().named('product_id')(); // output product
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  BoolColumn get isActive =>
      boolean().named('is_active').withDefault(const Constant(false))();
  BoolColumn get isDeleted =>
      boolean().named('is_deleted').withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ProductionRecipeItemRow')
class ProductionRecipeItems extends Table {
  TextColumn get id => text()();
  TextColumn get recipeId => text().named('recipe_id')();
  TextColumn get ingredientProductId => text().named('ingredient_product_id')();
  RealColumn get quantityPerUnit => real().named('quantity_per_unit')();
  TextColumn get unit => text()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column> get primaryKey => {id};
}
