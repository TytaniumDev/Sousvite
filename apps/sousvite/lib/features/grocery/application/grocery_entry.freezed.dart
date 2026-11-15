// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'grocery_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GroceryEntry {

/// The normalized name the items were combined by. Stable while the
/// entry exists, so it doubles as the row's key.
 String get key;/// The name shown, as the first item spelled it.
 String get name;/// The items this entry combines, in list order.
 List<GroceryItem> get items;/// The combined amounts, one per unit, in the order units first appear.
 List<GroceryAmount> get amounts;/// The recipes the items came from, without repeats. Empty when every
/// item was added by hand.
 List<RecipeId> get sourceRecipeIds;/// The store section the entry is grouped under, or null for "Other".
 String? get storeSection;
/// Create a copy of GroceryEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroceryEntryCopyWith<GroceryEntry> get copyWith => _$GroceryEntryCopyWithImpl<GroceryEntry>(this as GroceryEntry, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as GroceryEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroceryEntry&&(identical(other.key, _this.key) || other.key == _this.key)&&(identical(other.name, _this.name) || other.name == _this.name)&&const DeepCollectionEquality().equals(other.items, _this.items)&&const DeepCollectionEquality().equals(other.amounts, _this.amounts)&&const DeepCollectionEquality().equals(other.sourceRecipeIds, _this.sourceRecipeIds)&&(identical(other.storeSection, _this.storeSection) || other.storeSection == _this.storeSection));
}


@override
int get hashCode {
  final _this = this as GroceryEntry;
  return Object.hash(runtimeType,_this.key,_this.name,const DeepCollectionEquality().hash(_this.items),const DeepCollectionEquality().hash(_this.amounts),const DeepCollectionEquality().hash(_this.sourceRecipeIds),_this.storeSection);
}

@override
String toString() {
  final _this = this as GroceryEntry;
  return 'GroceryEntry(key: ${_this.key}, name: ${_this.name}, items: ${_this.items}, amounts: ${_this.amounts}, sourceRecipeIds: ${_this.sourceRecipeIds}, storeSection: ${_this.storeSection})';
}


}

/// @nodoc
abstract mixin class $GroceryEntryCopyWith<$Res>  {
  factory $GroceryEntryCopyWith(GroceryEntry value, $Res Function(GroceryEntry) _then) = _$GroceryEntryCopyWithImpl;
@useResult
$Res call({
 String key, String name, List<GroceryItem> items, List<GroceryAmount> amounts, List<RecipeId> sourceRecipeIds, String? storeSection
});




}
/// @nodoc
class _$GroceryEntryCopyWithImpl<$Res>
    implements $GroceryEntryCopyWith<$Res> {
  _$GroceryEntryCopyWithImpl(this._self, this._then);

  final GroceryEntry _self;
  final $Res Function(GroceryEntry) _then;

/// Create a copy of GroceryEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = null,Object? name = null,Object? items = null,Object? amounts = null,Object? sourceRecipeIds = null,Object? storeSection = freezed,}) {
  return _then(GroceryEntry(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<GroceryItem>,amounts: null == amounts ? _self.amounts : amounts // ignore: cast_nullable_to_non_nullable
as List<GroceryAmount>,sourceRecipeIds: null == sourceRecipeIds ? _self.sourceRecipeIds : sourceRecipeIds // ignore: cast_nullable_to_non_nullable
as List<RecipeId>,storeSection: freezed == storeSection ? _self.storeSection : storeSection // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [GroceryEntry].
extension GroceryEntryPatterns on GroceryEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GroceryEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GroceryEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GroceryEntry value)  $default,){
final _that = this;
switch (_that) {
case _GroceryEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GroceryEntry value)?  $default,){
final _that = this;
switch (_that) {
case _GroceryEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String key,  String name,  List<GroceryItem> items,  List<GroceryAmount> amounts,  List<RecipeId> sourceRecipeIds,  String? storeSection)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GroceryEntry() when $default != null:
return $default(_that.key,_that.name,_that.items,_that.amounts,_that.sourceRecipeIds,_that.storeSection);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String key,  String name,  List<GroceryItem> items,  List<GroceryAmount> amounts,  List<RecipeId> sourceRecipeIds,  String? storeSection)  $default,) {final _that = this;
switch (_that) {
case _GroceryEntry():
return $default(_that.key,_that.name,_that.items,_that.amounts,_that.sourceRecipeIds,_that.storeSection);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String key,  String name,  List<GroceryItem> items,  List<GroceryAmount> amounts,  List<RecipeId> sourceRecipeIds,  String? storeSection)?  $default,) {final _that = this;
switch (_that) {
case _GroceryEntry() when $default != null:
return $default(_that.key,_that.name,_that.items,_that.amounts,_that.sourceRecipeIds,_that.storeSection);case _:
  return null;

}
}

}

