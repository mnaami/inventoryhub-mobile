// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'category.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Category {

 String get id; String get organizationId; String get name; String? get parentCategoryId; String? get color; String? get icon; bool get isActive; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of Category
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategoryCopyWith<Category> get copyWith => _$CategoryCopyWithImpl<Category>(this as Category, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Category&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.name, name) || other.name == name)&&(identical(other.parentCategoryId, parentCategoryId) || other.parentCategoryId == parentCategoryId)&&(identical(other.color, color) || other.color == color)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,organizationId,name,parentCategoryId,color,icon,isActive,createdAt,updatedAt);

@override
String toString() {
  return 'Category(id: $id, organizationId: $organizationId, name: $name, parentCategoryId: $parentCategoryId, color: $color, icon: $icon, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $CategoryCopyWith<$Res>  {
  factory $CategoryCopyWith(Category value, $Res Function(Category) _then) = _$CategoryCopyWithImpl;
@useResult
$Res call({
 String id, String organizationId, String name, String? parentCategoryId, String? color, String? icon, bool isActive, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$CategoryCopyWithImpl<$Res>
    implements $CategoryCopyWith<$Res> {
  _$CategoryCopyWithImpl(this._self, this._then);

  final Category _self;
  final $Res Function(Category) _then;

/// Create a copy of Category
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? name = null,Object? parentCategoryId = freezed,Object? color = freezed,Object? icon = freezed,Object? isActive = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,parentCategoryId: freezed == parentCategoryId ? _self.parentCategoryId : parentCategoryId // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Category].
extension CategoryPatterns on Category {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Category value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Category() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Category value)  $default,){
final _that = this;
switch (_that) {
case _Category():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Category value)?  $default,){
final _that = this;
switch (_that) {
case _Category() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String organizationId,  String name,  String? parentCategoryId,  String? color,  String? icon,  bool isActive,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Category() when $default != null:
return $default(_that.id,_that.organizationId,_that.name,_that.parentCategoryId,_that.color,_that.icon,_that.isActive,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String organizationId,  String name,  String? parentCategoryId,  String? color,  String? icon,  bool isActive,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Category():
return $default(_that.id,_that.organizationId,_that.name,_that.parentCategoryId,_that.color,_that.icon,_that.isActive,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String organizationId,  String name,  String? parentCategoryId,  String? color,  String? icon,  bool isActive,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Category() when $default != null:
return $default(_that.id,_that.organizationId,_that.name,_that.parentCategoryId,_that.color,_that.icon,_that.isActive,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _Category implements Category {
  const _Category({required this.id, required this.organizationId, required this.name, this.parentCategoryId, this.color, this.icon, required this.isActive, required this.createdAt, required this.updatedAt});
  

@override final  String id;
@override final  String organizationId;
@override final  String name;
@override final  String? parentCategoryId;
@override final  String? color;
@override final  String? icon;
@override final  bool isActive;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of Category
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategoryCopyWith<_Category> get copyWith => __$CategoryCopyWithImpl<_Category>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Category&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.name, name) || other.name == name)&&(identical(other.parentCategoryId, parentCategoryId) || other.parentCategoryId == parentCategoryId)&&(identical(other.color, color) || other.color == color)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,organizationId,name,parentCategoryId,color,icon,isActive,createdAt,updatedAt);

@override
String toString() {
  return 'Category(id: $id, organizationId: $organizationId, name: $name, parentCategoryId: $parentCategoryId, color: $color, icon: $icon, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$CategoryCopyWith<$Res> implements $CategoryCopyWith<$Res> {
  factory _$CategoryCopyWith(_Category value, $Res Function(_Category) _then) = __$CategoryCopyWithImpl;
@override @useResult
$Res call({
 String id, String organizationId, String name, String? parentCategoryId, String? color, String? icon, bool isActive, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$CategoryCopyWithImpl<$Res>
    implements _$CategoryCopyWith<$Res> {
  __$CategoryCopyWithImpl(this._self, this._then);

  final _Category _self;
  final $Res Function(_Category) _then;

/// Create a copy of Category
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? name = null,Object? parentCategoryId = freezed,Object? color = freezed,Object? icon = freezed,Object? isActive = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_Category(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,parentCategoryId: freezed == parentCategoryId ? _self.parentCategoryId : parentCategoryId // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
mixin _$CategoryNode {

 Category get category; List<CategoryNode> get children;
/// Create a copy of CategoryNode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategoryNodeCopyWith<CategoryNode> get copyWith => _$CategoryNodeCopyWithImpl<CategoryNode>(this as CategoryNode, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategoryNode&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other.children, children));
}


@override
int get hashCode => Object.hash(runtimeType,category,const DeepCollectionEquality().hash(children));

@override
String toString() {
  return 'CategoryNode(category: $category, children: $children)';
}


}

/// @nodoc
abstract mixin class $CategoryNodeCopyWith<$Res>  {
  factory $CategoryNodeCopyWith(CategoryNode value, $Res Function(CategoryNode) _then) = _$CategoryNodeCopyWithImpl;
@useResult
$Res call({
 Category category, List<CategoryNode> children
});


$CategoryCopyWith<$Res> get category;

}
/// @nodoc
class _$CategoryNodeCopyWithImpl<$Res>
    implements $CategoryNodeCopyWith<$Res> {
  _$CategoryNodeCopyWithImpl(this._self, this._then);

  final CategoryNode _self;
  final $Res Function(CategoryNode) _then;

/// Create a copy of CategoryNode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? category = null,Object? children = null,}) {
  return _then(_self.copyWith(
category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category,children: null == children ? _self.children : children // ignore: cast_nullable_to_non_nullable
as List<CategoryNode>,
  ));
}
/// Create a copy of CategoryNode
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CategoryCopyWith<$Res> get category {
  
  return $CategoryCopyWith<$Res>(_self.category, (value) {
    return _then(_self.copyWith(category: value));
  });
}
}


/// Adds pattern-matching-related methods to [CategoryNode].
extension CategoryNodePatterns on CategoryNode {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CategoryNode value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CategoryNode() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CategoryNode value)  $default,){
final _that = this;
switch (_that) {
case _CategoryNode():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CategoryNode value)?  $default,){
final _that = this;
switch (_that) {
case _CategoryNode() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Category category,  List<CategoryNode> children)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CategoryNode() when $default != null:
return $default(_that.category,_that.children);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Category category,  List<CategoryNode> children)  $default,) {final _that = this;
switch (_that) {
case _CategoryNode():
return $default(_that.category,_that.children);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Category category,  List<CategoryNode> children)?  $default,) {final _that = this;
switch (_that) {
case _CategoryNode() when $default != null:
return $default(_that.category,_that.children);case _:
  return null;

}
}

}

/// @nodoc


class _CategoryNode implements CategoryNode {
  const _CategoryNode({required this.category, required final  List<CategoryNode> children}): _children = children;
  

@override final  Category category;
 final  List<CategoryNode> _children;
@override List<CategoryNode> get children {
  if (_children is EqualUnmodifiableListView) return _children;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_children);
}


/// Create a copy of CategoryNode
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategoryNodeCopyWith<_CategoryNode> get copyWith => __$CategoryNodeCopyWithImpl<_CategoryNode>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CategoryNode&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other._children, _children));
}


@override
int get hashCode => Object.hash(runtimeType,category,const DeepCollectionEquality().hash(_children));

@override
String toString() {
  return 'CategoryNode(category: $category, children: $children)';
}


}

/// @nodoc
abstract mixin class _$CategoryNodeCopyWith<$Res> implements $CategoryNodeCopyWith<$Res> {
  factory _$CategoryNodeCopyWith(_CategoryNode value, $Res Function(_CategoryNode) _then) = __$CategoryNodeCopyWithImpl;
@override @useResult
$Res call({
 Category category, List<CategoryNode> children
});


@override $CategoryCopyWith<$Res> get category;

}
/// @nodoc
class __$CategoryNodeCopyWithImpl<$Res>
    implements _$CategoryNodeCopyWith<$Res> {
  __$CategoryNodeCopyWithImpl(this._self, this._then);

  final _CategoryNode _self;
  final $Res Function(_CategoryNode) _then;

/// Create a copy of CategoryNode
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? category = null,Object? children = null,}) {
  return _then(_CategoryNode(
category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category,children: null == children ? _self._children : children // ignore: cast_nullable_to_non_nullable
as List<CategoryNode>,
  ));
}

/// Create a copy of CategoryNode
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CategoryCopyWith<$Res> get category {
  
  return $CategoryCopyWith<$Res>(_self.category, (value) {
    return _then(_self.copyWith(category: value));
  });
}
}

// dart format on
