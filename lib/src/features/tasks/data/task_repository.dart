import 'package:drift/drift.dart';
import 'package:lifeos/src/database/app_database.dart';
import 'package:lifeos/src/features/tasks/data/task_mapper.dart';
import 'package:lifeos/src/features/tasks/domain/task_model.dart';

// ---------------------------------------------------------------------------
// Abstract contract — swappable local ↔ remote (Phase E)
// ---------------------------------------------------------------------------

abstract interface class ITaskRepository {
  Stream<List<TaskModel>> watchTasks();
  Future<List<TaskModel>> getUnsyncedTasks();
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
    return (_db.select(_db.tasks)..where((t) => t.deletedAt.isNull()))
        .watch()
        .map((rows) => rows.map(TaskMapper.fromRow).toList());
  }

  @override
  Future<List<TaskModel>> getUnsyncedTasks() async {
    final rows = await (_db.select(
      _db.tasks,
    )..where((t) => t.isSynced.equals(false))).get();
    return rows.map(TaskMapper.fromRow).toList();
  }

  @override
  Future<int> addTask(TaskModel task) {
    final now = DateTime.now();
    return _db.into(_db.tasks).insert(
      TaskMapper.toInsertCompanion(
        task.copyWith(
          isSynced: false,
          createdAt: now,
          updatedAt: now,
        ),
      ),
    );
  }

  @override
  Future<void> updateTask(TaskModel task) {
    final now = DateTime.now();
    return (_db.update(_db.tasks)..where((t) => t.id.equals(task.id))).write(
      TaskMapper.toUpdateCompanion(
        task.copyWith(isSynced: false, updatedAt: now),
      ),
    );
  }

  @override
  Future<void> toggleTask(TaskModel task) {
    return updateTask(task.copyWith(isCompleted: !task.isCompleted));
  }

  @override
  Future<void> deleteTask(int id) async {
    final now = DateTime.now();
    await (_db.update(_db.tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
        isSynced: const Value(false),
      ),
    );
  }
}
