import 'package:drift/drift.dart';
import '../../../../core/db/app_database.dart';
import '../domain/category.dart';

Category toCategory(CategoryRow r) => Category(
      id: r.id,
      organizationId: r.organizationId,
      name: r.name,
      parentCategoryId: r.parentCategoryId,
      color: r.color,
      icon: r.icon,
      isActive: r.isActive,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
    );

CategoriesCompanion toCompanion(Category c) => CategoriesCompanion(
      id: Value(c.id),
      organizationId: Value(c.organizationId),
      name: Value(c.name),
      parentCategoryId: Value(c.parentCategoryId),
      color: Value(c.color),
      icon: Value(c.icon),
      isActive: Value(c.isActive),
      createdAt: Value(c.createdAt),
      updatedAt: Value(c.updatedAt),
    );