/// @nodoc


class _GroceryEntry extends GroceryEntry {
  const _GroceryEntry({required this.key, required this.name, required  List<GroceryItem> items, required  List<GroceryAmount> amounts, required  List<RecipeId> sourceRecipeIds, this.storeSection}): _items = items,_amounts = amounts,_sourceRecipeIds = sourceRecipeIds,super._();
  

/// The normalized name the items were combined by. Stable while the
/// entry exists, so it doubles as the row's key.
@override final  String key;
/// The name shown, as the first item spelled it.
@override final  String name;
/// The items this entry combines, in list order.
 final  List<GroceryItem> _items;
/// The items this entry combines, in list order.
@override List<GroceryItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

/// The combined amounts, one per unit, in the order units first appear.
 final  List<GroceryAmount> _amounts;
/// The combined amounts, one per unit, in the order units first appear.
@override List<GroceryAmount> get amounts {
  if (_amounts is EqualUnmodifiableListView) return _amounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_amounts);
}

/// The recipes the items came from, without repeats. Empty when every
/// item was added by hand.
 final  List<RecipeId> _sourceRecipeIds;
/// The recipes the items came from, without repeats. Empty when every
/// item was added by hand.
@override List<RecipeId> get sourceRecipeIds {
  if (_sourceRecipeIds is EqualUnmodifiableListView) return _sourceRecipeIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sourceRecipeIds);
}

/// The store section the entry is grouped under, or null for "Other".
@override final  String? storeSection;

/// Create a copy of GroceryEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroceryEntryCopyWith<_GroceryEntry> get copyWith => __$GroceryEntryCopyWithImpl<_GroceryEntry>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GroceryEntry&&(identical(other.key, key) || other.key == key)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.items, _items)&&const DeepCollectionEquality().equals(other.amounts, _amounts)&&const DeepCollectionEquality().equals(other.sourceRecipeIds, _sourceRecipeIds)&&(identical(other.storeSection, storeSection) || other.storeSection == storeSection));
}


@override
int get hashCode {
    return Object.hash(runtimeType,key,name,const DeepCollectionEquality().hash(_items),const DeepCollectionEquality().hash(_amounts),const DeepCollectionEquality().hash(_sourceRecipeIds),storeSection);
}

@override
String toString() {
    return 'GroceryEntry(key: $key, name: $name, items: $items, amounts: $amounts, sourceRecipeIds: $sourceRecipeIds, storeSection: $storeSection)';
}


}

