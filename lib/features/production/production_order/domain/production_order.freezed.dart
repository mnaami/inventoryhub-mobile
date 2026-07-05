// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'production_order.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProductionOrder {

 String get id; String get organizationId; String get orderNumber; String get productId; String? get employeeId; double get quantity; ProductionOrderStatus get status; DateTime? get startDate; DateTime? get completionDate; String? get notes; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of ProductionOrder
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductionOrderCopyWith<ProductionOrder> get copyWith => _$ProductionOrderCopyWithImpl<ProductionOrder>(this as ProductionOrder, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductionOrder&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.employeeId, employeeId) || other.employeeId == employeeId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.status, status) || other.status == status)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.completionDate, completionDate) || other.completionDate == completionDate)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,organizationId,orderNumber,productId,employeeId,quantity,status,startDate,completionDate,notes,createdAt,updatedAt);

@override
String toString() {
  return 'ProductionOrder(id: $id, organizationId: $organizationId, orderNumber: $orderNumber, productId: $productId, employeeId: $employeeId, quantity: $quantity, status: $status, startDate: $startDate, completionDate: $completionDate, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ProductionOrderCopyWith<$Res>  {
  factory $ProductionOrderCopyWith(ProductionOrder value, $Res Function(ProductionOrder) _then) = _$ProductionOrderCopyWithImpl;
@useResult
$Res call({
 String id, String organizationId, String orderNumber, String productId, String? employeeId, double quantity, ProductionOrderStatus status, DateTime? startDate, DateTime? completionDate, String? notes, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$ProductionOrderCopyWithImpl<$Res>
    implements $ProductionOrderCopyWith<$Res> {
  _$ProductionOrderCopyWithImpl(this._self, this._then);

  final ProductionOrder _self;
  final $Res Function(ProductionOrder) _then;

/// Create a copy of ProductionOrder
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? orderNumber = null,Object? productId = null,Object? employeeId = freezed,Object? quantity = null,Object? status = null,Object? startDate = freezed,Object? completionDate = freezed,Object? notes = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,employeeId: freezed == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ProductionOrderStatus,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,completionDate: freezed == completionDate ? _self.completionDate : completionDate // ignore: cast_nullable_to_non_nullable
as DateTime?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductionOrder].
extension ProductionOrderPatterns on ProductionOrder {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductionOrder value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductionOrder() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductionOrder value)  $default,){
final _that = this;
switch (_that) {
case _ProductionOrder():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductionOrder value)?  $default,){
final _that = this;
switch (_that) {
case _ProductionOrder() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String organizationId,  String orderNumber,  String productId,  String? employeeId,  double quantity,  ProductionOrderStatus status,  DateTime? startDate,  DateTime? completionDate,  String? notes,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductionOrder() when $default != null:
return $default(_that.id,_that.organizationId,_that.orderNumber,_that.productId,_that.employeeId,_that.quantity,_that.status,_that.startDate,_that.completionDate,_that.notes,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String organizationId,  String orderNumber,  String productId,  String? employeeId,  double quantity,  ProductionOrderStatus status,  DateTime? startDate,  DateTime? completionDate,  String? notes,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ProductionOrder():
return $default(_that.id,_that.organizationId,_that.orderNumber,_that.productId,_that.employeeId,_that.quantity,_that.status,_that.startDate,_that.completionDate,_that.notes,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String organizationId,  String orderNumber,  String productId,  String? employeeId,  double quantity,  ProductionOrderStatus status,  DateTime? startDate,  DateTime? completionDate,  String? notes,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ProductionOrder() when $default != null:
return $default(_that.id,_that.organizationId,_that.orderNumber,_that.productId,_that.employeeId,_that.quantity,_that.status,_that.startDate,_that.completionDate,_that.notes,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _ProductionOrder extends ProductionOrder {
  const _ProductionOrder({required this.id, required this.organizationId, required this.orderNumber, required this.productId, this.employeeId, required this.quantity, required this.status, this.startDate, this.completionDate, this.notes, required this.createdAt, required this.updatedAt}): super._();
  

@override final  String id;
@override final  String organizationId;
@override final  String orderNumber;
@override final  String productId;
@override final  String? employeeId;
@override final  double quantity;
@override final  ProductionOrderStatus status;
@override final  DateTime? startDate;
@override final  DateTime? completionDate;
@override final  String? notes;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of ProductionOrder
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductionOrderCopyWith<_ProductionOrder> get copyWith => __$ProductionOrderCopyWithImpl<_ProductionOrder>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductionOrder&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.employeeId, employeeId) || other.employeeId == employeeId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.status, status) || other.status == status)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.completionDate, completionDate) || other.completionDate == completionDate)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,organizationId,orderNumber,productId,employeeId,quantity,status,startDate,completionDate,notes,createdAt,updatedAt);

@override
String toString() {
  return 'ProductionOrder(id: $id, organizationId: $organizationId, orderNumber: $orderNumber, productId: $productId, employeeId: $employeeId, quantity: $quantity, status: $status, startDate: $startDate, completionDate: $completionDate, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ProductionOrderCopyWith<$Res> implements $ProductionOrderCopyWith<$Res> {
  factory _$ProductionOrderCopyWith(_ProductionOrder value, $Res Function(_ProductionOrder) _then) = __$ProductionOrderCopyWithImpl;
@override @useResult
$Res call({
 String id, String organizationId, String orderNumber, String productId, String? employeeId, double quantity, ProductionOrderStatus status, DateTime? startDate, DateTime? completionDate, String? notes, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$ProductionOrderCopyWithImpl<$Res>
    implements _$ProductionOrderCopyWith<$Res> {
  __$ProductionOrderCopyWithImpl(this._self, this._then);

  final _ProductionOrder _self;
  final $Res Function(_ProductionOrder) _then;

/// Create a copy of ProductionOrder
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? orderNumber = null,Object? productId = null,Object? employeeId = freezed,Object? quantity = null,Object? status = null,Object? startDate = freezed,Object? completionDate = freezed,Object? notes = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_ProductionOrder(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,employeeId: freezed == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ProductionOrderStatus,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,completionDate: freezed == completionDate ? _self.completionDate : completionDate // ignore: cast_nullable_to_non_nullable
as DateTime?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
