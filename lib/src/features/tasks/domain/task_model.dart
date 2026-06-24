import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_model.freezed.dart';

// ---------------------------------------------------------------------------
// Priority — domain enum, not a raw DB integer
// ---------------------------------------------------------------------------

enum TaskPriority { low, medium, high }

extension TaskPriorityX on TaskPriority {
  int toDbValue() => index + 1;

  String get label => switch (this) {
    TaskPriority.low => 'Low',
    TaskPriority.medium => 'Medium',
    TaskPriority.high => 'High',
  };

  static TaskPriority fromDb(int value) {
    if (value < 1 || value > TaskPriority.values.length) {
      return TaskPriority.low;
    }
    return TaskPriority.values[value - 1];
  }
}

// ---------------------------------------------------------------------------
// TaskModel — pure domain object, no DB or Flutter types
// ---------------------------------------------------------------------------

@freezed
abstract class TaskModel with _$TaskModel {
  const factory TaskModel({
    required int id,
    required String title,
    String? description,
    DateTime? dueDate,
    required bool isCompleted,
    required TaskPriority priority,
    required DateTime createdAt,
    required bool isSynced,
    String? remoteId,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _TaskModel;

  const TaskModel._();

  bool get isDeleted => deletedAt != null;

  bool get isOverdue {
    if (isCompleted || dueDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    return due.isBefore(today);
  }
}
