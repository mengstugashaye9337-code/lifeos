// lib/src/features/tasks/data/task_repository.dart
import 'package:drift/drift.dart';
import 'package:lifeos/src/database/app_database.dart';

// ---------------------------------------------------------------------------
// Priority enum with DB mapping
// ---------------------------------------------------------------------------

enum TaskPriority { low, medium, high }

extension TaskPriorityExtension on TaskPriority {
  int toDbValue() => index + 1;

  String get label {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
    }
  }
}

TaskPriority priorityFromDb(int value) {
  if (value < 1 || value > TaskPriority.values.length) return TaskPriority.low;
  return TaskPriority.values[value - 1];
}

// ---------------------------------------------------------------------------
// Repository
// ---------------------------------------------------------------------------

class TaskRepository {
  final AppDatabase _db;

  TaskRepository(this._db);

  Stream<List<Task>> watchTasks() => _db.select(_db.tasks).watch();

  Future<int> addTask(TasksCompanion task) => _db.into(_db.tasks).insert(task);

  /// Fixes Issue #2 safely: Uses the passed 'id' parameter directly for the search filter
  Future<void> updateTask(int id, TasksCompanion task) =>
      (_db.update(
            _db.tasks,
          )..where((t) => t.id.equals(id))) //  Changed from task.id.value to id
          .write(task);

  Future<void> toggleTask(Task task) {
    return updateTask(
      task.id,
      TasksCompanion(isCompleted: Value(!task.isCompleted)),
    );
  }

  Future<int> deleteTask(int id) =>
      (_db.delete(_db.tasks)..where((t) => t.id.equals(id))).go();
}
