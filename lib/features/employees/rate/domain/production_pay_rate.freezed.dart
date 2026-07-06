// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'production_pay_rate.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProductionPayRate {

 String get id; String get organizationId; String get productId; String? get employeeId; double get rate; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of ProductionPayRate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductionPayRateCopyWith<ProductionPayRate> get copyWith => _$ProductionPayRateCopyWithImpl<ProductionPayRate>(this as ProductionPayRate, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductionPayRate&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.employeeId, employeeId) || other.employeeId == employeeId)&&(identical(other.rate, rate) || other.rate == rate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,organizationId,productId,employeeId,rate,createdAt,updatedAt);

@override
String toString() {
  return 'ProductionPayRate(id: $id, organizationId: $organizationId, productId: $productId, employeeId: $employeeId, rate: $rate, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ProductionPayRateCopyWith<$Res>  {
  factory $ProductionPayRateCopyWith(ProductionPayRate value, $Res Function(ProductionPayRate) _then) = _$ProductionPayRateCopyWithImpl;
@useResult
$Res call({
 String id, String organizationId, String productId, String? employeeId, double rate, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$ProductionPayRateCopyWithImpl<$Res>
    implements $ProductionPayRateCopyWith<$Res> {
  _$ProductionPayRateCopyWithImpl(this._self, this._then);

  final ProductionPayRate _self;
  final $Res Function(ProductionPayRate) _then;

/// Create a copy of ProductionPayRate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? productId = null,Object? employeeId = freezed,Object? rate = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,employeeId: freezed == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as String?,rate: null == rate ? _self.rate : rate // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductionPayRate].
extension ProductionPayRatePatterns on ProductionPayRate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductionPayRate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductionPayRate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductionPayRate value)  $default,){
final _that = this;
switch (_that) {
case _ProductionPayRate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductionPayRate value)?  $default,){
final _that = this;
switch (_that) {
case _ProductionPayRate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String organizationId,  String productId,  String? employeeId,  double rate,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductionPayRate() when $default != null:
return $default(_that.id,_that.organizationId,_that.productId,_that.employeeId,_that.rate,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String organizationId,  String productId,  String? employeeId,  double rate,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ProductionPayRate():
return $default(_that.id,_that.organizationId,_that.productId,_that.employeeId,_that.rate,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String organizationId,  String productId,  String? employeeId,  double rate,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ProductionPayRate() when $default != null:
return $default(_that.id,_that.organizationId,_that.productId,_that.employeeId,_that.rate,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _ProductionPayRate extends ProductionPayRate {
  const _ProductionPayRate({required this.id, required this.organizationId, required this.productId, this.employeeId, required this.rate, required this.createdAt, required this.updatedAt}): super._();
  

@override final  String id;
@override final  String organizationId;
@override final  String productId;
@override final  String? employeeId;
@override final  double rate;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of ProductionPayRate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductionPayRateCopyWith<_ProductionPayRate> get copyWith => __$ProductionPayRateCopyWithImpl<_ProductionPayRate>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductionPayRate&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.employeeId, employeeId) || other.employeeId == employeeId)&&(identical(other.rate, rate) || other.rate == rate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,organizationId,productId,employeeId,rate,createdAt,updatedAt);

@override
String toString() {
  return 'ProductionPayRate(id: $id, organizationId: $organizationId, productId: $productId, employeeId: $employeeId, rate: $rate, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ProductionPayRateCopyWith<$Res> implements $ProductionPayRateCopyWith<$Res> {
  factory _$ProductionPayRateCopyWith(_ProductionPayRate value, $Res Function(_ProductionPayRate) _then) = __$ProductionPayRateCopyWithImpl;
@override @useResult
$Res call({
 String id, String organizationId, String productId, String? employeeId, double rate, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$ProductionPayRateCopyWithImpl<$Res>
    implements _$ProductionPayRateCopyWith<$Res> {
  __$ProductionPayRateCopyWithImpl(this._self, this._then);

  final _ProductionPayRate _self;
  final $Res Function(_ProductionPayRate) _then;

/// Create a copy of ProductionPayRate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? productId = null,Object? employeeId = freezed,Object? rate = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_ProductionPayRate(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,employeeId: freezed == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as String?,rate: null == rate ? _self.rate : rate // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
