import 'package:lifeos/src/database/app_database.dart';
import 'package:lifeos/src/features/tasks/data/task_mapper.dart';
import 'package:lifeos/src/features/tasks/domain/task_model.dart';

// ---------------------------------------------------------------------------
// Abstract contract — swappable local ↔ remote (Phase E)
// ---------------------------------------------------------------------------

abstract interface class ITaskRepository {
  Stream<List<TaskModel>> watchTasks();
  Future<int> addTask(TaskModel task);
  Future<void> updateTask(TaskModel task);
  Future<void> toggleTask(TaskModel task);
  Future<void> deleteTask(int id);
}

// ---------------------------------------------------------------------------
// Local implementation — Drift + SQLite
// ---------------------------------------------------------------------------

class LocalTaskRepository implements ITaskRepository {
  final AppDatabase _db;

  LocalTaskRepository(this._db);

  @override
  Stream<List<TaskModel>> watchTasks() {
    return _db.select(_db.tasks).watch().map(
      (rows) => rows.map(TaskMapper.fromRow).toList(),
    );
  }

  @override
  Future<int> addTask(TaskModel task) =>
      _db.into(_db.tasks).insert(TaskMapper.toInsertCompanion(task));

  @override
  Future<void> updateTask(TaskModel task) =>
      (_db.update(_db.tasks)..where((t) => t.id.equals(task.id))).write(
        TaskMapper.toUpdateCompanion(task),
      );

  @override
  Future<void> toggleTask(TaskModel task) {
    return updateTask(task.copyWith(isCompleted: !task.isCompleted));
  }

  @override
  Future<int> deleteTask(int id) =>
      (_db.delete(_db.tasks)..where((t) => t.id.equals(id))).go();
}
