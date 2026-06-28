import 'package:freezed_annotation/freezed_annotation.dart';
part 'stock_movement.freezed.dart';

enum MovementType {
  inbound('in'),
  outbound('out'),
  adjustment('adjustment');

  const MovementType(this.wire);
  final String wire;

  static MovementType fromWire(String wire) =>
      MovementType.values.firstWhere((t) => t.wire == wire,
          orElse: () => MovementType.adjustment);
}

@freezed
abstract class StockMovement with _$StockMovement {
  const factory StockMovement({
    required String id,
    required String organizationId,
    required String productId,
    required MovementType type,
    required double quantity, // signed
    String? notes,
    // Source document this movement came from, e.g.
    // 'purchase_order_receipt' / 'sale_order_shipping' / 'production_order'.
    String? referenceType,
    String? referenceId,
    required String createdBy,
    required DateTime createdAt,
  }) = _StockMovement;
}
