import 'package:freezed_annotation/freezed_annotation.dart';

part 'habit.freezed.dart';
part 'habit.g.dart';

@freezed
class Habit with _$Habit {
  const factory Habit({
    required int id,
    required String name,
    String? description,
    @Default(0) int streak,
    required DateTime createdAt,
    @Default(true) bool isActive,
  }) = _Habit;

  factory Habit.fromJson(Map<String, dynamic> json) => _$HabitFromJson(json);
}
