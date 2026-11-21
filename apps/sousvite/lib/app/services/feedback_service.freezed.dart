// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feedback_service.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FeedbackReport implements DiagnosticableTreeMixin {

/// What happened, or the idea, in the user's words.
 String get message;/// Where to reply, if the user typed it. Empty for none.
 String get email;/// A PNG of the screen the report is about, if the user captured one.
 Uint8List? get screenshot;/// The app location of [screenshot], such as `/library/folders/<id>`.
 String? get location;
/// Create a copy of FeedbackReport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FeedbackReportCopyWith<FeedbackReport> get copyWith => _$FeedbackReportCopyWithImpl<FeedbackReport>(this as FeedbackReport, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  final _this = this as FeedbackReport;
  properties
    ..add(DiagnosticsProperty('type', 'FeedbackReport'))
    ..add(DiagnosticsProperty('message', _this.message))..add(DiagnosticsProperty('email', _this.email))..add(DiagnosticsProperty('screenshot', _this.screenshot))..add(DiagnosticsProperty('location', _this.location));
}

@override
bool operator ==(Object other) {
  final _this = this as FeedbackReport;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FeedbackReport&&(identical(other.message, _this.message) || other.message == _this.message)&&(identical(other.email, _this.email) || other.email == _this.email)&&const DeepCollectionEquality().equals(other.screenshot, _this.screenshot)&&(identical(other.location, _this.location) || other.location == _this.location));
}


@override
int get hashCode {
  final _this = this as FeedbackReport;
  return Object.hash(runtimeType,_this.message,_this.email,const DeepCollectionEquality().hash(_this.screenshot),_this.location);
}

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  final _this = this as FeedbackReport;
  return 'FeedbackReport(message: ${_this.message}, email: ${_this.email}, screenshot: ${_this.screenshot}, location: ${_this.location})';
}


}

/// @nodoc
abstract mixin class $FeedbackReportCopyWith<$Res>  {
  factory $FeedbackReportCopyWith(FeedbackReport value, $Res Function(FeedbackReport) _then) = _$FeedbackReportCopyWithImpl;
@useResult
$Res call({
 String message, String email, Uint8List? screenshot, String? location
});




}
/// @nodoc
class _$FeedbackReportCopyWithImpl<$Res>
    implements $FeedbackReportCopyWith<$Res> {
  _$FeedbackReportCopyWithImpl(this._self, this._then);

  final FeedbackReport _self;
  final $Res Function(FeedbackReport) _then;

/// Create a copy of FeedbackReport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? message = null,Object? email = null,Object? screenshot = freezed,Object? location = freezed,}) {
  return _then(FeedbackReport(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,screenshot: freezed == screenshot ? _self.screenshot : screenshot // ignore: cast_nullable_to_non_nullable
as Uint8List?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [FeedbackReport].
extension FeedbackReportPatterns on FeedbackReport {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FeedbackReport value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FeedbackReport() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FeedbackReport value)  $default,){
final _that = this;
switch (_that) {
case _FeedbackReport():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FeedbackReport value)?  $default,){
final _that = this;
switch (_that) {
case _FeedbackReport() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String message,  String email,  Uint8List? screenshot,  String? location)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FeedbackReport() when $default != null:
return $default(_that.message,_that.email,_that.screenshot,_that.location);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String message,  String email,  Uint8List? screenshot,  String? location)  $default,) {final _that = this;
switch (_that) {
case _FeedbackReport():
return $default(_that.message,_that.email,_that.screenshot,_that.location);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String message,  String email,  Uint8List? screenshot,  String? location)?  $default,) {final _that = this;
switch (_that) {
case _FeedbackReport() when $default != null:
return $default(_that.message,_that.email,_that.screenshot,_that.location);case _:
  return null;

}
}

}

/// @nodoc


class _FeedbackReport with DiagnosticableTreeMixin implements FeedbackReport {
  const _FeedbackReport({this.message = '', this.email = '', this.screenshot, this.location});
  

/// What happened, or the idea, in the user's words.
@override@JsonKey() final  String message;
/// Where to reply, if the user typed it. Empty for none.
@override@JsonKey() final  String email;
/// A PNG of the screen the report is about, if the user captured one.
@override final  Uint8List? screenshot;
/// The app location of [screenshot], such as `/library/folders/<id>`.
@override final  String? location;

/// Create a copy of FeedbackReport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FeedbackReportCopyWith<_FeedbackReport> get copyWith => __$FeedbackReportCopyWithImpl<_FeedbackReport>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
    ..add(DiagnosticsProperty('type', 'FeedbackReport'))
    ..add(DiagnosticsProperty('message', message))..add(DiagnosticsProperty('email', email))..add(DiagnosticsProperty('screenshot', screenshot))..add(DiagnosticsProperty('location', location));
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FeedbackReport&&(identical(other.message, message) || other.message == message)&&(identical(other.email, email) || other.email == email)&&const DeepCollectionEquality().equals(other.screenshot, screenshot)&&(identical(other.location, location) || other.location == location));
}


@override
int get hashCode {
    return Object.hash(runtimeType,message,email,const DeepCollectionEquality().hash(screenshot),location);
}

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
    return 'FeedbackReport(message: $message, email: $email, screenshot: $screenshot, location: $location)';
}


}

/// @nodoc
abstract mixin class _$FeedbackReportCopyWith<$Res> implements $FeedbackReportCopyWith<$Res> {
  factory _$FeedbackReportCopyWith(_FeedbackReport value, $Res Function(_FeedbackReport) _then) = __$FeedbackReportCopyWithImpl;
@override @useResult
$Res call({
 String message, String email, Uint8List? screenshot, String? location
});




}
/// @nodoc
class __$FeedbackReportCopyWithImpl<$Res>
    implements _$FeedbackReportCopyWith<$Res> {
  __$FeedbackReportCopyWithImpl(this._self, this._then);

  final _FeedbackReport _self;
  final $Res Function(_FeedbackReport) _then;

/// Create a copy of FeedbackReport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,Object? email = null,Object? screenshot = freezed,Object? location = freezed,}) {
  return _then(_FeedbackReport(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,screenshot: freezed == screenshot ? _self.screenshot : screenshot // ignore: cast_nullable_to_non_nullable
as Uint8List?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
