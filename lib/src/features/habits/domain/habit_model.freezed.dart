// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'habit_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HabitModel {

 int get id; String? get remoteId; String get title; HabitFrequency get frequency; int get streak; DateTime? get lastCompletedDate; DateTime get createdAt; bool get isSynced; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of HabitModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HabitModelCopyWith<HabitModel> get copyWith => _$HabitModelCopyWithImpl<HabitModel>(this as HabitModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HabitModel&&(identical(other.id, id) || other.id == id)&&(identical(other.remoteId, remoteId) || other.remoteId == remoteId)&&(identical(other.title, title) || other.title == title)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.streak, streak) || other.streak == streak)&&(identical(other.lastCompletedDate, lastCompletedDate) || other.lastCompletedDate == lastCompletedDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isSynced, isSynced) || other.isSynced == isSynced)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,remoteId,title,frequency,streak,lastCompletedDate,createdAt,isSynced,updatedAt,deletedAt);

@override
String toString() {
  return 'HabitModel(id: $id, remoteId: $remoteId, title: $title, frequency: $frequency, streak: $streak, lastCompletedDate: $lastCompletedDate, createdAt: $createdAt, isSynced: $isSynced, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $HabitModelCopyWith<$Res>  {
  factory $HabitModelCopyWith(HabitModel value, $Res Function(HabitModel) _then) = _$HabitModelCopyWithImpl;
@useResult
$Res call({
 int id, String? remoteId, String title, HabitFrequency frequency, int streak, DateTime? lastCompletedDate, DateTime createdAt, bool isSynced, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$HabitModelCopyWithImpl<$Res>
    implements $HabitModelCopyWith<$Res> {
  _$HabitModelCopyWithImpl(this._self, this._then);

  final HabitModel _self;
  final $Res Function(HabitModel) _then;

/// Create a copy of HabitModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? remoteId = freezed,Object? title = null,Object? frequency = null,Object? streak = null,Object? lastCompletedDate = freezed,Object? createdAt = null,Object? isSynced = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,remoteId: freezed == remoteId ? _self.remoteId : remoteId // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as HabitFrequency,streak: null == streak ? _self.streak : streak // ignore: cast_nullable_to_non_nullable
as int,lastCompletedDate: freezed == lastCompletedDate ? _self.lastCompletedDate : lastCompletedDate // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,isSynced: null == isSynced ? _self.isSynced : isSynced // ignore: cast_nullable_to_non_nullable
as bool,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [HabitModel].
extension HabitModelPatterns on HabitModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HabitModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HabitModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HabitModel value)  $default,){
final _that = this;
switch (_that) {
case _HabitModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HabitModel value)?  $default,){
final _that = this;
switch (_that) {
case _HabitModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String? remoteId,  String title,  HabitFrequency frequency,  int streak,  DateTime? lastCompletedDate,  DateTime createdAt,  bool isSynced,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HabitModel() when $default != null:
return $default(_that.id,_that.remoteId,_that.title,_that.frequency,_that.streak,_that.lastCompletedDate,_that.createdAt,_that.isSynced,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String? remoteId,  String title,  HabitFrequency frequency,  int streak,  DateTime? lastCompletedDate,  DateTime createdAt,  bool isSynced,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _HabitModel():
return $default(_that.id,_that.remoteId,_that.title,_that.frequency,_that.streak,_that.lastCompletedDate,_that.createdAt,_that.isSynced,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String? remoteId,  String title,  HabitFrequency frequency,  int streak,  DateTime? lastCompletedDate,  DateTime createdAt,  bool isSynced,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _HabitModel() when $default != null:
return $default(_that.id,_that.remoteId,_that.title,_that.frequency,_that.streak,_that.lastCompletedDate,_that.createdAt,_that.isSynced,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc


class _HabitModel extends HabitModel {
  const _HabitModel({required this.id, this.remoteId, required this.title, required this.frequency, required this.streak, this.lastCompletedDate, required this.createdAt, required this.isSynced, required this.updatedAt, this.deletedAt}): super._();
  

@override final  int id;
@override final  String? remoteId;
@override final  String title;
@override final  HabitFrequency frequency;
@override final  int streak;
@override final  DateTime? lastCompletedDate;
@override final  DateTime createdAt;
@override final  bool isSynced;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of HabitModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HabitModelCopyWith<_HabitModel> get copyWith => __$HabitModelCopyWithImpl<_HabitModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HabitModel&&(identical(other.id, id) || other.id == id)&&(identical(other.remoteId, remoteId) || other.remoteId == remoteId)&&(identical(other.title, title) || other.title == title)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.streak, streak) || other.streak == streak)&&(identical(other.lastCompletedDate, lastCompletedDate) || other.lastCompletedDate == lastCompletedDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isSynced, isSynced) || other.isSynced == isSynced)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,remoteId,title,frequency,streak,lastCompletedDate,createdAt,isSynced,updatedAt,deletedAt);

@override
String toString() {
  return 'HabitModel(id: $id, remoteId: $remoteId, title: $title, frequency: $frequency, streak: $streak, lastCompletedDate: $lastCompletedDate, createdAt: $createdAt, isSynced: $isSynced, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$HabitModelCopyWith<$Res> implements $HabitModelCopyWith<$Res> {
  factory _$HabitModelCopyWith(_HabitModel value, $Res Function(_HabitModel) _then) = __$HabitModelCopyWithImpl;
@override @useResult
$Res call({
 int id, String? remoteId, String title, HabitFrequency frequency, int streak, DateTime? lastCompletedDate, DateTime createdAt, bool isSynced, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$HabitModelCopyWithImpl<$Res>
    implements _$HabitModelCopyWith<$Res> {
  __$HabitModelCopyWithImpl(this._self, this._then);

  final _HabitModel _self;
  final $Res Function(_HabitModel) _then;

/// Create a copy of HabitModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? remoteId = freezed,Object? title = null,Object? frequency = null,Object? streak = null,Object? lastCompletedDate = freezed,Object? createdAt = null,Object? isSynced = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_HabitModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,remoteId: freezed == remoteId ? _self.remoteId : remoteId // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as HabitFrequency,streak: null == streak ? _self.streak : streak // ignore: cast_nullable_to_non_nullable
as int,lastCompletedDate: freezed == lastCompletedDate ? _self.lastCompletedDate : lastCompletedDate // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,isSynced: null == isSynced ? _self.isSynced : isSynced // ignore: cast_nullable_to_non_nullable
as bool,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
