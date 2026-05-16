import 'package:lifeos/src/database/app_database.dart';
import 'package:drift/drift.dart';

class TaskRepository {
  final AppDatabase _db;

  TaskRepository(this._db);

  // Stream all tasks (Updates UI in real-time)
  Stream<List<Task>> watchTasks() => _db.select(_db.tasks).watch();

  // Add a new task
  Future<int> addTask(TasksCompanion task) => _db.into(_db.tasks).insert(task);

  // Toggle completion status
  Future<void> toggleTask(Task task) {
    return (_db.update(_db.tasks)..where((t) => t.id.equals(task.id))).write(
      TasksCompanion(isCompleted: Value(!task.isCompleted)),
    );
  }

  // Delete a task
  Future<int> deleteTask(int id) =>
      (_db.delete(_db.tasks)..where((t) => t.id.equals(id))).go();
}