/// @nodoc
abstract mixin class _$GroceryEntryCopyWith<$Res> implements $GroceryEntryCopyWith<$Res> {
  factory _$GroceryEntryCopyWith(_GroceryEntry value, $Res Function(_GroceryEntry) _then) = __$GroceryEntryCopyWithImpl;
@override @useResult
$Res call({
 String key, String name, List<GroceryItem> items, List<GroceryAmount> amounts, List<RecipeId> sourceRecipeIds, String? storeSection
});




}
/// @nodoc
class __$GroceryEntryCopyWithImpl<$Res>
    implements _$GroceryEntryCopyWith<$Res> {
  __$GroceryEntryCopyWithImpl(this._self, this._then);

  final _GroceryEntry _self;
  final $Res Function(_GroceryEntry) _then;

/// Create a copy of GroceryEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,Object? name = null,Object? items = null,Object? amounts = null,Object? sourceRecipeIds = null,Object? storeSection = freezed,}) {
  return _then(_GroceryEntry(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<GroceryItem>,amounts: null == amounts ? _self._amounts : amounts // ignore: cast_nullable_to_non_nullable
as List<GroceryAmount>,sourceRecipeIds: null == sourceRecipeIds ? _self._sourceRecipeIds : sourceRecipeIds // ignore: cast_nullable_to_non_nullable
as List<RecipeId>,storeSection: freezed == storeSection ? _self.storeSection : storeSection // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$GrocerySection {

/// The store section, or null for entries with none ("Other").
 String? get name;/// Keys of the section's entries, in list order.
 List<String> get entryKeys;
/// Create a copy of GrocerySection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GrocerySectionCopyWith<GrocerySection> get copyWith => _$GrocerySectionCopyWithImpl<GrocerySection>(this as GrocerySection, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as GrocerySection;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GrocerySection&&(identical(other.name, _this.name) || other.name == _this.name)&&const DeepCollectionEquality().equals(other.entryKeys, _this.entryKeys));
}


@override
int get hashCode {
  final _this = this as GrocerySection;
  return Object.hash(runtimeType,_this.name,const DeepCollectionEquality().hash(_this.entryKeys));
}

@override
String toString() {
  final _this = this as GrocerySection;
  return 'GrocerySection(name: ${_this.name}, entryKeys: ${_this.entryKeys})';
}


}

/// @nodoc
abstract mixin class $GrocerySectionCopyWith<$Res>  {
  factory $GrocerySectionCopyWith(GrocerySection value, $Res Function(GrocerySection) _then) = _$GrocerySectionCopyWithImpl;
@useResult
$Res call({
 String? name, List<String> entryKeys
});




}
/// @nodoc
class _$GrocerySectionCopyWithImpl<$Res>
    implements $GrocerySectionCopyWith<$Res> {
  _$GrocerySectionCopyWithImpl(this._self, this._then);

  final GrocerySection _self;
  final $Res Function(GrocerySection) _then;

/// Create a copy of GrocerySection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,Object? entryKeys = null,}) {
  return _then(GrocerySection(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,entryKeys: null == entryKeys ? _self.entryKeys : entryKeys // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [GrocerySection].
extension GrocerySectionPatterns on GrocerySection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GrocerySection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GrocerySection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GrocerySection value)  $default,){
final _that = this;
switch (_that) {
case _GrocerySection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GrocerySection value)?  $default,){
final _that = this;
switch (_that) {
case _GrocerySection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? name,  List<String> entryKeys)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GrocerySection() when $default != null:
return $default(_that.name,_that.entryKeys);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? name,  List<String> entryKeys)  $default,) {final _that = this;
switch (_that) {
case _GrocerySection():
return $default(_that.name,_that.entryKeys);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? name,  List<String> entryKeys)?  $default,) {final _that = this;
switch (_that) {
case _GrocerySection() when $default != null:
return $default(_that.name,_that.entryKeys);case _:
  return null;

}
}

}

/// @nodoc


class _GrocerySection implements GrocerySection {
  const _GrocerySection({required this.name, required  List<String> entryKeys}): _entryKeys = entryKeys;
  

/// The store section, or null for entries with none ("Other").
@override final  String? name;
/// Keys of the section's entries, in list order.
 final  List<String> _entryKeys;
/// Keys of the section's entries, in list order.
@override List<String> get entryKeys {
  if (_entryKeys is EqualUnmodifiableListView) return _entryKeys;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_entryKeys);
}


/// Create a copy of GrocerySection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GrocerySectionCopyWith<_GrocerySection> get copyWith => __$GrocerySectionCopyWithImpl<_GrocerySection>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GrocerySection&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.entryKeys, _entryKeys));
}


@override
int get hashCode {
    return Object.hash(runtimeType,name,const DeepCollectionEquality().hash(_entryKeys));
}

@override
String toString() {
    return 'GrocerySection(name: $name, entryKeys: $entryKeys)';
}


}

