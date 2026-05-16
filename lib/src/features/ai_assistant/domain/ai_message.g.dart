// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AIMessage _$AIMessageFromJson(Map<String, dynamic> json) => _AIMessage(
  id: json['id'] as String,
  content: json['content'] as String,
  isUser: json['isUser'] as bool,
  timestamp: DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$AIMessageToJson(_AIMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'isUser': instance.isUser,
      'timestamp': instance.timestamp.toIso8601String(),
    };
