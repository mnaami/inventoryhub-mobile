// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'production_recipe.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProductionRecipe {

 String get id; String get organizationId; String get productId; String get name; String? get description; bool get isActive; bool get isDeleted; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of ProductionRecipe
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductionRecipeCopyWith<ProductionRecipe> get copyWith => _$ProductionRecipeCopyWithImpl<ProductionRecipe>(this as ProductionRecipe, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductionRecipe&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,organizationId,productId,name,description,isActive,isDeleted,createdAt,updatedAt);

@override
String toString() {
  return 'ProductionRecipe(id: $id, organizationId: $organizationId, productId: $productId, name: $name, description: $description, isActive: $isActive, isDeleted: $isDeleted, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ProductionRecipeCopyWith<$Res>  {
  factory $ProductionRecipeCopyWith(ProductionRecipe value, $Res Function(ProductionRecipe) _then) = _$ProductionRecipeCopyWithImpl;
@useResult
$Res call({
 String id, String organizationId, String productId, String name, String? description, bool isActive, bool isDeleted, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$ProductionRecipeCopyWithImpl<$Res>
    implements $ProductionRecipeCopyWith<$Res> {
  _$ProductionRecipeCopyWithImpl(this._self, this._then);

  final ProductionRecipe _self;
  final $Res Function(ProductionRecipe) _then;

/// Create a copy of ProductionRecipe
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? productId = null,Object? name = null,Object? description = freezed,Object? isActive = null,Object? isDeleted = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductionRecipe].
extension ProductionRecipePatterns on ProductionRecipe {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductionRecipe value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductionRecipe() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductionRecipe value)  $default,){
final _that = this;
switch (_that) {
case _ProductionRecipe():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductionRecipe value)?  $default,){
final _that = this;
switch (_that) {
case _ProductionRecipe() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String organizationId,  String productId,  String name,  String? description,  bool isActive,  bool isDeleted,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductionRecipe() when $default != null:
return $default(_that.id,_that.organizationId,_that.productId,_that.name,_that.description,_that.isActive,_that.isDeleted,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String organizationId,  String productId,  String name,  String? description,  bool isActive,  bool isDeleted,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ProductionRecipe():
return $default(_that.id,_that.organizationId,_that.productId,_that.name,_that.description,_that.isActive,_that.isDeleted,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String organizationId,  String productId,  String name,  String? description,  bool isActive,  bool isDeleted,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ProductionRecipe() when $default != null:
return $default(_that.id,_that.organizationId,_that.productId,_that.name,_that.description,_that.isActive,_that.isDeleted,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _ProductionRecipe implements ProductionRecipe {
  const _ProductionRecipe({required this.id, required this.organizationId, required this.productId, required this.name, this.description, required this.isActive, required this.isDeleted, required this.createdAt, required this.updatedAt});
  

@override final  String id;
@override final  String organizationId;
@override final  String productId;
@override final  String name;
@override final  String? description;
@override final  bool isActive;
@override final  bool isDeleted;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of ProductionRecipe
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductionRecipeCopyWith<_ProductionRecipe> get copyWith => __$ProductionRecipeCopyWithImpl<_ProductionRecipe>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductionRecipe&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,organizationId,productId,name,description,isActive,isDeleted,createdAt,updatedAt);

@override
String toString() {
  return 'ProductionRecipe(id: $id, organizationId: $organizationId, productId: $productId, name: $name, description: $description, isActive: $isActive, isDeleted: $isDeleted, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ProductionRecipeCopyWith<$Res> implements $ProductionRecipeCopyWith<$Res> {
  factory _$ProductionRecipeCopyWith(_ProductionRecipe value, $Res Function(_ProductionRecipe) _then) = __$ProductionRecipeCopyWithImpl;
@override @useResult
$Res call({
 String id, String organizationId, String productId, String name, String? description, bool isActive, bool isDeleted, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$ProductionRecipeCopyWithImpl<$Res>
    implements _$ProductionRecipeCopyWith<$Res> {
  __$ProductionRecipeCopyWithImpl(this._self, this._then);

  final _ProductionRecipe _self;
  final $Res Function(_ProductionRecipe) _then;

/// Create a copy of ProductionRecipe
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? productId = null,Object? name = null,Object? description = freezed,Object? isActive = null,Object? isDeleted = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_ProductionRecipe(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
mixin _$ProductionRecipeItem {

 String get id; String get recipeId; String get ingredientProductId; double get quantityPerUnit; String get unit; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of ProductionRecipeItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductionRecipeItemCopyWith<ProductionRecipeItem> get copyWith => _$ProductionRecipeItemCopyWithImpl<ProductionRecipeItem>(this as ProductionRecipeItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductionRecipeItem&&(identical(other.id, id) || other.id == id)&&(identical(other.recipeId, recipeId) || other.recipeId == recipeId)&&(identical(other.ingredientProductId, ingredientProductId) || other.ingredientProductId == ingredientProductId)&&(identical(other.quantityPerUnit, quantityPerUnit) || other.quantityPerUnit == quantityPerUnit)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,recipeId,ingredientProductId,quantityPerUnit,unit,createdAt,updatedAt);

@override
String toString() {
  return 'ProductionRecipeItem(id: $id, recipeId: $recipeId, ingredientProductId: $ingredientProductId, quantityPerUnit: $quantityPerUnit, unit: $unit, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ProductionRecipeItemCopyWith<$Res>  {
  factory $ProductionRecipeItemCopyWith(ProductionRecipeItem value, $Res Function(ProductionRecipeItem) _then) = _$ProductionRecipeItemCopyWithImpl;
@useResult
$Res call({
 String id, String recipeId, String ingredientProductId, double quantityPerUnit, String unit, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$ProductionRecipeItemCopyWithImpl<$Res>
    implements $ProductionRecipeItemCopyWith<$Res> {
  _$ProductionRecipeItemCopyWithImpl(this._self, this._then);

  final ProductionRecipeItem _self;
  final $Res Function(ProductionRecipeItem) _then;

/// Create a copy of ProductionRecipeItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? recipeId = null,Object? ingredientProductId = null,Object? quantityPerUnit = null,Object? unit = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,recipeId: null == recipeId ? _self.recipeId : recipeId // ignore: cast_nullable_to_non_nullable
as String,ingredientProductId: null == ingredientProductId ? _self.ingredientProductId : ingredientProductId // ignore: cast_nullable_to_non_nullable
as String,quantityPerUnit: null == quantityPerUnit ? _self.quantityPerUnit : quantityPerUnit // ignore: cast_nullable_to_non_nullable
as double,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductionRecipeItem].
extension ProductionRecipeItemPatterns on ProductionRecipeItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductionRecipeItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductionRecipeItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductionRecipeItem value)  $default,){
final _that = this;
switch (_that) {
case _ProductionRecipeItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductionRecipeItem value)?  $default,){
final _that = this;
switch (_that) {
case _ProductionRecipeItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String recipeId,  String ingredientProductId,  double quantityPerUnit,  String unit,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductionRecipeItem() when $default != null:
return $default(_that.id,_that.recipeId,_that.ingredientProductId,_that.quantityPerUnit,_that.unit,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String recipeId,  String ingredientProductId,  double quantityPerUnit,  String unit,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ProductionRecipeItem():
return $default(_that.id,_that.recipeId,_that.ingredientProductId,_that.quantityPerUnit,_that.unit,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String recipeId,  String ingredientProductId,  double quantityPerUnit,  String unit,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ProductionRecipeItem() when $default != null:
return $default(_that.id,_that.recipeId,_that.ingredientProductId,_that.quantityPerUnit,_that.unit,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _ProductionRecipeItem implements ProductionRecipeItem {
  const _ProductionRecipeItem({required this.id, required this.recipeId, required this.ingredientProductId, required this.quantityPerUnit, required this.unit, required this.createdAt, required this.updatedAt});
  

@override final  String id;
@override final  String recipeId;
@override final  String ingredientProductId;
@override final  double quantityPerUnit;
@override final  String unit;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of ProductionRecipeItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductionRecipeItemCopyWith<_ProductionRecipeItem> get copyWith => __$ProductionRecipeItemCopyWithImpl<_ProductionRecipeItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductionRecipeItem&&(identical(other.id, id) || other.id == id)&&(identical(other.recipeId, recipeId) || other.recipeId == recipeId)&&(identical(other.ingredientProductId, ingredientProductId) || other.ingredientProductId == ingredientProductId)&&(identical(other.quantityPerUnit, quantityPerUnit) || other.quantityPerUnit == quantityPerUnit)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,recipeId,ingredientProductId,quantityPerUnit,unit,createdAt,updatedAt);

@override
String toString() {
  return 'ProductionRecipeItem(id: $id, recipeId: $recipeId, ingredientProductId: $ingredientProductId, quantityPerUnit: $quantityPerUnit, unit: $unit, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ProductionRecipeItemCopyWith<$Res> implements $ProductionRecipeItemCopyWith<$Res> {
  factory _$ProductionRecipeItemCopyWith(_ProductionRecipeItem value, $Res Function(_ProductionRecipeItem) _then) = __$ProductionRecipeItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String recipeId, String ingredientProductId, double quantityPerUnit, String unit, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$ProductionRecipeItemCopyWithImpl<$Res>
    implements _$ProductionRecipeItemCopyWith<$Res> {
  __$ProductionRecipeItemCopyWithImpl(this._self, this._then);

  final _ProductionRecipeItem _self;
  final $Res Function(_ProductionRecipeItem) _then;

/// Create a copy of ProductionRecipeItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? recipeId = null,Object? ingredientProductId = null,Object? quantityPerUnit = null,Object? unit = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_ProductionRecipeItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,recipeId: null == recipeId ? _self.recipeId : recipeId // ignore: cast_nullable_to_non_nullable
as String,ingredientProductId: null == ingredientProductId ? _self.ingredientProductId : ingredientProductId // ignore: cast_nullable_to_non_nullable
as String,quantityPerUnit: null == quantityPerUnit ? _self.quantityPerUnit : quantityPerUnit // ignore: cast_nullable_to_non_nullable
as double,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