/// @nodoc
abstract mixin class _$GrocerySectionCopyWith<$Res> implements $GrocerySectionCopyWith<$Res> {
  factory _$GrocerySectionCopyWith(_GrocerySection value, $Res Function(_GrocerySection) _then) = __$GrocerySectionCopyWithImpl;
@override @useResult
$Res call({
 String? name, List<String> entryKeys
});




}
/// @nodoc
class __$GrocerySectionCopyWithImpl<$Res>
    implements _$GrocerySectionCopyWith<$Res> {
  __$GrocerySectionCopyWithImpl(this._self, this._then);

  final _GrocerySection _self;
  final $Res Function(_GrocerySection) _then;

/// Create a copy of GrocerySection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,Object? entryKeys = null,}) {
  return _then(_GrocerySection(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,entryKeys: null == entryKeys ? _self._entryKeys : entryKeys // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc
mixin _$GroceryLayout {

/// Sections of unchecked entries, in display order.
 List<GrocerySection> get sections;/// Keys of checked entries, in list order.
 List<String> get checkedKeys;
/// Create a copy of GroceryLayout
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroceryLayoutCopyWith<GroceryLayout> get copyWith => _$GroceryLayoutCopyWithImpl<GroceryLayout>(this as GroceryLayout, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as GroceryLayout;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroceryLayout&&const DeepCollectionEquality().equals(other.sections, _this.sections)&&const DeepCollectionEquality().equals(other.checkedKeys, _this.checkedKeys));
}


@override
int get hashCode {
  final _this = this as GroceryLayout;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.sections),const DeepCollectionEquality().hash(_this.checkedKeys));
}

@override
String toString() {
  final _this = this as GroceryLayout;
  return 'GroceryLayout(sections: ${_this.sections}, checkedKeys: ${_this.checkedKeys})';
}


}

/// @nodoc
abstract mixin class $GroceryLayoutCopyWith<$Res>  {
  factory $GroceryLayoutCopyWith(GroceryLayout value, $Res Function(GroceryLayout) _then) = _$GroceryLayoutCopyWithImpl;
@useResult
$Res call({
 List<GrocerySection> sections, List<String> checkedKeys
});




}
/// @nodoc
class _$GroceryLayoutCopyWithImpl<$Res>
    implements $GroceryLayoutCopyWith<$Res> {
  _$GroceryLayoutCopyWithImpl(this._self, this._then);

  final GroceryLayout _self;
  final $Res Function(GroceryLayout) _then;

/// Create a copy of GroceryLayout
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sections = null,Object? checkedKeys = null,}) {
  return _then(GroceryLayout(
sections: null == sections ? _self.sections : sections // ignore: cast_nullable_to_non_nullable
as List<GrocerySection>,checkedKeys: null == checkedKeys ? _self.checkedKeys : checkedKeys // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [GroceryLayout].
extension GroceryLayoutPatterns on GroceryLayout {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GroceryLayout value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GroceryLayout() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GroceryLayout value)  $default,){
final _that = this;
switch (_that) {
case _GroceryLayout():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GroceryLayout value)?  $default,){
final _that = this;
switch (_that) {
case _GroceryLayout() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<GrocerySection> sections,  List<String> checkedKeys)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GroceryLayout() when $default != null:
return $default(_that.sections,_that.checkedKeys);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<GrocerySection> sections,  List<String> checkedKeys)  $default,) {final _that = this;
switch (_that) {
case _GroceryLayout():
return $default(_that.sections,_that.checkedKeys);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<GrocerySection> sections,  List<String> checkedKeys)?  $default,) {final _that = this;
switch (_that) {
case _GroceryLayout() when $default != null:
return $default(_that.sections,_that.checkedKeys);case _:
  return null;

}
}

}

/// @nodoc


class _GroceryLayout implements GroceryLayout {
  const _GroceryLayout({required  List<GrocerySection> sections, required  List<String> checkedKeys}): _sections = sections,_checkedKeys = checkedKeys;
  

/// Sections of unchecked entries, in display order.
 final  List<GrocerySection> _sections;
/// Sections of unchecked entries, in display order.
@override List<GrocerySection> get sections {
  if (_sections is EqualUnmodifiableListView) return _sections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sections);
}

