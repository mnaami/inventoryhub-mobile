import 'package:freezed_annotation/freezed_annotation.dart';
part 'employee_payment.freezed.dart';

@freezed
abstract class EmployeePayment with _$EmployeePayment {
  const EmployeePayment._();
  const factory EmployeePayment({
    required String id,
    required String organizationId,
    required String employeeId,
    required String paymentNumber,
    required double amount,
    required DateTime paymentDate,
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _EmployeePayment;
}
