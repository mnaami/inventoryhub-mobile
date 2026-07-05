// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'employee_payment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EmployeePayment {

 String get id; String get organizationId; String get employeeId; String get paymentNumber; double get amount; DateTime get paymentDate; String? get notes; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of EmployeePayment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EmployeePaymentCopyWith<EmployeePayment> get copyWith => _$EmployeePaymentCopyWithImpl<EmployeePayment>(this as EmployeePayment, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EmployeePayment&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.employeeId, employeeId) || other.employeeId == employeeId)&&(identical(other.paymentNumber, paymentNumber) || other.paymentNumber == paymentNumber)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.paymentDate, paymentDate) || other.paymentDate == paymentDate)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,organizationId,employeeId,paymentNumber,amount,paymentDate,notes,createdAt,updatedAt);

@override
String toString() {
  return 'EmployeePayment(id: $id, organizationId: $organizationId, employeeId: $employeeId, paymentNumber: $paymentNumber, amount: $amount, paymentDate: $paymentDate, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $EmployeePaymentCopyWith<$Res>  {
  factory $EmployeePaymentCopyWith(EmployeePayment value, $Res Function(EmployeePayment) _then) = _$EmployeePaymentCopyWithImpl;
@useResult
$Res call({
 String id, String organizationId, String employeeId, String paymentNumber, double amount, DateTime paymentDate, String? notes, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$EmployeePaymentCopyWithImpl<$Res>
    implements $EmployeePaymentCopyWith<$Res> {
  _$EmployeePaymentCopyWithImpl(this._self, this._then);

  final EmployeePayment _self;
  final $Res Function(EmployeePayment) _then;

/// Create a copy of EmployeePayment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? employeeId = null,Object? paymentNumber = null,Object? amount = null,Object? paymentDate = null,Object? notes = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,employeeId: null == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as String,paymentNumber: null == paymentNumber ? _self.paymentNumber : paymentNumber // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,paymentDate: null == paymentDate ? _self.paymentDate : paymentDate // ignore: cast_nullable_to_non_nullable
as DateTime,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [EmployeePayment].
extension EmployeePaymentPatterns on EmployeePayment {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EmployeePayment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EmployeePayment() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EmployeePayment value)  $default,){
final _that = this;
switch (_that) {
case _EmployeePayment():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EmployeePayment value)?  $default,){
final _that = this;
switch (_that) {
case _EmployeePayment() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String organizationId,  String employeeId,  String paymentNumber,  double amount,  DateTime paymentDate,  String? notes,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EmployeePayment() when $default != null:
return $default(_that.id,_that.organizationId,_that.employeeId,_that.paymentNumber,_that.amount,_that.paymentDate,_that.notes,_that.createdAt,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String organizationId,  String employeeId,  String paymentNumber,  double amount,  DateTime paymentDate,  String? notes,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _EmployeePayment():
return $default(_that.id,_that.organizationId,_that.employeeId,_that.paymentNumber,_that.amount,_that.paymentDate,_that.notes,_that.createdAt,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String organizationId,  String employeeId,  String paymentNumber,  double amount,  DateTime paymentDate,  String? notes,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _EmployeePayment() when $default != null:
return $default(_that.id,_that.organizationId,_that.employeeId,_that.paymentNumber,_that.amount,_that.paymentDate,_that.notes,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _EmployeePayment extends EmployeePayment {
  const _EmployeePayment({required this.id, required this.organizationId, required this.employeeId, required this.paymentNumber, required this.amount, required this.paymentDate, this.notes, required this.createdAt, required this.updatedAt}): super._();
  

@override final  String id;
@override final  String organizationId;
@override final  String employeeId;
@override final  String paymentNumber;
@override final  double amount;
@override final  DateTime paymentDate;
@override final  String? notes;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of EmployeePayment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EmployeePaymentCopyWith<_EmployeePayment> get copyWith => __$EmployeePaymentCopyWithImpl<_EmployeePayment>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EmployeePayment&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.employeeId, employeeId) || other.employeeId == employeeId)&&(identical(other.paymentNumber, paymentNumber) || other.paymentNumber == paymentNumber)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.paymentDate, paymentDate) || other.paymentDate == paymentDate)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,organizationId,employeeId,paymentNumber,amount,paymentDate,notes,createdAt,updatedAt);

@override
String toString() {
  return 'EmployeePayment(id: $id, organizationId: $organizationId, employeeId: $employeeId, paymentNumber: $paymentNumber, amount: $amount, paymentDate: $paymentDate, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$EmployeePaymentCopyWith<$Res> implements $EmployeePaymentCopyWith<$Res> {
  factory _$EmployeePaymentCopyWith(_EmployeePayment value, $Res Function(_EmployeePayment) _then) = __$EmployeePaymentCopyWithImpl;
@override @useResult
$Res call({
 String id, String organizationId, String employeeId, String paymentNumber, double amount, DateTime paymentDate, String? notes, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$EmployeePaymentCopyWithImpl<$Res>
    implements _$EmployeePaymentCopyWith<$Res> {
  __$EmployeePaymentCopyWithImpl(this._self, this._then);

  final _EmployeePayment _self;
  final $Res Function(_EmployeePayment) _then;

/// Create a copy of EmployeePayment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? employeeId = null,Object? paymentNumber = null,Object? amount = null,Object? paymentDate = null,Object? notes = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_EmployeePayment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,employeeId: null == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as String,paymentNumber: null == paymentNumber ? _self.paymentNumber : paymentNumber // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,paymentDate: null == paymentDate ? _self.paymentDate : paymentDate // ignore: cast_nullable_to_non_nullable
as DateTime,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
