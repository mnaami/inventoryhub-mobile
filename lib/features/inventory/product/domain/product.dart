import 'package:freezed_annotation/freezed_annotation.dart';
part 'product.freezed.dart';

@freezed
abstract class Product with _$Product {
  const Product._();
  const factory Product({
    required String id,
    required String organizationId,
    required String name,
    String? description,
    String? categoryId,
    required String unitId,
    required double purchasePrice,
    required double sellingPrice,
    required double currentStock,
    required double minimumStock,
    String? barcode,
    String? imagePath,
    String? supplierId,
    required bool isActive,
    required bool isSample,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Product;

  bool get isLowStock => minimumStock > 0 && currentStock <= minimumStock;
  bool get isOutOfStock => currentStock <= 0;
}
