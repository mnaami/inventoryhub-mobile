import 'package:freezed_annotation/freezed_annotation.dart';
part 'production_pay_rate.freezed.dart';

@freezed
abstract class ProductionPayRate with _$ProductionPayRate {
  const ProductionPayRate._();
  const factory ProductionPayRate({
    required String id,
    required String organizationId,
    required String productId,
    String? employeeId,
    required double rate,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _ProductionPayRate;
}