/// Keys of checked entries, in list order.
 final  List<String> _checkedKeys;
/// Keys of checked entries, in list order.
@override List<String> get checkedKeys {
  if (_checkedKeys is EqualUnmodifiableListView) return _checkedKeys;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_checkedKeys);
}


/// Create a copy of GroceryLayout
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroceryLayoutCopyWith<_GroceryLayout> get copyWith => __$GroceryLayoutCopyWithImpl<_GroceryLayout>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GroceryLayout&&const DeepCollectionEquality().equals(other.sections, _sections)&&const DeepCollectionEquality().equals(other.checkedKeys, _checkedKeys));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_sections),const DeepCollectionEquality().hash(_checkedKeys));
}

@override
String toString() {
    return 'GroceryLayout(sections: $sections, checkedKeys: $checkedKeys)';
}


}

/// @nodoc
abstract mixin class _$GroceryLayoutCopyWith<$Res> implements $GroceryLayoutCopyWith<$Res> {
  factory _$GroceryLayoutCopyWith(_GroceryLayout value, $Res Function(_GroceryLayout) _then) = __$GroceryLayoutCopyWithImpl;
@override @useResult
$Res call({
 List<GrocerySection> sections, List<String> checkedKeys
});




}
/// @nodoc
class __$GroceryLayoutCopyWithImpl<$Res>
    implements _$GroceryLayoutCopyWith<$Res> {
  __$GroceryLayoutCopyWithImpl(this._self, this._then);

  final _GroceryLayout _self;
  final $Res Function(_GroceryLayout) _then;

/// Create a copy of GroceryLayout
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sections = null,Object? checkedKeys = null,}) {
  return _then(_GroceryLayout(
sections: null == sections ? _self._sections : sections // ignore: cast_nullable_to_non_nullable
as List<GrocerySection>,checkedKeys: null == checkedKeys ? _self._checkedKeys : checkedKeys // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc
mixin _$GroceryView {

/// Sections of unchecked entries, in display order.
 List<GrocerySection> get sections;/// Keys of checked entries, in list order.
 List<String> get checkedKeys;/// Every entry by its key.
 Map<String, GroceryEntry> get entries;
/// Create a copy of GroceryView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroceryViewCopyWith<GroceryView> get copyWith => _$GroceryViewCopyWithImpl<GroceryView>(this as GroceryView, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as GroceryView;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroceryView&&const DeepCollectionEquality().equals(other.sections, _this.sections)&&const DeepCollectionEquality().equals(other.checkedKeys, _this.checkedKeys)&&const DeepCollectionEquality().equals(other.entries, _this.entries));
}


@override
int get hashCode {
  final _this = this as GroceryView;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.sections),const DeepCollectionEquality().hash(_this.checkedKeys),const DeepCollectionEquality().hash(_this.entries));
}

@override
String toString() {
  final _this = this as GroceryView;
  return 'GroceryView(sections: ${_this.sections}, checkedKeys: ${_this.checkedKeys}, entries: ${_this.entries})';
}


}

/// @nodoc
abstract mixin class $GroceryViewCopyWith<$Res>  {
  factory $GroceryViewCopyWith(GroceryView value, $Res Function(GroceryView) _then) = _$GroceryViewCopyWithImpl;
@useResult
$Res call({
 List<GrocerySection> sections, List<String> checkedKeys, Map<String, GroceryEntry> entries
});




}
/// @nodoc
class _$GroceryViewCopyWithImpl<$Res>
    implements $GroceryViewCopyWith<$Res> {
  _$GroceryViewCopyWithImpl(this._self, this._then);

  final GroceryView _self;
  final $Res Function(GroceryView) _then;

/// Create a copy of GroceryView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sections = null,Object? checkedKeys = null,Object? entries = null,}) {
  return _then(GroceryView(
sections: null == sections ? _self.sections : sections // ignore: cast_nullable_to_non_nullable
as List<GrocerySection>,checkedKeys: null == checkedKeys ? _self.checkedKeys : checkedKeys // ignore: cast_nullable_to_non_nullable
as List<String>,entries: null == entries ? _self.entries : entries // ignore: cast_nullable_to_non_nullable
as Map<String, GroceryEntry>,
  ));
}

}


