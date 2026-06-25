import 'package:drift/drift.dart';
import '../../../../core/db/app_database.dart';
import '../domain/unit.dart';

Unit toUnit(UnitRow r) => Unit(
      id: r.id,
      organizationId: r.organizationId,
      name: r.name,
      symbol: r.symbol,
      unitType: r.unitType,
      isBaseUnit: r.isBaseUnit,
      baseUnitId: r.baseUnitId,
      conversionFactor: r.conversionFactor,
      isActive: r.isActive,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
    );

UnitsCompanion toCompanion(Unit u) => UnitsCompanion(
      id: Value(u.id),
      organizationId: Value(u.organizationId),
      name: Value(u.name),
      symbol: Value(u.symbol),
      unitType: Value(u.unitType),
      isBaseUnit: Value(u.isBaseUnit),
      baseUnitId: Value(u.baseUnitId),
      conversionFactor: Value(u.conversionFactor),
      isActive: Value(u.isActive),
      createdAt: Value(u.createdAt),
      updatedAt: Value(u.updatedAt),
    );
