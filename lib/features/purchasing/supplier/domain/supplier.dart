import 'package:freezed_annotation/freezed_annotation.dart';
part 'supplier.freezed.dart';

@freezed
abstract class Supplier with _$Supplier {
  const factory Supplier({
    required String id,
    required String organizationId,
    required String name,
    String? contactPerson,
    String? email,
    @Default(<String>[]) List<String> phones,
    String? address,
    @Default(30) int paymentTerms,
    double? creditLimit,
    required bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Supplier;
}
