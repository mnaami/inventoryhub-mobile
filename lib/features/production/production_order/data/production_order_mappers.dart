import 'package:drift/drift.dart';
import '../../../../core/db/app_database.dart';
import '../domain/production_order.dart';
import '../domain/production_order_enums.dart';

ProductionOrder toProductionOrder(ProductionOrderRow r) => ProductionOrder(
      id: r.id,
      organizationId: r.organizationId,
      orderNumber: r.orderNumber,
      productId: r.productId,
      quantity: r.quantity,
      status: ProductionOrderStatus.fromWire(r.status),
      startDate: r.startDate,
      completionDate: r.completionDate,
      notes: r.notes,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
    );

ProductionOrdersCompanion productionOrderInsert(ProductionOrder o) =>
    ProductionOrdersCompanion.insert(
      id: o.id,
      organizationId: o.organizationId,
      orderNumber: o.orderNumber,
      productId: o.productId,
      quantity: o.quantity,
      status: Value(o.status.wire),
      startDate: Value(o.startDate),
      completionDate: Value(o.completionDate),
      notes: Value(o.notes),
      createdAt: o.createdAt,
      updatedAt: o.updatedAt,
    );
