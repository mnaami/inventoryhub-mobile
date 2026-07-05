// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sale_order.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SaleOrder {

 String get id; String get organizationId; String get soNumber; String get customerId; DateTime get orderDate; DateTime? get deliveryDate; OrderStatus get status; PaymentStatus get paymentStatus; ShippingStatus get shippingStatus; double get totalAmount; bool get isActive; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of SaleOrder
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SaleOrderCopyWith<SaleOrder> get copyWith => _$SaleOrderCopyWithImpl<SaleOrder>(this as SaleOrder, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SaleOrder&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.soNumber, soNumber) || other.soNumber == soNumber)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.orderDate, orderDate) || other.orderDate == orderDate)&&(identical(other.deliveryDate, deliveryDate) || other.deliveryDate == deliveryDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.paymentStatus, paymentStatus) || other.paymentStatus == paymentStatus)&&(identical(other.shippingStatus, shippingStatus) || other.shippingStatus == shippingStatus)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,organizationId,soNumber,customerId,orderDate,deliveryDate,status,paymentStatus,shippingStatus,totalAmount,isActive,createdAt,updatedAt);

@override
String toString() {
  return 'SaleOrder(id: $id, organizationId: $organizationId, soNumber: $soNumber, customerId: $customerId, orderDate: $orderDate, deliveryDate: $deliveryDate, status: $status, paymentStatus: $paymentStatus, shippingStatus: $shippingStatus, totalAmount: $totalAmount, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $SaleOrderCopyWith<$Res>  {
  factory $SaleOrderCopyWith(SaleOrder value, $Res Function(SaleOrder) _then) = _$SaleOrderCopyWithImpl;
@useResult
$Res call({
 String id, String organizationId, String soNumber, String customerId, DateTime orderDate, DateTime? deliveryDate, OrderStatus status, PaymentStatus paymentStatus, ShippingStatus shippingStatus, double totalAmount, bool isActive, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$SaleOrderCopyWithImpl<$Res>
    implements $SaleOrderCopyWith<$Res> {
  _$SaleOrderCopyWithImpl(this._self, this._then);

  final SaleOrder _self;
  final $Res Function(SaleOrder) _then;

/// Create a copy of SaleOrder
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? soNumber = null,Object? customerId = null,Object? orderDate = null,Object? deliveryDate = freezed,Object? status = null,Object? paymentStatus = null,Object? shippingStatus = null,Object? totalAmount = null,Object? isActive = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,soNumber: null == soNumber ? _self.soNumber : soNumber // ignore: cast_nullable_to_non_nullable
as String,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,orderDate: null == orderDate ? _self.orderDate : orderDate // ignore: cast_nullable_to_non_nullable
as DateTime,deliveryDate: freezed == deliveryDate ? _self.deliveryDate : deliveryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,paymentStatus: null == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as PaymentStatus,shippingStatus: null == shippingStatus ? _self.shippingStatus : shippingStatus // ignore: cast_nullable_to_non_nullable
as ShippingStatus,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [SaleOrder].
extension SaleOrderPatterns on SaleOrder {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SaleOrder value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SaleOrder() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SaleOrder value)  $default,){
final _that = this;
switch (_that) {
case _SaleOrder():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SaleOrder value)?  $default,){
final _that = this;
switch (_that) {
case _SaleOrder() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String organizationId,  String soNumber,  String customerId,  DateTime orderDate,  DateTime? deliveryDate,  OrderStatus status,  PaymentStatus paymentStatus,  ShippingStatus shippingStatus,  double totalAmount,  bool isActive,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SaleOrder() when $default != null:
return $default(_that.id,_that.organizationId,_that.soNumber,_that.customerId,_that.orderDate,_that.deliveryDate,_that.status,_that.paymentStatus,_that.shippingStatus,_that.totalAmount,_that.isActive,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String organizationId,  String soNumber,  String customerId,  DateTime orderDate,  DateTime? deliveryDate,  OrderStatus status,  PaymentStatus paymentStatus,  ShippingStatus shippingStatus,  double totalAmount,  bool isActive,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _SaleOrder():
return $default(_that.id,_that.organizationId,_that.soNumber,_that.customerId,_that.orderDate,_that.deliveryDate,_that.status,_that.paymentStatus,_that.shippingStatus,_that.totalAmount,_that.isActive,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String organizationId,  String soNumber,  String customerId,  DateTime orderDate,  DateTime? deliveryDate,  OrderStatus status,  PaymentStatus paymentStatus,  ShippingStatus shippingStatus,  double totalAmount,  bool isActive,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _SaleOrder() when $default != null:
return $default(_that.id,_that.organizationId,_that.soNumber,_that.customerId,_that.orderDate,_that.deliveryDate,_that.status,_that.paymentStatus,_that.shippingStatus,_that.totalAmount,_that.isActive,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _SaleOrder extends SaleOrder {
  const _SaleOrder({required this.id, required this.organizationId, required this.soNumber, required this.customerId, required this.orderDate, this.deliveryDate, required this.status, required this.paymentStatus, required this.shippingStatus, required this.totalAmount, required this.isActive, required this.createdAt, required this.updatedAt}): super._();
  

@override final  String id;
@override final  String organizationId;
@override final  String soNumber;
@override final  String customerId;
@override final  DateTime orderDate;
@override final  DateTime? deliveryDate;
@override final  OrderStatus status;
@override final  PaymentStatus paymentStatus;
@override final  ShippingStatus shippingStatus;
@override final  double totalAmount;
@override final  bool isActive;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of SaleOrder
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SaleOrderCopyWith<_SaleOrder> get copyWith => __$SaleOrderCopyWithImpl<_SaleOrder>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SaleOrder&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.soNumber, soNumber) || other.soNumber == soNumber)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.orderDate, orderDate) || other.orderDate == orderDate)&&(identical(other.deliveryDate, deliveryDate) || other.deliveryDate == deliveryDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.paymentStatus, paymentStatus) || other.paymentStatus == paymentStatus)&&(identical(other.shippingStatus, shippingStatus) || other.shippingStatus == shippingStatus)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,organizationId,soNumber,customerId,orderDate,deliveryDate,status,paymentStatus,shippingStatus,totalAmount,isActive,createdAt,updatedAt);

@override
String toString() {
  return 'SaleOrder(id: $id, organizationId: $organizationId, soNumber: $soNumber, customerId: $customerId, orderDate: $orderDate, deliveryDate: $deliveryDate, status: $status, paymentStatus: $paymentStatus, shippingStatus: $shippingStatus, totalAmount: $totalAmount, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$SaleOrderCopyWith<$Res> implements $SaleOrderCopyWith<$Res> {
  factory _$SaleOrderCopyWith(_SaleOrder value, $Res Function(_SaleOrder) _then) = __$SaleOrderCopyWithImpl;
@override @useResult
$Res call({
 String id, String organizationId, String soNumber, String customerId, DateTime orderDate, DateTime? deliveryDate, OrderStatus status, PaymentStatus paymentStatus, ShippingStatus shippingStatus, double totalAmount, bool isActive, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$SaleOrderCopyWithImpl<$Res>
    implements _$SaleOrderCopyWith<$Res> {
  __$SaleOrderCopyWithImpl(this._self, this._then);

  final _SaleOrder _self;
  final $Res Function(_SaleOrder) _then;

/// Create a copy of SaleOrder
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? soNumber = null,Object? customerId = null,Object? orderDate = null,Object? deliveryDate = freezed,Object? status = null,Object? paymentStatus = null,Object? shippingStatus = null,Object? totalAmount = null,Object? isActive = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_SaleOrder(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,soNumber: null == soNumber ? _self.soNumber : soNumber // ignore: cast_nullable_to_non_nullable
as String,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,orderDate: null == orderDate ? _self.orderDate : orderDate // ignore: cast_nullable_to_non_nullable
as DateTime,deliveryDate: freezed == deliveryDate ? _self.deliveryDate : deliveryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,paymentStatus: null == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as PaymentStatus,shippingStatus: null == shippingStatus ? _self.shippingStatus : shippingStatus // ignore: cast_nullable_to_non_nullable
as ShippingStatus,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
mixin _$SaleOrderItem {

 String get id; String get organizationId; String get saleOrderId; String get productId; String get productName; double get quantity; double get unitPrice; double get totalPrice; double get shippedQuantity; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of SaleOrderItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SaleOrderItemCopyWith<SaleOrderItem> get copyWith => _$SaleOrderItemCopyWithImpl<SaleOrderItem>(this as SaleOrderItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SaleOrderItem&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.saleOrderId, saleOrderId) || other.saleOrderId == saleOrderId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.totalPrice, totalPrice) || other.totalPrice == totalPrice)&&(identical(other.shippedQuantity, shippedQuantity) || other.shippedQuantity == shippedQuantity)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,organizationId,saleOrderId,productId,productName,quantity,unitPrice,totalPrice,shippedQuantity,createdAt,updatedAt);

@override
String toString() {
  return 'SaleOrderItem(id: $id, organizationId: $organizationId, saleOrderId: $saleOrderId, productId: $productId, productName: $productName, quantity: $quantity, unitPrice: $unitPrice, totalPrice: $totalPrice, shippedQuantity: $shippedQuantity, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $SaleOrderItemCopyWith<$Res>  {
  factory $SaleOrderItemCopyWith(SaleOrderItem value, $Res Function(SaleOrderItem) _then) = _$SaleOrderItemCopyWithImpl;
@useResult
$Res call({
 String id, String organizationId, String saleOrderId, String productId, String productName, double quantity, double unitPrice, double totalPrice, double shippedQuantity, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$SaleOrderItemCopyWithImpl<$Res>
    implements $SaleOrderItemCopyWith<$Res> {
  _$SaleOrderItemCopyWithImpl(this._self, this._then);

  final SaleOrderItem _self;
  final $Res Function(SaleOrderItem) _then;

/// Create a copy of SaleOrderItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? saleOrderId = null,Object? productId = null,Object? productName = null,Object? quantity = null,Object? unitPrice = null,Object? totalPrice = null,Object? shippedQuantity = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,saleOrderId: null == saleOrderId ? _self.saleOrderId : saleOrderId // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,totalPrice: null == totalPrice ? _self.totalPrice : totalPrice // ignore: cast_nullable_to_non_nullable
as double,shippedQuantity: null == shippedQuantity ? _self.shippedQuantity : shippedQuantity // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [SaleOrderItem].
extension SaleOrderItemPatterns on SaleOrderItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SaleOrderItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SaleOrderItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SaleOrderItem value)  $default,){
final _that = this;
switch (_that) {
case _SaleOrderItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SaleOrderItem value)?  $default,){
final _that = this;
switch (_that) {
case _SaleOrderItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String organizationId,  String saleOrderId,  String productId,  String productName,  double quantity,  double unitPrice,  double totalPrice,  double shippedQuantity,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SaleOrderItem() when $default != null:
return $default(_that.id,_that.organizationId,_that.saleOrderId,_that.productId,_that.productName,_that.quantity,_that.unitPrice,_that.totalPrice,_that.shippedQuantity,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String organizationId,  String saleOrderId,  String productId,  String productName,  double quantity,  double unitPrice,  double totalPrice,  double shippedQuantity,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _SaleOrderItem():
return $default(_that.id,_that.organizationId,_that.saleOrderId,_that.productId,_that.productName,_that.quantity,_that.unitPrice,_that.totalPrice,_that.shippedQuantity,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String organizationId,  String saleOrderId,  String productId,  String productName,  double quantity,  double unitPrice,  double totalPrice,  double shippedQuantity,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _SaleOrderItem() when $default != null:
return $default(_that.id,_that.organizationId,_that.saleOrderId,_that.productId,_that.productName,_that.quantity,_that.unitPrice,_that.totalPrice,_that.shippedQuantity,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _SaleOrderItem extends SaleOrderItem {
  const _SaleOrderItem({required this.id, required this.organizationId, required this.saleOrderId, required this.productId, required this.productName, required this.quantity, required this.unitPrice, required this.totalPrice, required this.shippedQuantity, required this.createdAt, required this.updatedAt}): super._();
  

@override final  String id;
@override final  String organizationId;
@override final  String saleOrderId;
@override final  String productId;
@override final  String productName;
@override final  double quantity;
@override final  double unitPrice;
@override final  double totalPrice;
@override final  double shippedQuantity;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of SaleOrderItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SaleOrderItemCopyWith<_SaleOrderItem> get copyWith => __$SaleOrderItemCopyWithImpl<_SaleOrderItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SaleOrderItem&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.saleOrderId, saleOrderId) || other.saleOrderId == saleOrderId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.totalPrice, totalPrice) || other.totalPrice == totalPrice)&&(identical(other.shippedQuantity, shippedQuantity) || other.shippedQuantity == shippedQuantity)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,organizationId,saleOrderId,productId,productName,quantity,unitPrice,totalPrice,shippedQuantity,createdAt,updatedAt);

@override
String toString() {
  return 'SaleOrderItem(id: $id, organizationId: $organizationId, saleOrderId: $saleOrderId, productId: $productId, productName: $productName, quantity: $quantity, unitPrice: $unitPrice, totalPrice: $totalPrice, shippedQuantity: $shippedQuantity, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$SaleOrderItemCopyWith<$Res> implements $SaleOrderItemCopyWith<$Res> {
  factory _$SaleOrderItemCopyWith(_SaleOrderItem value, $Res Function(_SaleOrderItem) _then) = __$SaleOrderItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String organizationId, String saleOrderId, String productId, String productName, double quantity, double unitPrice, double totalPrice, double shippedQuantity, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$SaleOrderItemCopyWithImpl<$Res>
    implements _$SaleOrderItemCopyWith<$Res> {
  __$SaleOrderItemCopyWithImpl(this._self, this._then);

  final _SaleOrderItem _self;
  final $Res Function(_SaleOrderItem) _then;

/// Create a copy of SaleOrderItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? saleOrderId = null,Object? productId = null,Object? productName = null,Object? quantity = null,Object? unitPrice = null,Object? totalPrice = null,Object? shippedQuantity = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_SaleOrderItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,saleOrderId: null == saleOrderId ? _self.saleOrderId : saleOrderId // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,totalPrice: null == totalPrice ? _self.totalPrice : totalPrice // ignore: cast_nullable_to_non_nullable
as double,shippedQuantity: null == shippedQuantity ? _self.shippedQuantity : shippedQuantity // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
mixin _$SaleOrderPayment {

 String get id; String get organizationId; String get saleOrderId; String get paymentNumber; double get amount; PaymentMethod get method; PaymentRecordStatus get status; DateTime get paymentDate; bool get isActive; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of SaleOrderPayment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SaleOrderPaymentCopyWith<SaleOrderPayment> get copyWith => _$SaleOrderPaymentCopyWithImpl<SaleOrderPayment>(this as SaleOrderPayment, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SaleOrderPayment&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.saleOrderId, saleOrderId) || other.saleOrderId == saleOrderId)&&(identical(other.paymentNumber, paymentNumber) || other.paymentNumber == paymentNumber)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.method, method) || other.method == method)&&(identical(other.status, status) || other.status == status)&&(identical(other.paymentDate, paymentDate) || other.paymentDate == paymentDate)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,organizationId,saleOrderId,paymentNumber,amount,method,status,paymentDate,isActive,createdAt,updatedAt);

@override
String toString() {
  return 'SaleOrderPayment(id: $id, organizationId: $organizationId, saleOrderId: $saleOrderId, paymentNumber: $paymentNumber, amount: $amount, method: $method, status: $status, paymentDate: $paymentDate, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $SaleOrderPaymentCopyWith<$Res>  {
  factory $SaleOrderPaymentCopyWith(SaleOrderPayment value, $Res Function(SaleOrderPayment) _then) = _$SaleOrderPaymentCopyWithImpl;
@useResult
$Res call({
 String id, String organizationId, String saleOrderId, String paymentNumber, double amount, PaymentMethod method, PaymentRecordStatus status, DateTime paymentDate, bool isActive, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$SaleOrderPaymentCopyWithImpl<$Res>
    implements $SaleOrderPaymentCopyWith<$Res> {
  _$SaleOrderPaymentCopyWithImpl(this._self, this._then);

  final SaleOrderPayment _self;
  final $Res Function(SaleOrderPayment) _then;

/// Create a copy of SaleOrderPayment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? saleOrderId = null,Object? paymentNumber = null,Object? amount = null,Object? method = null,Object? status = null,Object? paymentDate = null,Object? isActive = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,saleOrderId: null == saleOrderId ? _self.saleOrderId : saleOrderId // ignore: cast_nullable_to_non_nullable
as String,paymentNumber: null == paymentNumber ? _self.paymentNumber : paymentNumber // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as PaymentMethod,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PaymentRecordStatus,paymentDate: null == paymentDate ? _self.paymentDate : paymentDate // ignore: cast_nullable_to_non_nullable
as DateTime,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [SaleOrderPayment].
extension SaleOrderPaymentPatterns on SaleOrderPayment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SaleOrderPayment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SaleOrderPayment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SaleOrderPayment value)  $default,){
final _that = this;
switch (_that) {
case _SaleOrderPayment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SaleOrderPayment value)?  $default,){
final _that = this;
switch (_that) {
case _SaleOrderPayment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String organizationId,  String saleOrderId,  String paymentNumber,  double amount,  PaymentMethod method,  PaymentRecordStatus status,  DateTime paymentDate,  bool isActive,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SaleOrderPayment() when $default != null:
return $default(_that.id,_that.organizationId,_that.saleOrderId,_that.paymentNumber,_that.amount,_that.method,_that.status,_that.paymentDate,_that.isActive,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String organizationId,  String saleOrderId,  String paymentNumber,  double amount,  PaymentMethod method,  PaymentRecordStatus status,  DateTime paymentDate,  bool isActive,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _SaleOrderPayment():
return $default(_that.id,_that.organizationId,_that.saleOrderId,_that.paymentNumber,_that.amount,_that.method,_that.status,_that.paymentDate,_that.isActive,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String organizationId,  String saleOrderId,  String paymentNumber,  double amount,  PaymentMethod method,  PaymentRecordStatus status,  DateTime paymentDate,  bool isActive,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _SaleOrderPayment() when $default != null:
return $default(_that.id,_that.organizationId,_that.saleOrderId,_that.paymentNumber,_that.amount,_that.method,_that.status,_that.paymentDate,_that.isActive,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _SaleOrderPayment implements SaleOrderPayment {
  const _SaleOrderPayment({required this.id, required this.organizationId, required this.saleOrderId, required this.paymentNumber, required this.amount, required this.method, required this.status, required this.paymentDate, required this.isActive, required this.createdAt, required this.updatedAt});
  

@override final  String id;
@override final  String organizationId;
@override final  String saleOrderId;
@override final  String paymentNumber;
@override final  double amount;
@override final  PaymentMethod method;
@override final  PaymentRecordStatus status;
@override final  DateTime paymentDate;
@override final  bool isActive;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of SaleOrderPayment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SaleOrderPaymentCopyWith<_SaleOrderPayment> get copyWith => __$SaleOrderPaymentCopyWithImpl<_SaleOrderPayment>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SaleOrderPayment&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.saleOrderId, saleOrderId) || other.saleOrderId == saleOrderId)&&(identical(other.paymentNumber, paymentNumber) || other.paymentNumber == paymentNumber)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.method, method) || other.method == method)&&(identical(other.status, status) || other.status == status)&&(identical(other.paymentDate, paymentDate) || other.paymentDate == paymentDate)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,organizationId,saleOrderId,paymentNumber,amount,method,status,paymentDate,isActive,createdAt,updatedAt);

@override
String toString() {
  return 'SaleOrderPayment(id: $id, organizationId: $organizationId, saleOrderId: $saleOrderId, paymentNumber: $paymentNumber, amount: $amount, method: $method, status: $status, paymentDate: $paymentDate, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$SaleOrderPaymentCopyWith<$Res> implements $SaleOrderPaymentCopyWith<$Res> {
  factory _$SaleOrderPaymentCopyWith(_SaleOrderPayment value, $Res Function(_SaleOrderPayment) _then) = __$SaleOrderPaymentCopyWithImpl;
@override @useResult
$Res call({
 String id, String organizationId, String saleOrderId, String paymentNumber, double amount, PaymentMethod method, PaymentRecordStatus status, DateTime paymentDate, bool isActive, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$SaleOrderPaymentCopyWithImpl<$Res>
    implements _$SaleOrderPaymentCopyWith<$Res> {
  __$SaleOrderPaymentCopyWithImpl(this._self, this._then);

  final _SaleOrderPayment _self;
  final $Res Function(_SaleOrderPayment) _then;

/// Create a copy of SaleOrderPayment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? saleOrderId = null,Object? paymentNumber = null,Object? amount = null,Object? method = null,Object? status = null,Object? paymentDate = null,Object? isActive = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_SaleOrderPayment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,saleOrderId: null == saleOrderId ? _self.saleOrderId : saleOrderId // ignore: cast_nullable_to_non_nullable
as String,paymentNumber: null == paymentNumber ? _self.paymentNumber : paymentNumber // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as PaymentMethod,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PaymentRecordStatus,paymentDate: null == paymentDate ? _self.paymentDate : paymentDate // ignore: cast_nullable_to_non_nullable
as DateTime,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
mixin _$SaleOrderShipping {

 String get id; String get organizationId; String get saleOrderId; String get soShippingNumber; DateTime get shippingDate; String? get carrier; String? get trackingNumber; ShipmentStatus get status; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of SaleOrderShipping
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SaleOrderShippingCopyWith<SaleOrderShipping> get copyWith => _$SaleOrderShippingCopyWithImpl<SaleOrderShipping>(this as SaleOrderShipping, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SaleOrderShipping&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.saleOrderId, saleOrderId) || other.saleOrderId == saleOrderId)&&(identical(other.soShippingNumber, soShippingNumber) || other.soShippingNumber == soShippingNumber)&&(identical(other.shippingDate, shippingDate) || other.shippingDate == shippingDate)&&(identical(other.carrier, carrier) || other.carrier == carrier)&&(identical(other.trackingNumber, trackingNumber) || other.trackingNumber == trackingNumber)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,organizationId,saleOrderId,soShippingNumber,shippingDate,carrier,trackingNumber,status,createdAt,updatedAt);

@override
String toString() {
  return 'SaleOrderShipping(id: $id, organizationId: $organizationId, saleOrderId: $saleOrderId, soShippingNumber: $soShippingNumber, shippingDate: $shippingDate, carrier: $carrier, trackingNumber: $trackingNumber, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $SaleOrderShippingCopyWith<$Res>  {
  factory $SaleOrderShippingCopyWith(SaleOrderShipping value, $Res Function(SaleOrderShipping) _then) = _$SaleOrderShippingCopyWithImpl;
@useResult
$Res call({
 String id, String organizationId, String saleOrderId, String soShippingNumber, DateTime shippingDate, String? carrier, String? trackingNumber, ShipmentStatus status, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$SaleOrderShippingCopyWithImpl<$Res>
    implements $SaleOrderShippingCopyWith<$Res> {
  _$SaleOrderShippingCopyWithImpl(this._self, this._then);

  final SaleOrderShipping _self;
  final $Res Function(SaleOrderShipping) _then;

/// Create a copy of SaleOrderShipping
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? saleOrderId = null,Object? soShippingNumber = null,Object? shippingDate = null,Object? carrier = freezed,Object? trackingNumber = freezed,Object? status = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,saleOrderId: null == saleOrderId ? _self.saleOrderId : saleOrderId // ignore: cast_nullable_to_non_nullable
as String,soShippingNumber: null == soShippingNumber ? _self.soShippingNumber : soShippingNumber // ignore: cast_nullable_to_non_nullable
as String,shippingDate: null == shippingDate ? _self.shippingDate : shippingDate // ignore: cast_nullable_to_non_nullable
as DateTime,carrier: freezed == carrier ? _self.carrier : carrier // ignore: cast_nullable_to_non_nullable
as String?,trackingNumber: freezed == trackingNumber ? _self.trackingNumber : trackingNumber // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ShipmentStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [SaleOrderShipping].
extension SaleOrderShippingPatterns on SaleOrderShipping {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SaleOrderShipping value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SaleOrderShipping() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SaleOrderShipping value)  $default,){
final _that = this;
switch (_that) {
case _SaleOrderShipping():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SaleOrderShipping value)?  $default,){
final _that = this;
switch (_that) {
case _SaleOrderShipping() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String organizationId,  String saleOrderId,  String soShippingNumber,  DateTime shippingDate,  String? carrier,  String? trackingNumber,  ShipmentStatus status,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SaleOrderShipping() when $default != null:
return $default(_that.id,_that.organizationId,_that.saleOrderId,_that.soShippingNumber,_that.shippingDate,_that.carrier,_that.trackingNumber,_that.status,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String organizationId,  String saleOrderId,  String soShippingNumber,  DateTime shippingDate,  String? carrier,  String? trackingNumber,  ShipmentStatus status,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _SaleOrderShipping():
return $default(_that.id,_that.organizationId,_that.saleOrderId,_that.soShippingNumber,_that.shippingDate,_that.carrier,_that.trackingNumber,_that.status,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String organizationId,  String saleOrderId,  String soShippingNumber,  DateTime shippingDate,  String? carrier,  String? trackingNumber,  ShipmentStatus status,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _SaleOrderShipping() when $default != null:
return $default(_that.id,_that.organizationId,_that.saleOrderId,_that.soShippingNumber,_that.shippingDate,_that.carrier,_that.trackingNumber,_that.status,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _SaleOrderShipping implements SaleOrderShipping {
  const _SaleOrderShipping({required this.id, required this.organizationId, required this.saleOrderId, required this.soShippingNumber, required this.shippingDate, this.carrier, this.trackingNumber, required this.status, required this.createdAt, required this.updatedAt});
  

@override final  String id;
@override final  String organizationId;
@override final  String saleOrderId;
@override final  String soShippingNumber;
@override final  DateTime shippingDate;
@override final  String? carrier;
@override final  String? trackingNumber;
@override final  ShipmentStatus status;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of SaleOrderShipping
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SaleOrderShippingCopyWith<_SaleOrderShipping> get copyWith => __$SaleOrderShippingCopyWithImpl<_SaleOrderShipping>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SaleOrderShipping&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.saleOrderId, saleOrderId) || other.saleOrderId == saleOrderId)&&(identical(other.soShippingNumber, soShippingNumber) || other.soShippingNumber == soShippingNumber)&&(identical(other.shippingDate, shippingDate) || other.shippingDate == shippingDate)&&(identical(other.carrier, carrier) || other.carrier == carrier)&&(identical(other.trackingNumber, trackingNumber) || other.trackingNumber == trackingNumber)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,organizationId,saleOrderId,soShippingNumber,shippingDate,carrier,trackingNumber,status,createdAt,updatedAt);

@override
String toString() {
  return 'SaleOrderShipping(id: $id, organizationId: $organizationId, saleOrderId: $saleOrderId, soShippingNumber: $soShippingNumber, shippingDate: $shippingDate, carrier: $carrier, trackingNumber: $trackingNumber, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$SaleOrderShippingCopyWith<$Res> implements $SaleOrderShippingCopyWith<$Res> {
  factory _$SaleOrderShippingCopyWith(_SaleOrderShipping value, $Res Function(_SaleOrderShipping) _then) = __$SaleOrderShippingCopyWithImpl;
@override @useResult
$Res call({
 String id, String organizationId, String saleOrderId, String soShippingNumber, DateTime shippingDate, String? carrier, String? trackingNumber, ShipmentStatus status, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$SaleOrderShippingCopyWithImpl<$Res>
    implements _$SaleOrderShippingCopyWith<$Res> {
  __$SaleOrderShippingCopyWithImpl(this._self, this._then);

  final _SaleOrderShipping _self;
  final $Res Function(_SaleOrderShipping) _then;

/// Create a copy of SaleOrderShipping
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? saleOrderId = null,Object? soShippingNumber = null,Object? shippingDate = null,Object? carrier = freezed,Object? trackingNumber = freezed,Object? status = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_SaleOrderShipping(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,saleOrderId: null == saleOrderId ? _self.saleOrderId : saleOrderId // ignore: cast_nullable_to_non_nullable
as String,soShippingNumber: null == soShippingNumber ? _self.soShippingNumber : soShippingNumber // ignore: cast_nullable_to_non_nullable
as String,shippingDate: null == shippingDate ? _self.shippingDate : shippingDate // ignore: cast_nullable_to_non_nullable
as DateTime,carrier: freezed == carrier ? _self.carrier : carrier // ignore: cast_nullable_to_non_nullable
as String?,trackingNumber: freezed == trackingNumber ? _self.trackingNumber : trackingNumber // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ShipmentStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
mixin _$SaleOrderShippingItem {

 String get id; String get organizationId; String get shippingId; String get saleOrderItemId; String get productId; double get quantity; DateTime get createdAt;
/// Create a copy of SaleOrderShippingItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SaleOrderShippingItemCopyWith<SaleOrderShippingItem> get copyWith => _$SaleOrderShippingItemCopyWithImpl<SaleOrderShippingItem>(this as SaleOrderShippingItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SaleOrderShippingItem&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.shippingId, shippingId) || other.shippingId == shippingId)&&(identical(other.saleOrderItemId, saleOrderItemId) || other.saleOrderItemId == saleOrderItemId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,organizationId,shippingId,saleOrderItemId,productId,quantity,createdAt);

@override
String toString() {
  return 'SaleOrderShippingItem(id: $id, organizationId: $organizationId, shippingId: $shippingId, saleOrderItemId: $saleOrderItemId, productId: $productId, quantity: $quantity, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $SaleOrderShippingItemCopyWith<$Res>  {
  factory $SaleOrderShippingItemCopyWith(SaleOrderShippingItem value, $Res Function(SaleOrderShippingItem) _then) = _$SaleOrderShippingItemCopyWithImpl;
@useResult
$Res call({
 String id, String organizationId, String shippingId, String saleOrderItemId, String productId, double quantity, DateTime createdAt
});




}
/// @nodoc
class _$SaleOrderShippingItemCopyWithImpl<$Res>
    implements $SaleOrderShippingItemCopyWith<$Res> {
  _$SaleOrderShippingItemCopyWithImpl(this._self, this._then);

  final SaleOrderShippingItem _self;
  final $Res Function(SaleOrderShippingItem) _then;

/// Create a copy of SaleOrderShippingItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? shippingId = null,Object? saleOrderItemId = null,Object? productId = null,Object? quantity = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,shippingId: null == shippingId ? _self.shippingId : shippingId // ignore: cast_nullable_to_non_nullable
as String,saleOrderItemId: null == saleOrderItemId ? _self.saleOrderItemId : saleOrderItemId // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [SaleOrderShippingItem].
extension SaleOrderShippingItemPatterns on SaleOrderShippingItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SaleOrderShippingItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SaleOrderShippingItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SaleOrderShippingItem value)  $default,){
final _that = this;
switch (_that) {
case _SaleOrderShippingItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SaleOrderShippingItem value)?  $default,){
final _that = this;
switch (_that) {
case _SaleOrderShippingItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String organizationId,  String shippingId,  String saleOrderItemId,  String productId,  double quantity,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SaleOrderShippingItem() when $default != null:
return $default(_that.id,_that.organizationId,_that.shippingId,_that.saleOrderItemId,_that.productId,_that.quantity,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String organizationId,  String shippingId,  String saleOrderItemId,  String productId,  double quantity,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _SaleOrderShippingItem():
return $default(_that.id,_that.organizationId,_that.shippingId,_that.saleOrderItemId,_that.productId,_that.quantity,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String organizationId,  String shippingId,  String saleOrderItemId,  String productId,  double quantity,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _SaleOrderShippingItem() when $default != null:
return $default(_that.id,_that.organizationId,_that.shippingId,_that.saleOrderItemId,_that.productId,_that.quantity,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _SaleOrderShippingItem implements SaleOrderShippingItem {
  const _SaleOrderShippingItem({required this.id, required this.organizationId, required this.shippingId, required this.saleOrderItemId, required this.productId, required this.quantity, required this.createdAt});
  

@override final  String id;
@override final  String organizationId;
@override final  String shippingId;
@override final  String saleOrderItemId;
@override final  String productId;
@override final  double quantity;
@override final  DateTime createdAt;

/// Create a copy of SaleOrderShippingItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SaleOrderShippingItemCopyWith<_SaleOrderShippingItem> get copyWith => __$SaleOrderShippingItemCopyWithImpl<_SaleOrderShippingItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SaleOrderShippingItem&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.shippingId, shippingId) || other.shippingId == shippingId)&&(identical(other.saleOrderItemId, saleOrderItemId) || other.saleOrderItemId == saleOrderItemId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,organizationId,shippingId,saleOrderItemId,productId,quantity,createdAt);

@override
String toString() {
  return 'SaleOrderShippingItem(id: $id, organizationId: $organizationId, shippingId: $shippingId, saleOrderItemId: $saleOrderItemId, productId: $productId, quantity: $quantity, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$SaleOrderShippingItemCopyWith<$Res> implements $SaleOrderShippingItemCopyWith<$Res> {
  factory _$SaleOrderShippingItemCopyWith(_SaleOrderShippingItem value, $Res Function(_SaleOrderShippingItem) _then) = __$SaleOrderShippingItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String organizationId, String shippingId, String saleOrderItemId, String productId, double quantity, DateTime createdAt
});




}
/// @nodoc
class __$SaleOrderShippingItemCopyWithImpl<$Res>
    implements _$SaleOrderShippingItemCopyWith<$Res> {
  __$SaleOrderShippingItemCopyWithImpl(this._self, this._then);

  final _SaleOrderShippingItem _self;
  final $Res Function(_SaleOrderShippingItem) _then;

/// Create a copy of SaleOrderShippingItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? shippingId = null,Object? saleOrderItemId = null,Object? productId = null,Object? quantity = null,Object? createdAt = null,}) {
  return _then(_SaleOrderShippingItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,shippingId: null == shippingId ? _self.shippingId : shippingId // ignore: cast_nullable_to_non_nullable
as String,saleOrderItemId: null == saleOrderItemId ? _self.saleOrderItemId : saleOrderItemId // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
mixin _$SalePaymentListItem {

 String get id; String get organizationId; String get saleOrderId; String get paymentNumber; double get amount; PaymentMethod get method; PaymentRecordStatus get status; DateTime get paymentDate; bool get isActive; DateTime get createdAt; DateTime get updatedAt; String get soNumber; String get customerId;
/// Create a copy of SalePaymentListItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SalePaymentListItemCopyWith<SalePaymentListItem> get copyWith => _$SalePaymentListItemCopyWithImpl<SalePaymentListItem>(this as SalePaymentListItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SalePaymentListItem&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.saleOrderId, saleOrderId) || other.saleOrderId == saleOrderId)&&(identical(other.paymentNumber, paymentNumber) || other.paymentNumber == paymentNumber)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.method, method) || other.method == method)&&(identical(other.status, status) || other.status == status)&&(identical(other.paymentDate, paymentDate) || other.paymentDate == paymentDate)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.soNumber, soNumber) || other.soNumber == soNumber)&&(identical(other.customerId, customerId) || other.customerId == customerId));
}


@override
int get hashCode => Object.hash(runtimeType,id,organizationId,saleOrderId,paymentNumber,amount,method,status,paymentDate,isActive,createdAt,updatedAt,soNumber,customerId);

@override
String toString() {
  return 'SalePaymentListItem(id: $id, organizationId: $organizationId, saleOrderId: $saleOrderId, paymentNumber: $paymentNumber, amount: $amount, method: $method, status: $status, paymentDate: $paymentDate, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, soNumber: $soNumber, customerId: $customerId)';
}


}

/// @nodoc
abstract mixin class $SalePaymentListItemCopyWith<$Res>  {
  factory $SalePaymentListItemCopyWith(SalePaymentListItem value, $Res Function(SalePaymentListItem) _then) = _$SalePaymentListItemCopyWithImpl;
@useResult
$Res call({
 String id, String organizationId, String saleOrderId, String paymentNumber, double amount, PaymentMethod method, PaymentRecordStatus status, DateTime paymentDate, bool isActive, DateTime createdAt, DateTime updatedAt, String soNumber, String customerId
});




}
/// @nodoc
class _$SalePaymentListItemCopyWithImpl<$Res>
    implements $SalePaymentListItemCopyWith<$Res> {
  _$SalePaymentListItemCopyWithImpl(this._self, this._then);

  final SalePaymentListItem _self;
  final $Res Function(SalePaymentListItem) _then;

/// Create a copy of SalePaymentListItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? saleOrderId = null,Object? paymentNumber = null,Object? amount = null,Object? method = null,Object? status = null,Object? paymentDate = null,Object? isActive = null,Object? createdAt = null,Object? updatedAt = null,Object? soNumber = null,Object? customerId = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,saleOrderId: null == saleOrderId ? _self.saleOrderId : saleOrderId // ignore: cast_nullable_to_non_nullable
as String,paymentNumber: null == paymentNumber ? _self.paymentNumber : paymentNumber // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as PaymentMethod,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PaymentRecordStatus,paymentDate: null == paymentDate ? _self.paymentDate : paymentDate // ignore: cast_nullable_to_non_nullable
as DateTime,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,soNumber: null == soNumber ? _self.soNumber : soNumber // ignore: cast_nullable_to_non_nullable
as String,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SalePaymentListItem].
extension SalePaymentListItemPatterns on SalePaymentListItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SalePaymentListItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SalePaymentListItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SalePaymentListItem value)  $default,){
final _that = this;
switch (_that) {
case _SalePaymentListItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SalePaymentListItem value)?  $default,){
final _that = this;
switch (_that) {
case _SalePaymentListItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String organizationId,  String saleOrderId,  String paymentNumber,  double amount,  PaymentMethod method,  PaymentRecordStatus status,  DateTime paymentDate,  bool isActive,  DateTime createdAt,  DateTime updatedAt,  String soNumber,  String customerId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SalePaymentListItem() when $default != null:
return $default(_that.id,_that.organizationId,_that.saleOrderId,_that.paymentNumber,_that.amount,_that.method,_that.status,_that.paymentDate,_that.isActive,_that.createdAt,_that.updatedAt,_that.soNumber,_that.customerId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String organizationId,  String saleOrderId,  String paymentNumber,  double amount,  PaymentMethod method,  PaymentRecordStatus status,  DateTime paymentDate,  bool isActive,  DateTime createdAt,  DateTime updatedAt,  String soNumber,  String customerId)  $default,) {final _that = this;
switch (_that) {
case _SalePaymentListItem():
return $default(_that.id,_that.organizationId,_that.saleOrderId,_that.paymentNumber,_that.amount,_that.method,_that.status,_that.paymentDate,_that.isActive,_that.createdAt,_that.updatedAt,_that.soNumber,_that.customerId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String organizationId,  String saleOrderId,  String paymentNumber,  double amount,  PaymentMethod method,  PaymentRecordStatus status,  DateTime paymentDate,  bool isActive,  DateTime createdAt,  DateTime updatedAt,  String soNumber,  String customerId)?  $default,) {final _that = this;
switch (_that) {
case _SalePaymentListItem() when $default != null:
return $default(_that.id,_that.organizationId,_that.saleOrderId,_that.paymentNumber,_that.amount,_that.method,_that.status,_that.paymentDate,_that.isActive,_that.createdAt,_that.updatedAt,_that.soNumber,_that.customerId);case _:
  return null;

}
}

}

/// @nodoc


class _SalePaymentListItem implements SalePaymentListItem {
  const _SalePaymentListItem({required this.id, required this.organizationId, required this.saleOrderId, required this.paymentNumber, required this.amount, required this.method, required this.status, required this.paymentDate, required this.isActive, required this.createdAt, required this.updatedAt, required this.soNumber, required this.customerId});
  

@override final  String id;
@override final  String organizationId;
@override final  String saleOrderId;
@override final  String paymentNumber;
@override final  double amount;
@override final  PaymentMethod method;
@override final  PaymentRecordStatus status;
@override final  DateTime paymentDate;
@override final  bool isActive;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  String soNumber;
@override final  String customerId;

/// Create a copy of SalePaymentListItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SalePaymentListItemCopyWith<_SalePaymentListItem> get copyWith => __$SalePaymentListItemCopyWithImpl<_SalePaymentListItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SalePaymentListItem&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.saleOrderId, saleOrderId) || other.saleOrderId == saleOrderId)&&(identical(other.paymentNumber, paymentNumber) || other.paymentNumber == paymentNumber)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.method, method) || other.method == method)&&(identical(other.status, status) || other.status == status)&&(identical(other.paymentDate, paymentDate) || other.paymentDate == paymentDate)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.soNumber, soNumber) || other.soNumber == soNumber)&&(identical(other.customerId, customerId) || other.customerId == customerId));
}


@override
int get hashCode => Object.hash(runtimeType,id,organizationId,saleOrderId,paymentNumber,amount,method,status,paymentDate,isActive,createdAt,updatedAt,soNumber,customerId);

@override
String toString() {
  return 'SalePaymentListItem(id: $id, organizationId: $organizationId, saleOrderId: $saleOrderId, paymentNumber: $paymentNumber, amount: $amount, method: $method, status: $status, paymentDate: $paymentDate, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, soNumber: $soNumber, customerId: $customerId)';
}


}

/// @nodoc
abstract mixin class _$SalePaymentListItemCopyWith<$Res> implements $SalePaymentListItemCopyWith<$Res> {
  factory _$SalePaymentListItemCopyWith(_SalePaymentListItem value, $Res Function(_SalePaymentListItem) _then) = __$SalePaymentListItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String organizationId, String saleOrderId, String paymentNumber, double amount, PaymentMethod method, PaymentRecordStatus status, DateTime paymentDate, bool isActive, DateTime createdAt, DateTime updatedAt, String soNumber, String customerId
});




}
/// @nodoc
class __$SalePaymentListItemCopyWithImpl<$Res>
    implements _$SalePaymentListItemCopyWith<$Res> {
  __$SalePaymentListItemCopyWithImpl(this._self, this._then);

  final _SalePaymentListItem _self;
  final $Res Function(_SalePaymentListItem) _then;

/// Create a copy of SalePaymentListItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? saleOrderId = null,Object? paymentNumber = null,Object? amount = null,Object? method = null,Object? status = null,Object? paymentDate = null,Object? isActive = null,Object? createdAt = null,Object? updatedAt = null,Object? soNumber = null,Object? customerId = null,}) {
  return _then(_SalePaymentListItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,saleOrderId: null == saleOrderId ? _self.saleOrderId : saleOrderId // ignore: cast_nullable_to_non_nullable
as String,paymentNumber: null == paymentNumber ? _self.paymentNumber : paymentNumber // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as PaymentMethod,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PaymentRecordStatus,paymentDate: null == paymentDate ? _self.paymentDate : paymentDate // ignore: cast_nullable_to_non_nullable
as DateTime,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,soNumber: null == soNumber ? _self.soNumber : soNumber // ignore: cast_nullable_to_non_nullable
as String,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
