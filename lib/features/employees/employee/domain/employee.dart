import 'package:freezed_annotation/freezed_annotation.dart';
part 'employee.freezed.dart';

@freezed
abstract class Employee with _$Employee {
  const Employee._();
  const factory Employee({
    required String id,
    required String organizationId,
    required String name,
    String? phone,
    String? notes,
    required bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Employee;
}