/// Adds pattern-matching-related methods to [GroceryView].
extension GroceryViewPatterns on GroceryView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GroceryView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GroceryView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GroceryView value)  $default,){
final _that = this;
switch (_that) {
case _GroceryView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GroceryView value)?  $default,){
final _that = this;
switch (_that) {
case _GroceryView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<GrocerySection> sections,  List<String> checkedKeys,  Map<String, GroceryEntry> entries)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GroceryView() when $default != null:
return $default(_that.sections,_that.checkedKeys,_that.entries);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<GrocerySection> sections,  List<String> checkedKeys,  Map<String, GroceryEntry> entries)  $default,) {final _that = this;
switch (_that) {
case _GroceryView():
return $default(_that.sections,_that.checkedKeys,_that.entries);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<GrocerySection> sections,  List<String> checkedKeys,  Map<String, GroceryEntry> entries)?  $default,) {final _that = this;
switch (_that) {
case _GroceryView() when $default != null:
return $default(_that.sections,_that.checkedKeys,_that.entries);case _:
  return null;

}
}

}

/// @nodoc


class _GroceryView extends GroceryView {
  const _GroceryView({required  List<GrocerySection> sections, required  List<String> checkedKeys, required  Map<String, GroceryEntry> entries}): _sections = sections,_checkedKeys = checkedKeys,_entries = entries,super._();
  

/// Sections of unchecked entries, in display order.
 final  List<GrocerySection> _sections;
/// Sections of unchecked entries, in display order.
@override List<GrocerySection> get sections {
  if (_sections is EqualUnmodifiableListView) return _sections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sections);
}

/// Keys of checked entries, in list order.
 final  List<String> _checkedKeys;
/// Keys of checked entries, in list order.
@override List<String> get checkedKeys {
  if (_checkedKeys is EqualUnmodifiableListView) return _checkedKeys;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_checkedKeys);
}

/// Every entry by its key.
 final  Map<String, GroceryEntry> _entries;
/// Every entry by its key.
@override Map<String, GroceryEntry> get entries {
  if (_entries is EqualUnmodifiableMapView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_entries);
}


/// Create a copy of GroceryView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroceryViewCopyWith<_GroceryView> get copyWith => __$GroceryViewCopyWithImpl<_GroceryView>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GroceryView&&const DeepCollectionEquality().equals(other.sections, _sections)&&const DeepCollectionEquality().equals(other.checkedKeys, _checkedKeys)&&const DeepCollectionEquality().equals(other.entries, _entries));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_sections),const DeepCollectionEquality().hash(_checkedKeys),const DeepCollectionEquality().hash(_entries));
}

@override
String toString() {
    return 'GroceryView(sections: $sections, checkedKeys: $checkedKeys, entries: $entries)';
}


}

/// @nodoc
abstract mixin class _$GroceryViewCopyWith<$Res> implements $GroceryViewCopyWith<$Res> {
  factory _$GroceryViewCopyWith(_GroceryView value, $Res Function(_GroceryView) _then) = __$GroceryViewCopyWithImpl;
@override @useResult
$Res call({
 List<GrocerySection> sections, List<String> checkedKeys, Map<String, GroceryEntry> entries
});




}
/// @nodoc
class __$GroceryViewCopyWithImpl<$Res>
    implements _$GroceryViewCopyWith<$Res> {
  __$GroceryViewCopyWithImpl(this._self, this._then);

  final _GroceryView _self;
  final $Res Function(_GroceryView) _then;

/// Create a copy of GroceryView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sections = null,Object? checkedKeys = null,Object? entries = null,}) {
  return _then(_GroceryView(
sections: null == sections ? _self._sections : sections // ignore: cast_nullable_to_non_nullable
as List<GrocerySection>,checkedKeys: null == checkedKeys ? _self._checkedKeys : checkedKeys // ignore: cast_nullable_to_non_nullable
as List<String>,entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as Map<String, GroceryEntry>,
  ));
}


}

// dart format on
