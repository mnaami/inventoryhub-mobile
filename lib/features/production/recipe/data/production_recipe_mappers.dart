import 'package:drift/drift.dart';
import '../../../../core/db/app_database.dart';
import '../domain/production_recipe.dart';

ProductionRecipe toProductionRecipe(ProductionRecipeRow r) => ProductionRecipe(
      id: r.id,
      organizationId: r.organizationId,
      productId: r.productId,
      name: r.name,
      description: r.description,
      isActive: r.isActive,
      isDeleted: r.isDeleted,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
    );

ProductionRecipesCompanion recipeInsert(ProductionRecipe r) =>
    ProductionRecipesCompanion.insert(
      id: r.id,
      organizationId: r.organizationId,
      productId: r.productId,
      name: r.name,
      description: Value(r.description),
      isActive: Value(r.isActive),
      isDeleted: Value(r.isDeleted),
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
    );

ProductionRecipesCompanion recipeUpdate(ProductionRecipe r) =>
    ProductionRecipesCompanion(
      id: Value(r.id),
      organizationId: Value(r.organizationId),
      productId: Value(r.productId),
      name: Value(r.name),
      description: Value(r.description),
      isActive: Value(r.isActive),
      isDeleted: Value(r.isDeleted),
      updatedAt: Value(r.updatedAt),
    );

ProductionRecipeItem toProductionRecipeItem(ProductionRecipeItemRow r) =>
    ProductionRecipeItem(
      id: r.id,
      recipeId: r.recipeId,
      ingredientProductId: r.ingredientProductId,
      quantityPerUnit: r.quantityPerUnit,
      unit: r.unit,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
    );

ProductionRecipeItemsCompanion recipeItemInsert(ProductionRecipeItem i) =>
    ProductionRecipeItemsCompanion.insert(
      id: i.id,
      recipeId: i.recipeId,
      ingredientProductId: i.ingredientProductId,
      quantityPerUnit: i.quantityPerUnit,
      unit: i.unit,
      createdAt: i.createdAt,
      updatedAt: i.updatedAt,
    );
