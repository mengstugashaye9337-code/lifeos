// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AIMessage {

 String get id; String get content; bool get isUser; DateTime get timestamp;
/// Create a copy of AIMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AIMessageCopyWith<AIMessage> get copyWith => _$AIMessageCopyWithImpl<AIMessage>(this as AIMessage, _$identity);

  /// Serializes this AIMessage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AIMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.content, content) || other.content == content)&&(identical(other.isUser, isUser) || other.isUser == isUser)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,content,isUser,timestamp);

@override
String toString() {
  return 'AIMessage(id: $id, content: $content, isUser: $isUser, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class $AIMessageCopyWith<$Res>  {
  factory $AIMessageCopyWith(AIMessage value, $Res Function(AIMessage) _then) = _$AIMessageCopyWithImpl;
@useResult
$Res call({
 String id, String content, bool isUser, DateTime timestamp
});




}
/// @nodoc
class _$AIMessageCopyWithImpl<$Res>
    implements $AIMessageCopyWith<$Res> {
  _$AIMessageCopyWithImpl(this._self, this._then);

  final AIMessage _self;
  final $Res Function(AIMessage) _then;

/// Create a copy of AIMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? content = null,Object? isUser = null,Object? timestamp = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,isUser: null == isUser ? _self.isUser : isUser // ignore: cast_nullable_to_non_nullable
as bool,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [AIMessage].
extension AIMessagePatterns on AIMessage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AIMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AIMessage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AIMessage value)  $default,){
final _that = this;
switch (_that) {
case _AIMessage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AIMessage value)?  $default,){
final _that = this;
switch (_that) {
case _AIMessage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String content,  bool isUser,  DateTime timestamp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AIMessage() when $default != null:
return $default(_that.id,_that.content,_that.isUser,_that.timestamp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String content,  bool isUser,  DateTime timestamp)  $default,) {final _that = this;
switch (_that) {
case _AIMessage():
return $default(_that.id,_that.content,_that.isUser,_that.timestamp);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String content,  bool isUser,  DateTime timestamp)?  $default,) {final _that = this;
switch (_that) {
case _AIMessage() when $default != null:
return $default(_that.id,_that.content,_that.isUser,_that.timestamp);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AIMessage implements AIMessage {
  const _AIMessage({required this.id, required this.content, required this.isUser, required this.timestamp});
  factory _AIMessage.fromJson(Map<String, dynamic> json) => _$AIMessageFromJson(json);

@override final  String id;
@override final  String content;
@override final  bool isUser;
@override final  DateTime timestamp;

/// Create a copy of AIMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AIMessageCopyWith<_AIMessage> get copyWith => __$AIMessageCopyWithImpl<_AIMessage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AIMessageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AIMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.content, content) || other.content == content)&&(identical(other.isUser, isUser) || other.isUser == isUser)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,content,isUser,timestamp);

@override
String toString() {
  return 'AIMessage(id: $id, content: $content, isUser: $isUser, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class _$AIMessageCopyWith<$Res> implements $AIMessageCopyWith<$Res> {
  factory _$AIMessageCopyWith(_AIMessage value, $Res Function(_AIMessage) _then) = __$AIMessageCopyWithImpl;
@override @useResult
$Res call({
 String id, String content, bool isUser, DateTime timestamp
});




}
/// @nodoc
class __$AIMessageCopyWithImpl<$Res>
    implements _$AIMessageCopyWith<$Res> {
  __$AIMessageCopyWithImpl(this._self, this._then);

  final _AIMessage _self;
  final $Res Function(_AIMessage) _then;

/// Create a copy of AIMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? content = null,Object? isUser = null,Object? timestamp = null,}) {
  return _then(_AIMessage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,isUser: null == isUser ? _self.isUser : isUser // ignore: cast_nullable_to_non_nullable
as bool,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
