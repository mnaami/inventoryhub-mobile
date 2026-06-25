// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Product {

 String get id; String get organizationId; String get name; String? get description; String? get categoryId; String get unitId; double get purchasePrice; double get sellingPrice; double get currentStock; double get minimumStock; String? get barcode; String? get imagePath; String? get supplierId; bool get isActive; bool get isSample; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductCopyWith<Product> get copyWith => _$ProductCopyWithImpl<Product>(this as Product, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Product&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.unitId, unitId) || other.unitId == unitId)&&(identical(other.purchasePrice, purchasePrice) || other.purchasePrice == purchasePrice)&&(identical(other.sellingPrice, sellingPrice) || other.sellingPrice == sellingPrice)&&(identical(other.currentStock, currentStock) || other.currentStock == currentStock)&&(identical(other.minimumStock, minimumStock) || other.minimumStock == minimumStock)&&(identical(other.barcode, barcode) || other.barcode == barcode)&&(identical(other.imagePath, imagePath) || other.imagePath == imagePath)&&(identical(other.supplierId, supplierId) || other.supplierId == supplierId)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isSample, isSample) || other.isSample == isSample)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,organizationId,name,description,categoryId,unitId,purchasePrice,sellingPrice,currentStock,minimumStock,barcode,imagePath,supplierId,isActive,isSample,createdAt,updatedAt);

