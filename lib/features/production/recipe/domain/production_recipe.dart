import 'package:freezed_annotation/freezed_annotation.dart';
part 'production_recipe.freezed.dart';

@freezed
abstract class ProductionRecipe with _$ProductionRecipe {
  const factory ProductionRecipe({
    required String id,
    required String organizationId,
    required String productId,
    required String name,
    String? description,
    required bool isActive,
    required bool isDeleted,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _ProductionRecipe;
}

@freezed
abstract class ProductionRecipeItem with _$ProductionRecipeItem {
  const factory ProductionRecipeItem({
    required String id,
    required String recipeId,
    required String ingredientProductId,
    required double quantityPerUnit,
    required String unit,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _ProductionRecipeItem;
}
