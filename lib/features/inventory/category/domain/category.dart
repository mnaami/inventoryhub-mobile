import 'package:freezed_annotation/freezed_annotation.dart';
part 'category.freezed.dart';

@freezed
abstract class Category with _$Category {
  const factory Category({
    required String id,
    required String organizationId,
    required String name,
    String? parentCategoryId,
    String? color,
    String? icon,
    required bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Category;
}

@freezed
abstract class CategoryNode with _$CategoryNode {
  const factory CategoryNode({
    required Category category,
    required List<CategoryNode> children,
  }) = _CategoryNode;
}
