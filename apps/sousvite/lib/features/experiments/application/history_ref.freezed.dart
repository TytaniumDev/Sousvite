// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'history_ref.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HistoryRef {

 Object? get id; DateTime get createdAt;
/// Create a copy of HistoryRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HistoryRefCopyWith<HistoryRef> get copyWith => _$HistoryRefCopyWithImpl<HistoryRef>(this as HistoryRef, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as HistoryRef;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HistoryRef&&const DeepCollectionEquality().equals(other.id, _this.id)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}


@override
int get hashCode {
  final _this = this as HistoryRef;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.id),_this.createdAt);
}

@override
String toString() {
  final _this = this as HistoryRef;
  return 'HistoryRef(id: ${_this.id}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $HistoryRefCopyWith<$Res>  {
  factory $HistoryRefCopyWith(HistoryRef value, $Res Function(HistoryRef) _then) = _$HistoryRefCopyWithImpl;
@useResult
$Res call({
 DateTime createdAt
});




}
/// @nodoc
class _$HistoryRefCopyWithImpl<$Res>
    implements $HistoryRefCopyWith<$Res> {
  _$HistoryRefCopyWithImpl(this._self, this._then);

  final HistoryRef _self;
  final $Res Function(HistoryRef) _then;

/// Create a copy of HistoryRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? createdAt = null,}) {
  return _then(_self.copyWith(
createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [HistoryRef].
extension HistoryRefPatterns on HistoryRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( VersionRef value)?  version,TResult Function( ExperimentRef value)?  experiment,required TResult orElse(),}){
final _that = this;
switch (_that) {
case VersionRef() when version != null:
return version(_that);case ExperimentRef() when experiment != null:
return experiment(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( VersionRef value)  version,required TResult Function( ExperimentRef value)  experiment,}){
final _that = this;
switch (_that) {
case VersionRef():
return version(_that);case ExperimentRef():
return experiment(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( VersionRef value)?  version,TResult? Function( ExperimentRef value)?  experiment,}){
final _that = this;
switch (_that) {
case VersionRef() when version != null:
return version(_that);case ExperimentRef() when experiment != null:
return experiment(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( RecipeVersionId id,  DateTime createdAt)?  version,TResult Function( ExperimentId id,  DateTime createdAt)?  experiment,required TResult orElse(),}) {final _that = this;
switch (_that) {
case VersionRef() when version != null:
return version(_that.id,_that.createdAt);case ExperimentRef() when experiment != null:
return experiment(_that.id,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( RecipeVersionId id,  DateTime createdAt)  version,required TResult Function( ExperimentId id,  DateTime createdAt)  experiment,}) {final _that = this;
switch (_that) {
case VersionRef():
return version(_that.id,_that.createdAt);case ExperimentRef():
return experiment(_that.id,_that.createdAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( RecipeVersionId id,  DateTime createdAt)?  version,TResult? Function( ExperimentId id,  DateTime createdAt)?  experiment,}) {final _that = this;
switch (_that) {
case VersionRef() when version != null:
return version(_that.id,_that.createdAt);case ExperimentRef() when experiment != null:
return experiment(_that.id,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class VersionRef implements HistoryRef {
  const VersionRef({required this.id, required this.createdAt});
  

@override final  RecipeVersionId id;
@override final  DateTime createdAt;

/// Create a copy of HistoryRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VersionRefCopyWith<VersionRef> get copyWith => _$VersionRefCopyWithImpl<VersionRef>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is VersionRef&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,createdAt);
}

@override
String toString() {
    return 'HistoryRef.version(id: $id, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $VersionRefCopyWith<$Res> implements $HistoryRefCopyWith<$Res> {
  factory $VersionRefCopyWith(VersionRef value, $Res Function(VersionRef) _then) = _$VersionRefCopyWithImpl;
@override @useResult
$Res call({
 RecipeVersionId id, DateTime createdAt
});




}
/// @nodoc
class _$VersionRefCopyWithImpl<$Res>
    implements $VersionRefCopyWith<$Res> {
  _$VersionRefCopyWithImpl(this._self, this._then);

  final VersionRef _self;
  final $Res Function(VersionRef) _then;

/// Create a copy of HistoryRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? createdAt = null,}) {
  return _then(VersionRef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as RecipeVersionId,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc


class ExperimentRef implements HistoryRef {
  const ExperimentRef({required this.id, required this.createdAt});
  

@override final  ExperimentId id;
@override final  DateTime createdAt;

/// Create a copy of HistoryRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExperimentRefCopyWith<ExperimentRef> get copyWith => _$ExperimentRefCopyWithImpl<ExperimentRef>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ExperimentRef&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,createdAt);
}

@override
String toString() {
    return 'HistoryRef.experiment(id: $id, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ExperimentRefCopyWith<$Res> implements $HistoryRefCopyWith<$Res> {
  factory $ExperimentRefCopyWith(ExperimentRef value, $Res Function(ExperimentRef) _then) = _$ExperimentRefCopyWithImpl;
@override @useResult
$Res call({
 ExperimentId id, DateTime createdAt
});




}
/// @nodoc
class _$ExperimentRefCopyWithImpl<$Res>
    implements $ExperimentRefCopyWith<$Res> {
  _$ExperimentRefCopyWithImpl(this._self, this._then);

  final ExperimentRef _self;
  final $Res Function(ExperimentRef) _then;

/// Create a copy of HistoryRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? createdAt = null,}) {
  return _then(ExperimentRef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as ExperimentId,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
