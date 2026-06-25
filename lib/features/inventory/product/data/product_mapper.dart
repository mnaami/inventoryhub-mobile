import 'package:drift/drift.dart';
import '../../../../core/db/app_database.dart';
import '../domain/product.dart';

Product toProduct(ProductRow r) => Product(
      id: r.id,
      organizationId: r.organizationId,
      name: r.name,
      description: r.description,
      categoryId: r.categoryId,
      unitId: r.unitId,
      purchasePrice: r.purchasePrice,
      sellingPrice: r.sellingPrice,
      currentStock: r.currentStock,
      minimumStock: r.minimumStock,
      barcode: r.barcode,
      imagePath: r.imagePath,
      supplierId: r.supplierId,
      isActive: r.isActive,
      isSample: r.isSample,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
    );

ProductsCompanion toInsertCompanion(Product p) => ProductsCompanion.insert(
      id: p.id,
      organizationId: p.organizationId,
      name: p.name,
      unitId: p.unitId,
      description: Value(p.description),
      categoryId: Value(p.categoryId),
      purchasePrice: Value(p.purchasePrice),
      sellingPrice: Value(p.sellingPrice),
      currentStock: Value(p.currentStock),
      minimumStock: Value(p.minimumStock),
      barcode: Value(p.barcode),
      imagePath: Value(p.imagePath),
      supplierId: Value(p.supplierId),
      isActive: Value(p.isActive),
      isSample: Value(p.isSample),
      createdAt: p.createdAt,
      updatedAt: p.updatedAt,
    );

/// Update companion that deliberately OMITS currentStock so updates can never
/// alter the ledger-maintained running total.
ProductsCompanion toUpdateCompanion(Product p) => ProductsCompanion(
      id: Value(p.id),
      organizationId: Value(p.organizationId),
      name: Value(p.name),
      description: Value(p.description),
      categoryId: Value(p.categoryId),
      unitId: Value(p.unitId),
      purchasePrice: Value(p.purchasePrice),
      sellingPrice: Value(p.sellingPrice),
      minimumStock: Value(p.minimumStock),
      barcode: Value(p.barcode),
      imagePath: Value(p.imagePath),
      supplierId: Value(p.supplierId),
      isActive: Value(p.isActive),
      isSample: Value(p.isSample),
      updatedAt: Value(p.updatedAt),
    );
