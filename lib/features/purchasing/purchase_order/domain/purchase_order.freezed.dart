// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'purchase_order.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PurchaseOrder {

 String get id; String get organizationId; String get orderNumber; String get supplierId; DateTime get orderDate; DateTime? get expectedDeliveryDate; PurchaseOrderStatus get status; PaymentStatus get paymentStatus; ReceiptStatus get receiptStatus; double get totalAmount; bool get isActive; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of PurchaseOrder
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PurchaseOrderCopyWith<PurchaseOrder> get copyWith => _$PurchaseOrderCopyWithImpl<PurchaseOrder>(this as PurchaseOrder, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PurchaseOrder&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.supplierId, supplierId) || other.supplierId == supplierId)&&(identical(other.orderDate, orderDate) || other.orderDate == orderDate)&&(identical(other.expectedDeliveryDate, expectedDeliveryDate) || other.expectedDeliveryDate == expectedDeliveryDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.paymentStatus, paymentStatus) || other.paymentStatus == paymentStatus)&&(identical(other.receiptStatus, receiptStatus) || other.receiptStatus == receiptStatus)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,organizationId,orderNumber,supplierId,orderDate,expectedDeliveryDate,status,paymentStatus,receiptStatus,totalAmount,isActive,createdAt,updatedAt);

