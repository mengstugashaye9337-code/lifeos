// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Task _$TaskFromJson(Map<String, dynamic> json) => _Task(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  description: json['description'] as String?,
  isCompleted: json['isCompleted'] as bool? ?? false,
  createdAt: DateTime.parse(json['createdAt'] as String),
  dueDate: json['dueDate'] == null
      ? null
      : DateTime.parse(json['dueDate'] as String),
);

Map<String, dynamic> _$TaskToJson(_Task instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'isCompleted': instance.isCompleted,
  'createdAt': instance.createdAt.toIso8601String(),
  'dueDate': instance.dueDate?.toIso8601String(),
};
