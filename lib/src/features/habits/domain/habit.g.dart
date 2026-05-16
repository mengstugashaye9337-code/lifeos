// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Habit _$HabitFromJson(Map<String, dynamic> json) => _Habit(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String?,
  streak: (json['streak'] as num?)?.toInt() ?? 0,
  createdAt: DateTime.parse(json['createdAt'] as String),
  isActive: json['isActive'] as bool? ?? true,
);

Map<String, dynamic> _$HabitToJson(_Habit instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'streak': instance.streak,
  'createdAt': instance.createdAt.toIso8601String(),
  'isActive': instance.isActive,
};
