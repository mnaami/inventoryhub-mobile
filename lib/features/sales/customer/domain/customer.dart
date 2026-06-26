import 'package:freezed_annotation/freezed_annotation.dart';
part 'customer.freezed.dart';

@freezed
abstract class Customer with _$Customer {
  const Customer._();
  const factory Customer({
    required String id,
    required String organizationId,
    required String name,
    String? email,
    @Default(<String>[]) List<String> phones,
    String? address,
    @Default(30) int paymentTerms,
    double? creditLimit,
    String? imagePath,
    required bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Customer;
}
