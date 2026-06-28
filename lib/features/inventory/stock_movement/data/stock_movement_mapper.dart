import 'package:drift/drift.dart';
import '../../../../core/db/app_database.dart';
import '../domain/stock_movement.dart';

StockMovement toStockMovement(StockMovementRow r) => StockMovement(
      id: r.id,
      organizationId: r.organizationId,
      productId: r.productId,
      type: MovementType.fromWire(r.movementType),
      quantity: r.quantity,
      notes: r.notes,
      referenceType: r.referenceType,
      referenceId: r.referenceId,
      createdBy: r.createdBy,
      createdAt: r.createdAt,
    );

StockMovementsCompanion toCompanion(StockMovement m) =>
    StockMovementsCompanion.insert(
      id: m.id,
      organizationId: m.organizationId,
      productId: m.productId,
      movementType: m.type.wire,
      quantity: m.quantity,
      notes: Value(m.notes),
      referenceType: Value(m.referenceType),
      referenceId: Value(m.referenceId),
      createdBy: m.createdBy,
      createdAt: m.createdAt,
    );
