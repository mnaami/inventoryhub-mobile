import 'package:freezed_annotation/freezed_annotation.dart';
part 'unit.freezed.dart';

@freezed
abstract class Unit with _$Unit {
  const factory Unit({
    required String id,
    required String organizationId,
    required String name,
    required String symbol,
    required String unitType,
    required bool isBaseUnit,
    String? baseUnitId,
    required double conversionFactor,
    required bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Unit;
}