@override
String toString() {
  return 'Product(id: $id, organizationId: $organizationId, name: $name, description: $description, categoryId: $categoryId, unitId: $unitId, purchasePrice: $purchasePrice, sellingPrice: $sellingPrice, currentStock: $currentStock, minimumStock: $minimumStock, barcode: $barcode, imagePath: $imagePath, supplierId: $supplierId, isActive: $isActive, isSample: $isSample, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ProductCopyWith<$Res>  {
  factory $ProductCopyWith(Product value, $Res Function(Product) _then) = _$ProductCopyWithImpl;
@useResult
$Res call({
 String id, String organizationId, String name, String? description, String? categoryId, String unitId, double purchasePrice, double sellingPrice, double currentStock, double minimumStock, String? barcode, String? imagePath, String? supplierId, bool isActive, bool isSample, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$ProductCopyWithImpl<$Res>
    implements $ProductCopyWith<$Res> {
  _$ProductCopyWithImpl(this._self, this._then);

  final Product _self;
  final $Res Function(Product) _then;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? name = null,Object? description = freezed,Object? categoryId = freezed,Object? unitId = null,Object? purchasePrice = null,Object? sellingPrice = null,Object? currentStock = null,Object? minimumStock = null,Object? barcode = freezed,Object? imagePath = freezed,Object? supplierId = freezed,Object? isActive = null,Object? isSample = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,unitId: null == unitId ? _self.unitId : unitId // ignore: cast_nullable_to_non_nullable
as String,purchasePrice: null == purchasePrice ? _self.purchasePrice : purchasePrice // ignore: cast_nullable_to_non_nullable
as double,sellingPrice: null == sellingPrice ? _self.sellingPrice : sellingPrice // ignore: cast_nullable_to_non_nullable
as double,currentStock: null == currentStock ? _self.currentStock : currentStock // ignore: cast_nullable_to_non_nullable
as double,minimumStock: null == minimumStock ? _self.minimumStock : minimumStock // ignore: cast_nullable_to_non_nullable
as double,barcode: freezed == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as String?,imagePath: freezed == imagePath ? _self.imagePath : imagePath // ignore: cast_nullable_to_non_nullable
as String?,supplierId: freezed == supplierId ? _self.supplierId : supplierId // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isSample: null == isSample ? _self.isSample : isSample // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Product].
extension ProductPatterns on Product {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Product value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Product() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Product value)  $default,){
final _that = this;
switch (_that) {
case _Product():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Product value)?  $default,){
final _that = this;
switch (_that) {
case _Product() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String organizationId,  String name,  String? description,  String? categoryId,  String unitId,  double purchasePrice,  double sellingPrice,  double currentStock,  double minimumStock,  String? barcode,  String? imagePath,  String? supplierId,  bool isActive,  bool isSample,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that.id,_that.organizationId,_that.name,_that.description,_that.categoryId,_that.unitId,_that.purchasePrice,_that.sellingPrice,_that.currentStock,_that.minimumStock,_that.barcode,_that.imagePath,_that.supplierId,_that.isActive,_that.isSample,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String organizationId,  String name,  String? description,  String? categoryId,  String unitId,  double purchasePrice,  double sellingPrice,  double currentStock,  double minimumStock,  String? barcode,  String? imagePath,  String? supplierId,  bool isActive,  bool isSample,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Product():
return $default(_that.id,_that.organizationId,_that.name,_that.description,_that.categoryId,_that.unitId,_that.purchasePrice,_that.sellingPrice,_that.currentStock,_that.minimumStock,_that.barcode,_that.imagePath,_that.supplierId,_that.isActive,_that.isSample,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String organizationId,  String name,  String? description,  String? categoryId,  String unitId,  double purchasePrice,  double sellingPrice,  double currentStock,  double minimumStock,  String? barcode,  String? imagePath,  String? supplierId,  bool isActive,  bool isSample,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that.id,_that.organizationId,_that.name,_that.description,_that.categoryId,_that.unitId,_that.purchasePrice,_that.sellingPrice,_that.currentStock,_that.minimumStock,_that.barcode,_that.imagePath,_that.supplierId,_that.isActive,_that.isSample,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _Product extends Product {
  const _Product({required this.id, required this.organizationId, required this.name, this.description, this.categoryId, required this.unitId, required this.purchasePrice, required this.sellingPrice, required this.currentStock, required this.minimumStock, this.barcode, this.imagePath, this.supplierId, required this.isActive, required this.isSample, required this.createdAt, required this.updatedAt}): super._();
  

@override final  String id;
@override final  String organizationId;
@override final  String name;
@override final  String? description;
@override final  String? categoryId;
@override final  String unitId;
@override final  double purchasePrice;
@override final  double sellingPrice;
@override final  double currentStock;
@override final  double minimumStock;
@override final  String? barcode;
@override final  String? imagePath;
@override final  String? supplierId;
@override final  bool isActive;
@override final  bool isSample;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductCopyWith<_Product> get copyWith => __$ProductCopyWithImpl<_Product>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Product&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.unitId, unitId) || other.unitId == unitId)&&(identical(other.purchasePrice, purchasePrice) || other.purchasePrice == purchasePrice)&&(identical(other.sellingPrice, sellingPrice) || other.sellingPrice == sellingPrice)&&(identical(other.currentStock, currentStock) || other.currentStock == currentStock)&&(identical(other.minimumStock, minimumStock) || other.minimumStock == minimumStock)&&(identical(other.barcode, barcode) || other.barcode == barcode)&&(identical(other.imagePath, imagePath) || other.imagePath == imagePath)&&(identical(other.supplierId, supplierId) || other.supplierId == supplierId)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isSample, isSample) || other.isSample == isSample)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,organizationId,name,description,categoryId,unitId,purchasePrice,sellingPrice,currentStock,minimumStock,barcode,imagePath,supplierId,isActive,isSample,createdAt,updatedAt);

@override
String toString() {
  return 'Product(id: $id, organizationId: $organizationId, name: $name, description: $description, categoryId: $categoryId, unitId: $unitId, purchasePrice: $purchasePrice, sellingPrice: $sellingPrice, currentStock: $currentStock, minimumStock: $minimumStock, barcode: $barcode, imagePath: $imagePath, supplierId: $supplierId, isActive: $isActive, isSample: $isSample, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ProductCopyWith<$Res> implements $ProductCopyWith<$Res> {
  factory _$ProductCopyWith(_Product value, $Res Function(_Product) _then) = __$ProductCopyWithImpl;
@override @useResult
$Res call({
 String id, String organizationId, String name, String? description, String? categoryId, String unitId, double purchasePrice, double sellingPrice, double currentStock, double minimumStock, String? barcode, String? imagePath, String? supplierId, bool isActive, bool isSample, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$ProductCopyWithImpl<$Res>
    implements _$ProductCopyWith<$Res> {
  __$ProductCopyWithImpl(this._self, this._then);

  final _Product _self;
  final $Res Function(_Product) _then;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? name = null,Object? description = freezed,Object? categoryId = freezed,Object? unitId = null,Object? purchasePrice = null,Object? sellingPrice = null,Object? currentStock = null,Object? minimumStock = null,Object? barcode = freezed,Object? imagePath = freezed,Object? supplierId = freezed,Object? isActive = null,Object? isSample = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_Product(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,unitId: null == unitId ? _self.unitId : unitId // ignore: cast_nullable_to_non_nullable
as String,purchasePrice: null == purchasePrice ? _self.purchasePrice : purchasePrice // ignore: cast_nullable_to_non_nullable
as double,sellingPrice: null == sellingPrice ? _self.sellingPrice : sellingPrice // ignore: cast_nullable_to_non_nullable
as double,currentStock: null == currentStock ? _self.currentStock : currentStock // ignore: cast_nullable_to_non_nullable
as double,minimumStock: null == minimumStock ? _self.minimumStock : minimumStock // ignore: cast_nullable_to_non_nullable
as double,barcode: freezed == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as String?,imagePath: freezed == imagePath ? _self.imagePath : imagePath // ignore: cast_nullable_to_non_nullable
as String?,supplierId: freezed == supplierId ? _self.supplierId : supplierId // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isSample: null == isSample ? _self.isSample : isSample // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
