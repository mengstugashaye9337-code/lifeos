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

  // ── Sync helpers (used by Session 3 manual push/pull) ───────────────────

  Future<void> markTaskSynced({
    required int localId,
    String? remoteId,
    required DateTime updatedAt,
  }) async {
    await (_db.update(_db.tasks)..where((t) => t.id.equals(localId))).write(
      TaskMapper.toSyncedCompanion(
        id: localId,
        remoteId: remoteId == null
            ? const Value.absent()
            : Value(remoteId),
        updatedAt: updatedAt,
      ),
    );
  }

  Future<void> upsertFromRemote(TaskModel remoteTask) async {
    if (remoteTask.remoteId == null) return;

    final existingByRemote = await (_db.select(_db.tasks)
          ..where((t) => t.remoteId.equals(remoteTask.remoteId!))
          ..limit(1))
        .getSingleOrNull();

    if (existingByRemote != null &&
        existingByRemote.updatedAt.isAfter(remoteTask.updatedAt)) {
      return; // local wins when newer and unsynced changes exist
    }

    if (existingByRemote == null) {
      await _db.into(_db.tasks).insert(
        TasksCompanion.insert(
          title: remoteTask.title,
          description: Value(remoteTask.description),
          dueDate: Value(remoteTask.dueDate),
          isCompleted: Value(remoteTask.isCompleted),
          priority: Value(remoteTask.priority.toDbValue()),
          createdAt: Value(remoteTask.createdAt),
          isSynced: const Value(true),
          remoteId: Value(remoteTask.remoteId),
          updatedAt: Value(remoteTask.updatedAt),
          deletedAt: Value(remoteTask.deletedAt),
        ),
      );
      return;
    }

    await (_db.update(_db.tasks)..where((t) => t.id.equals(existingByRemote.id))).write(
      TasksCompanion(
        title: Value(remoteTask.title),
        description: Value(remoteTask.description),
        dueDate: Value(remoteTask.dueDate),
        isCompleted: Value(remoteTask.isCompleted),
        priority: Value(remoteTask.priority.toDbValue()),
        createdAt: Value(remoteTask.createdAt),
        isSynced: const Value(true),
        remoteId: Value(remoteTask.remoteId),
        updatedAt: Value(remoteTask.updatedAt),
        deletedAt: Value(remoteTask.deletedAt),
      ),
    );
  }
}
