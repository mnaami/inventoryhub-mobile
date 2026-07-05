import 'package:freezed_annotation/freezed_annotation.dart';
import 'production_order_enums.dart';
part 'production_order.freezed.dart';

@freezed
abstract class ProductionOrder with _$ProductionOrder {
  const ProductionOrder._();
  const factory ProductionOrder({
    required String id,
    required String organizationId,
    required String orderNumber,
    required String productId,
    String? employeeId,
    required double quantity,
    required ProductionOrderStatus status,
    DateTime? startDate,
    DateTime? completionDate,
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _ProductionOrder;

  bool get canComplete =>
      status == ProductionOrderStatus.planned ||
      status == ProductionOrderStatus.inProgress;
  bool get canStart => status == ProductionOrderStatus.planned;
  bool get isTerminal =>
      status == ProductionOrderStatus.completed ||
      status == ProductionOrderStatus.cancelled;
}