@override
String toString() {
  return 'PurchaseOrder(id: $id, organizationId: $organizationId, orderNumber: $orderNumber, supplierId: $supplierId, orderDate: $orderDate, expectedDeliveryDate: $expectedDeliveryDate, status: $status, paymentStatus: $paymentStatus, receiptStatus: $receiptStatus, totalAmount: $totalAmount, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $PurchaseOrderCopyWith<$Res>  {
  factory $PurchaseOrderCopyWith(PurchaseOrder value, $Res Function(PurchaseOrder) _then) = _$PurchaseOrderCopyWithImpl;
@useResult
$Res call({
 String id, String organizationId, String orderNumber, String supplierId, DateTime orderDate, DateTime? expectedDeliveryDate, PurchaseOrderStatus status, PaymentStatus paymentStatus, ReceiptStatus receiptStatus, double totalAmount, bool isActive, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$PurchaseOrderCopyWithImpl<$Res>
    implements $PurchaseOrderCopyWith<$Res> {
  _$PurchaseOrderCopyWithImpl(this._self, this._then);

  final PurchaseOrder _self;
  final $Res Function(PurchaseOrder) _then;

/// Create a copy of PurchaseOrder
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? orderNumber = null,Object? supplierId = null,Object? orderDate = null,Object? expectedDeliveryDate = freezed,Object? status = null,Object? paymentStatus = null,Object? receiptStatus = null,Object? totalAmount = null,Object? isActive = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as String,supplierId: null == supplierId ? _self.supplierId : supplierId // ignore: cast_nullable_to_non_nullable
as String,orderDate: null == orderDate ? _self.orderDate : orderDate // ignore: cast_nullable_to_non_nullable
as DateTime,expectedDeliveryDate: freezed == expectedDeliveryDate ? _self.expectedDeliveryDate : expectedDeliveryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PurchaseOrderStatus,paymentStatus: null == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as PaymentStatus,receiptStatus: null == receiptStatus ? _self.receiptStatus : receiptStatus // ignore: cast_nullable_to_non_nullable
as ReceiptStatus,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PurchaseOrder].
extension PurchaseOrderPatterns on PurchaseOrder {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PurchaseOrder value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PurchaseOrder() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PurchaseOrder value)  $default,){
final _that = this;
switch (_that) {
case _PurchaseOrder():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PurchaseOrder value)?  $default,){
final _that = this;
switch (_that) {
case _PurchaseOrder() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String organizationId,  String orderNumber,  String supplierId,  DateTime orderDate,  DateTime? expectedDeliveryDate,  PurchaseOrderStatus status,  PaymentStatus paymentStatus,  ReceiptStatus receiptStatus,  double totalAmount,  bool isActive,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PurchaseOrder() when $default != null:
return $default(_that.id,_that.organizationId,_that.orderNumber,_that.supplierId,_that.orderDate,_that.expectedDeliveryDate,_that.status,_that.paymentStatus,_that.receiptStatus,_that.totalAmount,_that.isActive,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String organizationId,  String orderNumber,  String supplierId,  DateTime orderDate,  DateTime? expectedDeliveryDate,  PurchaseOrderStatus status,  PaymentStatus paymentStatus,  ReceiptStatus receiptStatus,  double totalAmount,  bool isActive,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _PurchaseOrder():
return $default(_that.id,_that.organizationId,_that.orderNumber,_that.supplierId,_that.orderDate,_that.expectedDeliveryDate,_that.status,_that.paymentStatus,_that.receiptStatus,_that.totalAmount,_that.isActive,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String organizationId,  String orderNumber,  String supplierId,  DateTime orderDate,  DateTime? expectedDeliveryDate,  PurchaseOrderStatus status,  PaymentStatus paymentStatus,  ReceiptStatus receiptStatus,  double totalAmount,  bool isActive,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _PurchaseOrder() when $default != null:
return $default(_that.id,_that.organizationId,_that.orderNumber,_that.supplierId,_that.orderDate,_that.expectedDeliveryDate,_that.status,_that.paymentStatus,_that.receiptStatus,_that.totalAmount,_that.isActive,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _PurchaseOrder extends PurchaseOrder {
  const _PurchaseOrder({required this.id, required this.organizationId, required this.orderNumber, required this.supplierId, required this.orderDate, this.expectedDeliveryDate, required this.status, required this.paymentStatus, required this.receiptStatus, required this.totalAmount, required this.isActive, required this.createdAt, required this.updatedAt}): super._();
  

@override final  String id;
@override final  String organizationId;
@override final  String orderNumber;
@override final  String supplierId;
@override final  DateTime orderDate;
@override final  DateTime? expectedDeliveryDate;
@override final  PurchaseOrderStatus status;
@override final  PaymentStatus paymentStatus;
@override final  ReceiptStatus receiptStatus;
@override final  double totalAmount;
@override final  bool isActive;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of PurchaseOrder
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PurchaseOrderCopyWith<_PurchaseOrder> get copyWith => __$PurchaseOrderCopyWithImpl<_PurchaseOrder>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PurchaseOrder&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.supplierId, supplierId) || other.supplierId == supplierId)&&(identical(other.orderDate, orderDate) || other.orderDate == orderDate)&&(identical(other.expectedDeliveryDate, expectedDeliveryDate) || other.expectedDeliveryDate == expectedDeliveryDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.paymentStatus, paymentStatus) || other.paymentStatus == paymentStatus)&&(identical(other.receiptStatus, receiptStatus) || other.receiptStatus == receiptStatus)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,organizationId,orderNumber,supplierId,orderDate,expectedDeliveryDate,status,paymentStatus,receiptStatus,totalAmount,isActive,createdAt,updatedAt);

@override
String toString() {
  return 'PurchaseOrder(id: $id, organizationId: $organizationId, orderNumber: $orderNumber, supplierId: $supplierId, orderDate: $orderDate, expectedDeliveryDate: $expectedDeliveryDate, status: $status, paymentStatus: $paymentStatus, receiptStatus: $receiptStatus, totalAmount: $totalAmount, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$PurchaseOrderCopyWith<$Res> implements $PurchaseOrderCopyWith<$Res> {
  factory _$PurchaseOrderCopyWith(_PurchaseOrder value, $Res Function(_PurchaseOrder) _then) = __$PurchaseOrderCopyWithImpl;
@override @useResult
$Res call({
 String id, String organizationId, String orderNumber, String supplierId, DateTime orderDate, DateTime? expectedDeliveryDate, PurchaseOrderStatus status, PaymentStatus paymentStatus, ReceiptStatus receiptStatus, double totalAmount, bool isActive, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$PurchaseOrderCopyWithImpl<$Res>
    implements _$PurchaseOrderCopyWith<$Res> {
  __$PurchaseOrderCopyWithImpl(this._self, this._then);

  final _PurchaseOrder _self;
  final $Res Function(_PurchaseOrder) _then;

/// Create a copy of PurchaseOrder
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? orderNumber = null,Object? supplierId = null,Object? orderDate = null,Object? expectedDeliveryDate = freezed,Object? status = null,Object? paymentStatus = null,Object? receiptStatus = null,Object? totalAmount = null,Object? isActive = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_PurchaseOrder(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as String,supplierId: null == supplierId ? _self.supplierId : supplierId // ignore: cast_nullable_to_non_nullable
as String,orderDate: null == orderDate ? _self.orderDate : orderDate // ignore: cast_nullable_to_non_nullable
as DateTime,expectedDeliveryDate: freezed == expectedDeliveryDate ? _self.expectedDeliveryDate : expectedDeliveryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PurchaseOrderStatus,paymentStatus: null == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as PaymentStatus,receiptStatus: null == receiptStatus ? _self.receiptStatus : receiptStatus // ignore: cast_nullable_to_non_nullable
as ReceiptStatus,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
mixin _$PurchaseOrderItem {

 String get id; String get organizationId; String get purchaseOrderId; String get productId; String get productName; double get quantity; double get unitPrice; double get totalPrice; double get receivedQuantity; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of PurchaseOrderItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PurchaseOrderItemCopyWith<PurchaseOrderItem> get copyWith => _$PurchaseOrderItemCopyWithImpl<PurchaseOrderItem>(this as PurchaseOrderItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PurchaseOrderItem&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.purchaseOrderId, purchaseOrderId) || other.purchaseOrderId == purchaseOrderId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.totalPrice, totalPrice) || other.totalPrice == totalPrice)&&(identical(other.receivedQuantity, receivedQuantity) || other.receivedQuantity == receivedQuantity)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,organizationId,purchaseOrderId,productId,productName,quantity,unitPrice,totalPrice,receivedQuantity,createdAt,updatedAt);

@override
String toString() {
  return 'PurchaseOrderItem(id: $id, organizationId: $organizationId, purchaseOrderId: $purchaseOrderId, productId: $productId, productName: $productName, quantity: $quantity, unitPrice: $unitPrice, totalPrice: $totalPrice, receivedQuantity: $receivedQuantity, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $PurchaseOrderItemCopyWith<$Res>  {
  factory $PurchaseOrderItemCopyWith(PurchaseOrderItem value, $Res Function(PurchaseOrderItem) _then) = _$PurchaseOrderItemCopyWithImpl;
@useResult
$Res call({
 String id, String organizationId, String purchaseOrderId, String productId, String productName, double quantity, double unitPrice, double totalPrice, double receivedQuantity, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$PurchaseOrderItemCopyWithImpl<$Res>
    implements $PurchaseOrderItemCopyWith<$Res> {
  _$PurchaseOrderItemCopyWithImpl(this._self, this._then);

  final PurchaseOrderItem _self;
  final $Res Function(PurchaseOrderItem) _then;

/// Create a copy of PurchaseOrderItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? purchaseOrderId = null,Object? productId = null,Object? productName = null,Object? quantity = null,Object? unitPrice = null,Object? totalPrice = null,Object? receivedQuantity = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,purchaseOrderId: null == purchaseOrderId ? _self.purchaseOrderId : purchaseOrderId // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,totalPrice: null == totalPrice ? _self.totalPrice : totalPrice // ignore: cast_nullable_to_non_nullable
as double,receivedQuantity: null == receivedQuantity ? _self.receivedQuantity : receivedQuantity // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PurchaseOrderItem].
extension PurchaseOrderItemPatterns on PurchaseOrderItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PurchaseOrderItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PurchaseOrderItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PurchaseOrderItem value)  $default,){
final _that = this;
switch (_that) {
case _PurchaseOrderItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PurchaseOrderItem value)?  $default,){
final _that = this;
switch (_that) {
case _PurchaseOrderItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String organizationId,  String purchaseOrderId,  String productId,  String productName,  double quantity,  double unitPrice,  double totalPrice,  double receivedQuantity,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PurchaseOrderItem() when $default != null:
return $default(_that.id,_that.organizationId,_that.purchaseOrderId,_that.productId,_that.productName,_that.quantity,_that.unitPrice,_that.totalPrice,_that.receivedQuantity,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String organizationId,  String purchaseOrderId,  String productId,  String productName,  double quantity,  double unitPrice,  double totalPrice,  double receivedQuantity,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _PurchaseOrderItem():
return $default(_that.id,_that.organizationId,_that.purchaseOrderId,_that.productId,_that.productName,_that.quantity,_that.unitPrice,_that.totalPrice,_that.receivedQuantity,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String organizationId,  String purchaseOrderId,  String productId,  String productName,  double quantity,  double unitPrice,  double totalPrice,  double receivedQuantity,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _PurchaseOrderItem() when $default != null:
return $default(_that.id,_that.organizationId,_that.purchaseOrderId,_that.productId,_that.productName,_that.quantity,_that.unitPrice,_that.totalPrice,_that.receivedQuantity,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _PurchaseOrderItem extends PurchaseOrderItem {
  const _PurchaseOrderItem({required this.id, required this.organizationId, required this.purchaseOrderId, required this.productId, required this.productName, required this.quantity, required this.unitPrice, required this.totalPrice, required this.receivedQuantity, required this.createdAt, required this.updatedAt}): super._();
  

@override final  String id;
@override final  String organizationId;
@override final  String purchaseOrderId;
@override final  String productId;
@override final  String productName;
@override final  double quantity;
@override final  double unitPrice;
@override final  double totalPrice;
@override final  double receivedQuantity;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of PurchaseOrderItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PurchaseOrderItemCopyWith<_PurchaseOrderItem> get copyWith => __$PurchaseOrderItemCopyWithImpl<_PurchaseOrderItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PurchaseOrderItem&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.purchaseOrderId, purchaseOrderId) || other.purchaseOrderId == purchaseOrderId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.totalPrice, totalPrice) || other.totalPrice == totalPrice)&&(identical(other.receivedQuantity, receivedQuantity) || other.receivedQuantity == receivedQuantity)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,organizationId,purchaseOrderId,productId,productName,quantity,unitPrice,totalPrice,receivedQuantity,createdAt,updatedAt);

@override
String toString() {
  return 'PurchaseOrderItem(id: $id, organizationId: $organizationId, purchaseOrderId: $purchaseOrderId, productId: $productId, productName: $productName, quantity: $quantity, unitPrice: $unitPrice, totalPrice: $totalPrice, receivedQuantity: $receivedQuantity, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$PurchaseOrderItemCopyWith<$Res> implements $PurchaseOrderItemCopyWith<$Res> {
  factory _$PurchaseOrderItemCopyWith(_PurchaseOrderItem value, $Res Function(_PurchaseOrderItem) _then) = __$PurchaseOrderItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String organizationId, String purchaseOrderId, String productId, String productName, double quantity, double unitPrice, double totalPrice, double receivedQuantity, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$PurchaseOrderItemCopyWithImpl<$Res>
    implements _$PurchaseOrderItemCopyWith<$Res> {
  __$PurchaseOrderItemCopyWithImpl(this._self, this._then);

  final _PurchaseOrderItem _self;
  final $Res Function(_PurchaseOrderItem) _then;

/// Create a copy of PurchaseOrderItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? purchaseOrderId = null,Object? productId = null,Object? productName = null,Object? quantity = null,Object? unitPrice = null,Object? totalPrice = null,Object? receivedQuantity = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_PurchaseOrderItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,purchaseOrderId: null == purchaseOrderId ? _self.purchaseOrderId : purchaseOrderId // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,totalPrice: null == totalPrice ? _self.totalPrice : totalPrice // ignore: cast_nullable_to_non_nullable
as double,receivedQuantity: null == receivedQuantity ? _self.receivedQuantity : receivedQuantity // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
mixin _$PurchaseOrderReceipt {

 String get id; String get organizationId; String get purchaseOrderId; String get receiptNumber; DateTime get receiptDate; ReceiptDocStatus get status; String? get notes; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of PurchaseOrderReceipt
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PurchaseOrderReceiptCopyWith<PurchaseOrderReceipt> get copyWith => _$PurchaseOrderReceiptCopyWithImpl<PurchaseOrderReceipt>(this as PurchaseOrderReceipt, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PurchaseOrderReceipt&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.purchaseOrderId, purchaseOrderId) || other.purchaseOrderId == purchaseOrderId)&&(identical(other.receiptNumber, receiptNumber) || other.receiptNumber == receiptNumber)&&(identical(other.receiptDate, receiptDate) || other.receiptDate == receiptDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,organizationId,purchaseOrderId,receiptNumber,receiptDate,status,notes,createdAt,updatedAt);

@override
String toString() {
  return 'PurchaseOrderReceipt(id: $id, organizationId: $organizationId, purchaseOrderId: $purchaseOrderId, receiptNumber: $receiptNumber, receiptDate: $receiptDate, status: $status, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $PurchaseOrderReceiptCopyWith<$Res>  {
  factory $PurchaseOrderReceiptCopyWith(PurchaseOrderReceipt value, $Res Function(PurchaseOrderReceipt) _then) = _$PurchaseOrderReceiptCopyWithImpl;
@useResult
$Res call({
 String id, String organizationId, String purchaseOrderId, String receiptNumber, DateTime receiptDate, ReceiptDocStatus status, String? notes, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$PurchaseOrderReceiptCopyWithImpl<$Res>
    implements $PurchaseOrderReceiptCopyWith<$Res> {
  _$PurchaseOrderReceiptCopyWithImpl(this._self, this._then);

  final PurchaseOrderReceipt _self;
  final $Res Function(PurchaseOrderReceipt) _then;

/// Create a copy of PurchaseOrderReceipt
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? purchaseOrderId = null,Object? receiptNumber = null,Object? receiptDate = null,Object? status = null,Object? notes = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,purchaseOrderId: null == purchaseOrderId ? _self.purchaseOrderId : purchaseOrderId // ignore: cast_nullable_to_non_nullable
as String,receiptNumber: null == receiptNumber ? _self.receiptNumber : receiptNumber // ignore: cast_nullable_to_non_nullable
as String,receiptDate: null == receiptDate ? _self.receiptDate : receiptDate // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ReceiptDocStatus,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PurchaseOrderReceipt].
extension PurchaseOrderReceiptPatterns on PurchaseOrderReceipt {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PurchaseOrderReceipt value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PurchaseOrderReceipt() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PurchaseOrderReceipt value)  $default,){
final _that = this;
switch (_that) {
case _PurchaseOrderReceipt():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PurchaseOrderReceipt value)?  $default,){
final _that = this;
switch (_that) {
case _PurchaseOrderReceipt() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String organizationId,  String purchaseOrderId,  String receiptNumber,  DateTime receiptDate,  ReceiptDocStatus status,  String? notes,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PurchaseOrderReceipt() when $default != null:
return $default(_that.id,_that.organizationId,_that.purchaseOrderId,_that.receiptNumber,_that.receiptDate,_that.status,_that.notes,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String organizationId,  String purchaseOrderId,  String receiptNumber,  DateTime receiptDate,  ReceiptDocStatus status,  String? notes,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _PurchaseOrderReceipt():
return $default(_that.id,_that.organizationId,_that.purchaseOrderId,_that.receiptNumber,_that.receiptDate,_that.status,_that.notes,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String organizationId,  String purchaseOrderId,  String receiptNumber,  DateTime receiptDate,  ReceiptDocStatus status,  String? notes,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _PurchaseOrderReceipt() when $default != null:
return $default(_that.id,_that.organizationId,_that.purchaseOrderId,_that.receiptNumber,_that.receiptDate,_that.status,_that.notes,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _PurchaseOrderReceipt implements PurchaseOrderReceipt {
  const _PurchaseOrderReceipt({required this.id, required this.organizationId, required this.purchaseOrderId, required this.receiptNumber, required this.receiptDate, required this.status, this.notes, required this.createdAt, required this.updatedAt});
  

@override final  String id;
@override final  String organizationId;
@override final  String purchaseOrderId;
@override final  String receiptNumber;
@override final  DateTime receiptDate;
@override final  ReceiptDocStatus status;
@override final  String? notes;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of PurchaseOrderReceipt
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PurchaseOrderReceiptCopyWith<_PurchaseOrderReceipt> get copyWith => __$PurchaseOrderReceiptCopyWithImpl<_PurchaseOrderReceipt>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PurchaseOrderReceipt&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.purchaseOrderId, purchaseOrderId) || other.purchaseOrderId == purchaseOrderId)&&(identical(other.receiptNumber, receiptNumber) || other.receiptNumber == receiptNumber)&&(identical(other.receiptDate, receiptDate) || other.receiptDate == receiptDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,organizationId,purchaseOrderId,receiptNumber,receiptDate,status,notes,createdAt,updatedAt);

@override
String toString() {
  return 'PurchaseOrderReceipt(id: $id, organizationId: $organizationId, purchaseOrderId: $purchaseOrderId, receiptNumber: $receiptNumber, receiptDate: $receiptDate, status: $status, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$PurchaseOrderReceiptCopyWith<$Res> implements $PurchaseOrderReceiptCopyWith<$Res> {
  factory _$PurchaseOrderReceiptCopyWith(_PurchaseOrderReceipt value, $Res Function(_PurchaseOrderReceipt) _then) = __$PurchaseOrderReceiptCopyWithImpl;
@override @useResult
$Res call({
 String id, String organizationId, String purchaseOrderId, String receiptNumber, DateTime receiptDate, ReceiptDocStatus status, String? notes, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$PurchaseOrderReceiptCopyWithImpl<$Res>
    implements _$PurchaseOrderReceiptCopyWith<$Res> {
  __$PurchaseOrderReceiptCopyWithImpl(this._self, this._then);

  final _PurchaseOrderReceipt _self;
  final $Res Function(_PurchaseOrderReceipt) _then;

/// Create a copy of PurchaseOrderReceipt
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? purchaseOrderId = null,Object? receiptNumber = null,Object? receiptDate = null,Object? status = null,Object? notes = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_PurchaseOrderReceipt(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,purchaseOrderId: null == purchaseOrderId ? _self.purchaseOrderId : purchaseOrderId // ignore: cast_nullable_to_non_nullable
as String,receiptNumber: null == receiptNumber ? _self.receiptNumber : receiptNumber // ignore: cast_nullable_to_non_nullable
as String,receiptDate: null == receiptDate ? _self.receiptDate : receiptDate // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ReceiptDocStatus,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
mixin _$PurchaseOrderReceiptItem {

 String get id; String get organizationId; String get receiptId; String get purchaseOrderItemId; String get productId; double get quantity; DateTime get createdAt;
/// Create a copy of PurchaseOrderReceiptItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PurchaseOrderReceiptItemCopyWith<PurchaseOrderReceiptItem> get copyWith => _$PurchaseOrderReceiptItemCopyWithImpl<PurchaseOrderReceiptItem>(this as PurchaseOrderReceiptItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PurchaseOrderReceiptItem&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.receiptId, receiptId) || other.receiptId == receiptId)&&(identical(other.purchaseOrderItemId, purchaseOrderItemId) || other.purchaseOrderItemId == purchaseOrderItemId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,organizationId,receiptId,purchaseOrderItemId,productId,quantity,createdAt);

@override
String toString() {
  return 'PurchaseOrderReceiptItem(id: $id, organizationId: $organizationId, receiptId: $receiptId, purchaseOrderItemId: $purchaseOrderItemId, productId: $productId, quantity: $quantity, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $PurchaseOrderReceiptItemCopyWith<$Res>  {
  factory $PurchaseOrderReceiptItemCopyWith(PurchaseOrderReceiptItem value, $Res Function(PurchaseOrderReceiptItem) _then) = _$PurchaseOrderReceiptItemCopyWithImpl;
@useResult
$Res call({
 String id, String organizationId, String receiptId, String purchaseOrderItemId, String productId, double quantity, DateTime createdAt
});




}
/// @nodoc
class _$PurchaseOrderReceiptItemCopyWithImpl<$Res>
    implements $PurchaseOrderReceiptItemCopyWith<$Res> {
  _$PurchaseOrderReceiptItemCopyWithImpl(this._self, this._then);

  final PurchaseOrderReceiptItem _self;
  final $Res Function(PurchaseOrderReceiptItem) _then;

/// Create a copy of PurchaseOrderReceiptItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? receiptId = null,Object? purchaseOrderItemId = null,Object? productId = null,Object? quantity = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,receiptId: null == receiptId ? _self.receiptId : receiptId // ignore: cast_nullable_to_non_nullable
as String,purchaseOrderItemId: null == purchaseOrderItemId ? _self.purchaseOrderItemId : purchaseOrderItemId // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PurchaseOrderReceiptItem].
extension PurchaseOrderReceiptItemPatterns on PurchaseOrderReceiptItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PurchaseOrderReceiptItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PurchaseOrderReceiptItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PurchaseOrderReceiptItem value)  $default,){
final _that = this;
switch (_that) {
case _PurchaseOrderReceiptItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PurchaseOrderReceiptItem value)?  $default,){
final _that = this;
switch (_that) {
case _PurchaseOrderReceiptItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String organizationId,  String receiptId,  String purchaseOrderItemId,  String productId,  double quantity,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PurchaseOrderReceiptItem() when $default != null:
return $default(_that.id,_that.organizationId,_that.receiptId,_that.purchaseOrderItemId,_that.productId,_that.quantity,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String organizationId,  String receiptId,  String purchaseOrderItemId,  String productId,  double quantity,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _PurchaseOrderReceiptItem():
return $default(_that.id,_that.organizationId,_that.receiptId,_that.purchaseOrderItemId,_that.productId,_that.quantity,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String organizationId,  String receiptId,  String purchaseOrderItemId,  String productId,  double quantity,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _PurchaseOrderReceiptItem() when $default != null:
return $default(_that.id,_that.organizationId,_that.receiptId,_that.purchaseOrderItemId,_that.productId,_that.quantity,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _PurchaseOrderReceiptItem implements PurchaseOrderReceiptItem {
  const _PurchaseOrderReceiptItem({required this.id, required this.organizationId, required this.receiptId, required this.purchaseOrderItemId, required this.productId, required this.quantity, required this.createdAt});
  

@override final  String id;
@override final  String organizationId;
@override final  String receiptId;
@override final  String purchaseOrderItemId;
@override final  String productId;
@override final  double quantity;
@override final  DateTime createdAt;

/// Create a copy of PurchaseOrderReceiptItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PurchaseOrderReceiptItemCopyWith<_PurchaseOrderReceiptItem> get copyWith => __$PurchaseOrderReceiptItemCopyWithImpl<_PurchaseOrderReceiptItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PurchaseOrderReceiptItem&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.receiptId, receiptId) || other.receiptId == receiptId)&&(identical(other.purchaseOrderItemId, purchaseOrderItemId) || other.purchaseOrderItemId == purchaseOrderItemId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,organizationId,receiptId,purchaseOrderItemId,productId,quantity,createdAt);

@override
String toString() {
  return 'PurchaseOrderReceiptItem(id: $id, organizationId: $organizationId, receiptId: $receiptId, purchaseOrderItemId: $purchaseOrderItemId, productId: $productId, quantity: $quantity, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$PurchaseOrderReceiptItemCopyWith<$Res> implements $PurchaseOrderReceiptItemCopyWith<$Res> {
  factory _$PurchaseOrderReceiptItemCopyWith(_PurchaseOrderReceiptItem value, $Res Function(_PurchaseOrderReceiptItem) _then) = __$PurchaseOrderReceiptItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String organizationId, String receiptId, String purchaseOrderItemId, String productId, double quantity, DateTime createdAt
});




}
/// @nodoc
class __$PurchaseOrderReceiptItemCopyWithImpl<$Res>
    implements _$PurchaseOrderReceiptItemCopyWith<$Res> {
  __$PurchaseOrderReceiptItemCopyWithImpl(this._self, this._then);

  final _PurchaseOrderReceiptItem _self;
  final $Res Function(_PurchaseOrderReceiptItem) _then;

/// Create a copy of PurchaseOrderReceiptItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? receiptId = null,Object? purchaseOrderItemId = null,Object? productId = null,Object? quantity = null,Object? createdAt = null,}) {
  return _then(_PurchaseOrderReceiptItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,receiptId: null == receiptId ? _self.receiptId : receiptId // ignore: cast_nullable_to_non_nullable
as String,purchaseOrderItemId: null == purchaseOrderItemId ? _self.purchaseOrderItemId : purchaseOrderItemId // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
mixin _$PurchaseOrderPayment {

 String get id; String get organizationId; String get purchaseOrderId; String get paymentNumber; double get amount; PaymentMethod get method; PaymentDocStatus get status; DateTime get paymentDate; bool get isActive; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of PurchaseOrderPayment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PurchaseOrderPaymentCopyWith<PurchaseOrderPayment> get copyWith => _$PurchaseOrderPaymentCopyWithImpl<PurchaseOrderPayment>(this as PurchaseOrderPayment, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PurchaseOrderPayment&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.purchaseOrderId, purchaseOrderId) || other.purchaseOrderId == purchaseOrderId)&&(identical(other.paymentNumber, paymentNumber) || other.paymentNumber == paymentNumber)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.method, method) || other.method == method)&&(identical(other.status, status) || other.status == status)&&(identical(other.paymentDate, paymentDate) || other.paymentDate == paymentDate)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,organizationId,purchaseOrderId,paymentNumber,amount,method,status,paymentDate,isActive,createdAt,updatedAt);

@override
String toString() {
  return 'PurchaseOrderPayment(id: $id, organizationId: $organizationId, purchaseOrderId: $purchaseOrderId, paymentNumber: $paymentNumber, amount: $amount, method: $method, status: $status, paymentDate: $paymentDate, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $PurchaseOrderPaymentCopyWith<$Res>  {
  factory $PurchaseOrderPaymentCopyWith(PurchaseOrderPayment value, $Res Function(PurchaseOrderPayment) _then) = _$PurchaseOrderPaymentCopyWithImpl;
@useResult
$Res call({
 String id, String organizationId, String purchaseOrderId, String paymentNumber, double amount, PaymentMethod method, PaymentDocStatus status, DateTime paymentDate, bool isActive, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$PurchaseOrderPaymentCopyWithImpl<$Res>
    implements $PurchaseOrderPaymentCopyWith<$Res> {
  _$PurchaseOrderPaymentCopyWithImpl(this._self, this._then);

  final PurchaseOrderPayment _self;
  final $Res Function(PurchaseOrderPayment) _then;

/// Create a copy of PurchaseOrderPayment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? purchaseOrderId = null,Object? paymentNumber = null,Object? amount = null,Object? method = null,Object? status = null,Object? paymentDate = null,Object? isActive = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,purchaseOrderId: null == purchaseOrderId ? _self.purchaseOrderId : purchaseOrderId // ignore: cast_nullable_to_non_nullable
as String,paymentNumber: null == paymentNumber ? _self.paymentNumber : paymentNumber // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as PaymentMethod,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PaymentDocStatus,paymentDate: null == paymentDate ? _self.paymentDate : paymentDate // ignore: cast_nullable_to_non_nullable
as DateTime,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PurchaseOrderPayment].
extension PurchaseOrderPaymentPatterns on PurchaseOrderPayment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PurchaseOrderPayment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PurchaseOrderPayment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PurchaseOrderPayment value)  $default,){
final _that = this;
switch (_that) {
case _PurchaseOrderPayment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PurchaseOrderPayment value)?  $default,){
final _that = this;
switch (_that) {
case _PurchaseOrderPayment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String organizationId,  String purchaseOrderId,  String paymentNumber,  double amount,  PaymentMethod method,  PaymentDocStatus status,  DateTime paymentDate,  bool isActive,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PurchaseOrderPayment() when $default != null:
return $default(_that.id,_that.organizationId,_that.purchaseOrderId,_that.paymentNumber,_that.amount,_that.method,_that.status,_that.paymentDate,_that.isActive,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String organizationId,  String purchaseOrderId,  String paymentNumber,  double amount,  PaymentMethod method,  PaymentDocStatus status,  DateTime paymentDate,  bool isActive,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _PurchaseOrderPayment():
return $default(_that.id,_that.organizationId,_that.purchaseOrderId,_that.paymentNumber,_that.amount,_that.method,_that.status,_that.paymentDate,_that.isActive,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String organizationId,  String purchaseOrderId,  String paymentNumber,  double amount,  PaymentMethod method,  PaymentDocStatus status,  DateTime paymentDate,  bool isActive,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _PurchaseOrderPayment() when $default != null:
return $default(_that.id,_that.organizationId,_that.purchaseOrderId,_that.paymentNumber,_that.amount,_that.method,_that.status,_that.paymentDate,_that.isActive,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _PurchaseOrderPayment implements PurchaseOrderPayment {
  const _PurchaseOrderPayment({required this.id, required this.organizationId, required this.purchaseOrderId, required this.paymentNumber, required this.amount, required this.method, required this.status, required this.paymentDate, required this.isActive, required this.createdAt, required this.updatedAt});
  

@override final  String id;
@override final  String organizationId;
@override final  String purchaseOrderId;
@override final  String paymentNumber;
@override final  double amount;
@override final  PaymentMethod method;
@override final  PaymentDocStatus status;
@override final  DateTime paymentDate;
@override final  bool isActive;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of PurchaseOrderPayment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PurchaseOrderPaymentCopyWith<_PurchaseOrderPayment> get copyWith => __$PurchaseOrderPaymentCopyWithImpl<_PurchaseOrderPayment>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PurchaseOrderPayment&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.purchaseOrderId, purchaseOrderId) || other.purchaseOrderId == purchaseOrderId)&&(identical(other.paymentNumber, paymentNumber) || other.paymentNumber == paymentNumber)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.method, method) || other.method == method)&&(identical(other.status, status) || other.status == status)&&(identical(other.paymentDate, paymentDate) || other.paymentDate == paymentDate)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,organizationId,purchaseOrderId,paymentNumber,amount,method,status,paymentDate,isActive,createdAt,updatedAt);

@override
String toString() {
  return 'PurchaseOrderPayment(id: $id, organizationId: $organizationId, purchaseOrderId: $purchaseOrderId, paymentNumber: $paymentNumber, amount: $amount, method: $method, status: $status, paymentDate: $paymentDate, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$PurchaseOrderPaymentCopyWith<$Res> implements $PurchaseOrderPaymentCopyWith<$Res> {
  factory _$PurchaseOrderPaymentCopyWith(_PurchaseOrderPayment value, $Res Function(_PurchaseOrderPayment) _then) = __$PurchaseOrderPaymentCopyWithImpl;
@override @useResult
$Res call({
 String id, String organizationId, String purchaseOrderId, String paymentNumber, double amount, PaymentMethod method, PaymentDocStatus status, DateTime paymentDate, bool isActive, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$PurchaseOrderPaymentCopyWithImpl<$Res>
    implements _$PurchaseOrderPaymentCopyWith<$Res> {
  __$PurchaseOrderPaymentCopyWithImpl(this._self, this._then);

  final _PurchaseOrderPayment _self;
  final $Res Function(_PurchaseOrderPayment) _then;

/// Create a copy of PurchaseOrderPayment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? purchaseOrderId = null,Object? paymentNumber = null,Object? amount = null,Object? method = null,Object? status = null,Object? paymentDate = null,Object? isActive = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_PurchaseOrderPayment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,purchaseOrderId: null == purchaseOrderId ? _self.purchaseOrderId : purchaseOrderId // ignore: cast_nullable_to_non_nullable
as String,paymentNumber: null == paymentNumber ? _self.paymentNumber : paymentNumber // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as PaymentMethod,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PaymentDocStatus,paymentDate: null == paymentDate ? _self.paymentDate : paymentDate // ignore: cast_nullable_to_non_nullable
as DateTime,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
