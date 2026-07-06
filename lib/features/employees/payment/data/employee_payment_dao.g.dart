// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee_payment_dao.dart';

// ignore_for_file: type=lint
mixin _$EmployeePaymentDaoMixin on DatabaseAccessor<AppDatabase> {
  $EmployeePaymentsTable get employeePayments =>
      attachedDatabase.employeePayments;
  EmployeePaymentDaoManager get managers => EmployeePaymentDaoManager(this);
}

class EmployeePaymentDaoManager {
  final _$EmployeePaymentDaoMixin _db;
  EmployeePaymentDaoManager(this._db);
  $$EmployeePaymentsTableTableManager get employeePayments =>
      $$EmployeePaymentsTableTableManager(
        _db.attachedDatabase,
        _db.employeePayments,
      );
}
