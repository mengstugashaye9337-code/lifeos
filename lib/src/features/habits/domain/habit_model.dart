import 'package:freezed_annotation/freezed_annotation.dart';

part 'habit_model.freezed.dart';

// ---------------------------------------------------------------------------
// Frequency — what the domain understands, not what the DB stores
// ---------------------------------------------------------------------------

enum HabitFrequency { daily, weekly }

extension HabitFrequencyX on HabitFrequency {
  String toDbValue() => name; // 'daily' | 'weekly'

  String get label => switch (this) {
    HabitFrequency.daily => 'Daily',
    HabitFrequency.weekly => 'Weekly',
  };

  static HabitFrequency fromDb(String value) => HabitFrequency.values
      .firstWhere((f) => f.name == value, orElse: () => HabitFrequency.daily);
}

// ---------------------------------------------------------------------------
// HabitModel — pure domain object, no DB types, no Flutter types
// ---------------------------------------------------------------------------

@freezed
abstract class HabitModel with _$HabitModel {
  const factory HabitModel({
    required int id,
    required String title,
    required HabitFrequency frequency,
    required int streak,
    required DateTime createdAt,
    required bool isSynced,
    DateTime? lastCompletedDate,
  }) = _HabitModel;

  // Convenience — is this habit already done for today?
  const HabitModel._();

  bool get isCompletedToday {
    if (lastCompletedDate == null) return false;
    final now = DateTime.now();
    final last = lastCompletedDate!;
    return last.year == now.year &&
        last.month == now.month &&
        last.day == now.day;
  }

  // Is the streak still alive or broken?
  bool get isStreakActive {
    if (lastCompletedDate == null || streak == 0) return false;
    final now = DateTime.now();
    final last = lastCompletedDate!;
    final diff = now.difference(last).inDays;
    return switch (frequency) {
      HabitFrequency.daily => diff <= 1,
      HabitFrequency.weekly => diff <= 7,
    };
  }
}
